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
  region  = "ap-southeast-1"
}

# lambda role
resource "aws_iam_role" "iam_role_for_lambda_all" {
  name = "lambda-invoke-role-all"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

# lambda policy
resource "aws_iam_policy" "iam_policy_for_lambda_all" {
  name = "lambda-invoke-policy-all"
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "LambdaPolicy",
        "Effect": "Allow",
        "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSubnets",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
  }
EOF
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment_all" {
  role       = "${aws_iam_role.iam_role_for_lambda_all.name}"
  policy_arn = "${aws_iam_policy.iam_policy_for_lambda_all.arn}"
}
################END OF IAM###############################


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
  filename      = "target/springbootawsapi-0.0.1-SNAPSHOT1.jar"
  #source_code_hash = "${base64sha256(file(var.lambda_payload_filename))}"
  function_name = "spring_misc_function"

  handler          = "com.learn.springbootawsapi.LambdaHandler"
  timeout = 60
  role             = aws_iam_role.iam_role_for_lambda_all.arn
  depends_on   = [aws_cloudwatch_log_group.spring_misc_log_group]
  memory_size = 1024

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    #subnet_ids         = [172.31.32.0/20, 172.31.16.0/20, 172.31.0.0/20]
    subnet_ids = ["subnet-0d919a7517bdd0b5e","subnet-0a01af556f68f1234", "subnet-0fede3802b522bcff"]
    security_group_ids = ["sg-0084d2399a869752d"]
  }

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
  filename      = "target/springbootawsapi-0.0.1-SNAPSHOT1.jar"
  #source_code_hash = "${base64sha256(file(var.lambda_payload_filename))}"
  function_name = "spring_misc2_function"

  handler          = "com.learn.springbootawsapi.LambdaHandler"
  timeout = 60
  role             = aws_iam_role.iam_role_for_lambda_all.arn
  depends_on   = [aws_cloudwatch_log_group.spring_misc2_log_group]
  memory_size = 1024

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    #subnet_ids         = [172.31.32.0/20, 172.31.16.0/20, 172.31.0.0/20]
    subnet_ids = ["subnet-0d919a7517bdd0b5e","subnet-0a01af556f68f1234", "subnet-0fede3802b522bcff"]
    security_group_ids = ["sg-0084d2399a869752d"]
  }

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

#####user#########
resource "aws_api_gateway_resource" "ParentUserResource" {
  rest_api_id = aws_api_gateway_rest_api.SpringMiscAPI.id
  parent_id   = aws_api_gateway_rest_api.SpringMiscAPI.root_resource_id
  path_part   = "user"
}
##############

################addUser################

resource "aws_api_gateway_method" "AddUserMethod" {
  rest_api_id   = aws_api_gateway_rest_api.SpringMiscAPI.id
  resource_id   = aws_api_gateway_resource.ParentUserResource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_lambda_function" "add_user_function" {
  runtime          = "java17"
  filename      = "target/springbootawsapi-0.0.1-SNAPSHOT1.jar"
  #source_code_hash = "${base64sha256(file(var.lambda_payload_filename))}"
  function_name = "add_user_function"

  handler          = "com.learn.springbootawsapi.LambdaHandler"
  timeout = 60
  #role             = "arn:aws:iam::975049941293:role/lambda-invoke-role"
  role             = aws_iam_role.iam_role_for_lambda_all.arn
  depends_on   = [aws_cloudwatch_log_group.add_user_log_group]
  memory_size = 1024

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    #subnet_ids         = [172.31.32.0/20, 172.31.16.0/20, 172.31.0.0/20]
    subnet_ids = ["subnet-0d919a7517bdd0b5e","subnet-0a01af556f68f1234", "subnet-0fede3802b522bcff"]
    security_group_ids = ["sg-0084d2399a869752d"]
  }

}

resource "aws_cloudwatch_log_group" "add_user_log_group" {
  name = "/aws/lambda/add_user_function"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_lambda_permission" "add_user_function" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.add_user_function.function_name
  principal     = "apigateway.amazonaws.com"
  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.SpringMiscAPI.execution_arn}/*/${aws_api_gateway_method.AddUserMethod.http_method}/${aws_api_gateway_resource.ParentUserResource.path_part}"
}

resource "aws_api_gateway_integration" "add_user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.SpringMiscAPI.id
  resource_id             = aws_api_gateway_resource.ParentUserResource.id
  http_method             = aws_api_gateway_method.AddUserMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_user_function.invoke_arn
  depends_on = [
    aws_lambda_permission.add_user_function]
}

################getUser################
resource "aws_api_gateway_method" "GetUserMethod" {
  rest_api_id   = aws_api_gateway_rest_api.SpringMiscAPI.id
  resource_id   = aws_api_gateway_resource.ParentUserResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_lambda_function" "get_user_function" {
  runtime          = "java17"
  filename      = "target/springbootawsapi-0.0.1-SNAPSHOT1.jar"
  #source_code_hash = "${base64sha256(file(var.lambda_payload_filename))}"
  function_name = "get_user_function"

  handler          = "com.learn.springbootawsapi.LambdaHandler"
  timeout = 60
  #role             = "arn:aws:iam::975049941293:role/lambda-invoke-role"
  role             = aws_iam_role.iam_role_for_lambda_all.arn
  depends_on   = [aws_cloudwatch_log_group.get_user2_log_group]
  memory_size = 1024

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    #subnet_ids         = [172.31.32.0/20, 172.31.16.0/20, 172.31.0.0/20]
    subnet_ids = ["subnet-0d919a7517bdd0b5e","subnet-0a01af556f68f1234", "subnet-0fede3802b522bcff"]
    security_group_ids = ["sg-0084d2399a869752d"]
  }

}

resource "aws_cloudwatch_log_group" "get_user2_log_group" {
  name = "/aws/lambda/get_user2_function"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_lambda_permission" "get_user_function" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.SpringMiscAPI.execution_arn}/*/${aws_api_gateway_method.GetUserMethod.http_method}/${aws_api_gateway_resource.ParentUserResource.path_part}"
}

resource "aws_api_gateway_integration" "get_user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.SpringMiscAPI.id
  resource_id             = aws_api_gateway_resource.ParentUserResource.id
  http_method             = aws_api_gateway_method.GetUserMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_user_function.invoke_arn
  depends_on = [
    aws_lambda_permission.get_user_function]
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

  depends_on = [aws_api_gateway_integration.spring_misc_integration, aws_api_gateway_integration.spring_misc2_integration,aws_api_gateway_integration.add_user_integration, aws_api_gateway_integration.get_user_integration]
}

/*resource "aws_api_gateway_base_path_mapping" "MyDemoResource" {
  api_id      = aws_api_gateway_rest_api.MyDemoAPI.id
  stage_name = aws_api_gateway_deployment.v1.stage_name
  domain_name = ""
}*/


