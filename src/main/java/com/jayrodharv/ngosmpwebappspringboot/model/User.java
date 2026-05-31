package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

/**
 * Maps to the User table.
 * UserID is the user's email address (PK).
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    private String userId;          // email
    private String displayName;
    private String password;        // BCrypt hash
    private String language;
    private String status;          // active | inactive | locked
    private String roleId;
    private LocalDateTime createdAt;
    private LocalDateTime lastLoggedIn;
    private LocalDateTime updatedAt;
    private Integer pfpImageId;

    // ── Convenience helpers ──────────────────────────────────────────────────

    public boolean isActive()   { return "active".equalsIgnoreCase(status); }
    public boolean isLocked()   { return "locked".equalsIgnoreCase(status); }
    public boolean isInactive() { return "inactive".equalsIgnoreCase(status); }
}
