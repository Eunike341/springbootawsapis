package com.learn.springbootawsapi;

import com.learn.springbootawsapi.model.UserDto;
import com.learn.springbootawsapi.service.UserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@RestController
@EnableWebMvc
public class MiscController {

    private final UserService userService;

    public MiscController(UserService userService) {
        this.userService = userService;
    }


    @GetMapping("/adduser")
    public UserDto addUser () {
        System.out.println("==========addUser is called");
        var userDto = userService.createUser("userName", "email");
        System.out.println("==========userService is called, returning:" + userDto);
        return userDto;
    }

}
