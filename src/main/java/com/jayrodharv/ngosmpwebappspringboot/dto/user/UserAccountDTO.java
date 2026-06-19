package com.jayrodharv.ngosmpwebappspringboot.dto.user;

import java.time.LocalDateTime;

public record UserAccountDTO(
    Integer userId,
    String email,
    String displayName,
    String status,
    LocalDateTime lastSeen,
    LocalDateTime createdAt,
    LocalDateTime lastUpdatedAt,
    String pfpPath
) {}
