package com.k8s.demo.dto;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class UserRequest {
    private String username;
    private String email;
    private String password;
}
