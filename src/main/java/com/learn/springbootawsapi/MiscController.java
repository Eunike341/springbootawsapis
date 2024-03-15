package com.learn.springbootawsapi;

import com.learn.springbootawsapi.model.UserDto;
import com.learn.springbootawsapi.service.UserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

@RestController
@EnableWebMvc
public class MiscController {

    private final UserService userService;

    public MiscController(UserService userService) {
        this.userService = userService;
    }


    @PostMapping("/adduser")
    public UserDto addUser (@RequestBody(required = false) UserDto user) {
        System.out.println("==========addUser is called with user:" + user);
        if(user == null) {
            user = new UserDto(new Random().ints(4, 'a', 'z' + 1)
                    .mapToObj(i -> String.valueOf((char)i))
                    .collect(Collectors.joining()),
                    new Random().ints(4, 'a', 'z' + 1)
                    .mapToObj(i -> String.valueOf((char)i))
                    .collect(Collectors.joining())+"@email.com");
        }
        var userDto = userService.createUser(user.username(), user.email());
        System.out.println("==========userService is called, returning:" + userDto);
        return userDto;
//        System.out.println("==========getuser is called");
//        return userService.getUsers();
    }

    @GetMapping("/getuser")
    public List<UserDto> getUser () {
        System.out.println("==========getuser is called");
        return userService.getUsers();
    }

}
