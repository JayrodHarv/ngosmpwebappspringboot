package com.jayrodharv.ngosmpwebappspringboot.dto.user;

import java.util.Set;

public record UserSessionDTO(
    Integer userId,
    String displayName,
    Set<String> roles,
    Set<String> permissions
) {}

// How to check if a user has a specific permission
// sessionUser.permissions().contains("BUILD_UPDATE_ALL");