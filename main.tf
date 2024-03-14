terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}


resource "aws_api_gateway_rest_api" "SpringMiscAPI" {
  name        = "SpringMiscAPI"
  description = "This is Spring Boot API for demonstration purposes"
}

resource "aws_api_gateway_resource" "SpringMiscResource" {
  rest_api_id = aws_api_gateway_rest_api.SpringMiscAPI.id
  parent_id   = aws_api_gateway_rest_api.SpringMiscAPI.root_resource_id
  path_part   = "springmiscapis"
}

resource "aws_api_gateway_method" "SpringMiscMethod" {
  rest_api_id   = aws_api_gateway_rest_api.SpringMiscAPI.id
  resource_id   = aws_api_gateway_resource.SpringMiscResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_lambda_function" "spring_misc_function" {
  runtime          = "java17"
  filename      = "target/springbootawsapi-0.0.1-SNAPSHOT.jar"
  #source_code_hash = "${base64sha256(file(var.lambda_payload_filename))}"
  function_name = "spring_misc_function"

  handler          = "com.learn.springbootawsapi.LambdaHandler"
  timeout = 60
  role             = "arn:aws:iam::975049941293:role/lambda-invoke-role"
  depends_on   = [aws_cloudwatch_log_group.spring_misc_log_group]

}

resource "aws_cloudwatch_log_group" "spring_misc_log_group" {
  name = "/aws/lambda/spring_misc_function"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_lambda_permission" "spring_misc_function" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.spring_misc_function.function_name
  principal     = "apigateway.amazonaws.com"
  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.SpringMiscAPI.execution_arn}/*/${aws_api_gateway_method.SpringMiscMethod.http_method}/${aws_api_gateway_resource.SpringMiscResource.path_part}"
}

resource "aws_api_gateway_integration" "spring_misc_integration" {
  rest_api_id             = aws_api_gateway_rest_api.SpringMiscAPI.id
  resource_id             = aws_api_gateway_resource.SpringMiscResource.id
  http_method             = aws_api_gateway_method.SpringMiscMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.spring_misc_function.invoke_arn
  depends_on = [
  aws_lambda_permission.spring_misc_function]
}


################miscapis2################
resource "aws_api_gateway_resource" "SpringMisc2Resource" {
  rest_api_id = aws_api_gateway_rest_api.SpringMiscAPI.id
  parent_id   = aws_api_gateway_rest_api.SpringMiscAPI.root_resource_id
  path_part   = "springmiscapis2"
}

resource "aws_api_gateway_method" "SpringMisc2Method" {
  rest_api_id   = aws_api_gateway_rest_api.SpringMiscAPI.id
  resource_id   = aws_api_gateway_resource.SpringMisc2Resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_lambda_function" "spring_misc2_function" {
  runtime          = "java17"
  filename      = "target/springbootawsapi-0.0.1-SNAPSHOT.jar"
  #source_code_hash = "${base64sha256(file(var.lambda_payload_filename))}"
  function_name = "spring_misc2_function"

  handler          = "com.learn.springbootawsapi.LambdaHandler"
  timeout = 60
  role             = "arn:aws:iam::975049941293:role/lambda-invoke-role"
  depends_on   = [aws_cloudwatch_log_group.spring_misc2_log_group]

}

resource "aws_cloudwatch_log_group" "spring_misc2_log_group" {
  name = "/aws/lambda/spring_misc2_function"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_lambda_permission" "spring_misc2_function" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.spring_misc2_function.function_name
  principal     = "apigateway.amazonaws.com"
  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.SpringMiscAPI.execution_arn}/*/${aws_api_gateway_method.SpringMisc2Method.http_method}/${aws_api_gateway_resource.SpringMisc2Resource.path_part}"
}

resource "aws_api_gateway_integration" "spring_misc2_integration" {
  rest_api_id             = aws_api_gateway_rest_api.SpringMiscAPI.id
  resource_id             = aws_api_gateway_resource.SpringMisc2Resource.id
  http_method             = aws_api_gateway_method.SpringMisc2Method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.spring_misc2_function.invoke_arn
  depends_on = [
    aws_lambda_permission.spring_misc2_function]
}



resource "aws_api_gateway_deployment" "v1" {
  rest_api_id = aws_api_gateway_rest_api.SpringMiscAPI.id
  stage_name = "v1"

  # To trigger a redeployment every terraform apply
  stage_description = "Deployed at ${timestamp()}"

  lifecycle {
    ignore_changes = [
      stage_name
    ]
  }

  depends_on = [aws_api_gateway_integration.spring_misc_integration, aws_api_gateway_integration.spring_misc2_integration]
}

/*resource "aws_api_gateway_base_path_mapping" "MyDemoResource" {
  api_id      = aws_api_gateway_rest_api.MyDemoAPI.id
  stage_name = aws_api_gateway_deployment.v1.stage_name
  domain_name = ""
}*/


