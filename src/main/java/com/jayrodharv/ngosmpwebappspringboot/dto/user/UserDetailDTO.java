package com.jayrodharv.ngosmpwebappspringboot.dto.user;

import java.time.LocalDateTime;

public record UserDetailDTO(
    Integer userId,
    String email,
    String displayName,
    String status,
    LocalDateTime createdAt,
    LocalDateTime lastSeen
) {}
