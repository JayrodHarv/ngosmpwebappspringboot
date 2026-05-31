package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

/**
 * ViewModel returned by sp_get_userVM.
 * Combines User + Role permissions + profile image into one object,
 * so controllers and Thymeleaf templates don't need to join manually.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserVM {

    // ── User fields ──────────────────────────────────────────────────────────
    private String userId;
    private String displayName;
    private String language;
    private String status;
    private String roleId;
    private LocalDateTime createdAt;
    private LocalDateTime lastLoggedIn;
    private LocalDateTime updatedAt;

    // ── Role permissions ─────────────────────────────────────────────────────
    private boolean canAddBuilds;
    private boolean canEditAllBuilds;
    private boolean canDeleteAllBuilds;

    private boolean canViewBuildTypes;
    private boolean canAddBuildTypes;
    private boolean canEditBuildTypes;
    private boolean canDeleteBuildTypes;

    private boolean canViewWorlds;
    private boolean canAddWorlds;
    private boolean canEditWorlds;
    private boolean canDeleteWorlds;

    private boolean canViewAllVotes;
    private boolean canAddVotes;
    private boolean canEditAllVotes;
    private boolean canDeleteAllVotes;

    private boolean canViewRoles;
    private boolean canAddRoles;
    private boolean canEditRoles;
    private boolean canDeleteRoles;

    private boolean canViewUsers;
    private boolean canAddUsers;
    private boolean canEditUsers;
    private boolean canBanUsers;

    private String roleDescription;

    // ── Profile picture ───────────────────────────────────────────────────────
    private Integer imageId;
    private String fileName;
    private String mimeType;
    private String filePath;

    // ── Convenience ───────────────────────────────────────────────────────────
    public boolean hasProfilePicture() { return imageId != null; }
    public boolean isActive()          { return "active".equalsIgnoreCase(status); }
    public boolean isLocked()          { return "locked".equalsIgnoreCase(status); }
}
