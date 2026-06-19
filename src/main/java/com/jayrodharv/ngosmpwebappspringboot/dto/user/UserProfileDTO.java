package com.jayrodharv.ngosmpwebappspringboot.dto.user;

import java.time.LocalDateTime;

public record UserProfileDTO(
    Integer userId,
    String displayName,
    LocalDateTime lastSeen,
    LocalDateTime createdAt,
    String pfpPath
) {}
