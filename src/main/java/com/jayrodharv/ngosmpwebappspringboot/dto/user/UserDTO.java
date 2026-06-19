package com.jayrodharv.ngosmpwebappspringboot.dto.user;

import java.time.LocalDateTime;

public record UserDTO(
    Integer userId,
    String displayName,
    String status,
    LocalDateTime lastSeen,
    LocalDateTime createdAt,
    String pfpPath
) {}
