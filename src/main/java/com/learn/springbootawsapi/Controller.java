package com.learn.springbootawsapi;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@RestController
@EnableWebMvc
public class Controller {

    @GetMapping("/springmiscapis")
    public String sayHello () {
        return "hello springmiscapis";
    }
}
