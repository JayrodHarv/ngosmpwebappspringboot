package com.jayrodharv.ngosmpwebappspringboot.dto.user;

public record UserLoginDTO (
    Integer userId,
    String displayName,
    String passwordHash,
    String status
) {}
