package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * Maps to the Role table.
 * RoleID is the PK (string name like "Admin", "User").
 * Each BIT column is stored as boolean.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Role {

    private String roleId;
    private String description;

    // Build permissions
    private boolean canAddBuilds;
    private boolean canEditAllBuilds;
    private boolean canDeleteAllBuilds;

    // BuildType permissions
    private boolean canViewBuildTypes;
    private boolean canAddBuildTypes;
    private boolean canEditBuildTypes;
    private boolean canDeleteBuildTypes;

    // World permissions
    private boolean canViewWorlds;
    private boolean canAddWorlds;
    private boolean canEditWorlds;
    private boolean canDeleteWorlds;

    // Vote permissions
    private boolean canViewAllVotes;
    private boolean canAddVotes;
    private boolean canEditAllVotes;
    private boolean canDeleteAllVotes;

    // Role permissions
    private boolean canViewRoles;
    private boolean canAddRoles;
    private boolean canEditRoles;
    private boolean canDeleteRoles;

    // User permissions
    private boolean canViewUsers;
    private boolean canAddUsers;
    private boolean canEditUsers;
    private boolean canBanUsers;
}
