package com.jayrodharv.ngosmpwebappspringboot.dto.user;

public record UserListDTO(
    Integer userId,
    String displayName,
    String pfpPath
) {}
