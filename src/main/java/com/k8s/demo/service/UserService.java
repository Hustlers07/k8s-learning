package com.k8s.demo.service;

import com.k8s.demo.dto.User;
import com.k8s.demo.dto.UserRequest;

import java.util.List;

public interface UserService {

    public List<User> getAllUsers();
    public User saveUser(UserRequest request);
    public User getUserByUsername(String username);
}
