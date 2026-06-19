package com.jayrodharv.ngosmpwebappspringboot.service;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import com.jayrodharv.ngosmpwebappspringboot.config.CustomUserDetails;
import com.jayrodharv.ngosmpwebappspringboot.model.Permission;

@Service
public class AuthorizationService {

    public void requirePermission(
            CustomUserDetails user,
            Permission permission) {

        if (!user.hasPermission(permission)) {
            throw new AccessDeniedException(
                "Missing permission: " + permission
            );
        }
    }

    public void requireOwnOrAll(
            CustomUserDetails user,
            Permission ownPermission,
            Permission allPermission,
            boolean isOwner) {

        if (user.hasPermission(allPermission)) {
            return;
        }

        if (isOwner && user.hasPermission(ownPermission)) {
            return;
        }

        throw new AccessDeniedException(
            "Insufficient permissions"
        );
    }
}