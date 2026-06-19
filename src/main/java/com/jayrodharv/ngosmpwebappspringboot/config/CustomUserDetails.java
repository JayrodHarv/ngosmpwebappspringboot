package com.jayrodharv.ngosmpwebappspringboot.config;

import java.util.Collection;
import java.util.Set;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;

import com.jayrodharv.ngosmpwebappspringboot.dto.RoleDTO;
import com.jayrodharv.ngosmpwebappspringboot.model.Permission;

public class CustomUserDetails extends User {

    private final Integer userId;
    private final Set<Permission> permissions;
    private final Set<RoleDTO> roles;

    public CustomUserDetails(
        String username,
        String password,
        Collection<? extends GrantedAuthority> authorities,
        Integer userId,
        Set<Permission> permissions,
        Set<RoleDTO> roles
    ) {
        super(username, password, authorities);
        this.userId = userId;
        this.permissions = permissions;
        this.roles = roles;
    }

    public Integer getUserId() {
        return userId;
    }

    public Set<RoleDTO> getRoles() {
        return roles;
    }

    public boolean hasPermission(Permission permission) {
        return permissions.contains(permission);
    }

}
