package com.learn.springbootawsapi.service;

import com.learn.springbootawsapi.model.UserDto;
import com.learn.springbootawsapi.repository.User;
import com.learn.springbootawsapi.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserDto createUser (String userName, String email) {
        System.out.println("=======createUser is called");
        var user = new User();
        user.setActive(true);
        user.setEmail(email);
        user.setFirstName("first name");
        user.setLastName("last name");
        user.setPasswordHash("xxx");
        user.setUsername(userName);
        System.out.println("===========before calling repository");
        this.userRepository.save(user);
        System.out.println("===========after calling repository");
        return new UserDto(user);
    }
}
