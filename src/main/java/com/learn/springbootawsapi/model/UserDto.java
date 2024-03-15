package com.learn.springbootawsapi.model;

import com.learn.springbootawsapi.repository.User;

public record UserDto(String username, String email) {
    public UserDto (User user) {
        this(user.getUsername(), user.getEmail());
    }
}
