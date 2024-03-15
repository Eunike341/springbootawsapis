package com.learn.springbootawsapi.service;

import com.learn.springbootawsapi.model.UserDto;
import com.learn.springbootawsapi.repository.User;
import com.learn.springbootawsapi.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

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

    public List<UserDto> getUsers () {
        System.out.println("====getUsers is called");
        return Optional.ofNullable(userRepository.findAll())
                .stream()
                .flatMap(Collection::stream)
                .map(UserDto::new)
                .collect(Collectors.toList());
    }
}
