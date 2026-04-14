package com.k8s.demo.controller;


import com.k8s.demo.dto.User;
import com.k8s.demo.dto.UserRequest;
import com.k8s.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/user")
public class DemoController {

    @Autowired
    private UserService userService;

    @GetMapping("/health")
    public String helloWorld() {
        return ResponseEntity.ok().body("Hello World").getBody();
    }

    @GetMapping("/all")
    public ResponseEntity<List<User>> hello() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @PostMapping("/add")
    public ResponseEntity<User> addUser(@RequestBody UserRequest request) {

        try {
            User user = userService.saveUser(request);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            // Handle any exceptions that may occur during the database query
            return ResponseEntity.status(500).body(null);
        }
    }
}
