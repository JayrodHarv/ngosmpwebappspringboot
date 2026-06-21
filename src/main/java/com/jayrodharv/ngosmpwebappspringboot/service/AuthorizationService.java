package com.jayrodharv.ngosmpwebappspringboot.service;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import com.jayrodharv.ngosmpwebappspringboot.config.CustomUserDetails;
import com.jayrodharv.ngosmpwebappspringboot.model.Permission;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class AuthorizationService {

    public void requirePermission(
            CustomUserDetails user,
            Permission permission) {

        log.info("Checking for '{}' permission from '{}'",
            permission.name(),
            user.getUsername()
        );

        if (!user.hasPermission(permission)) {
            log.warn("Insufficient permissions: User '{}' missing '{}' permission",
                user.getUsername(),
                permission.name()
            );
            throw new AccessDeniedException("Missing permission: " + permission);
        }
        log.info("Suffificient permissions: User '{}' has '{}' permission",
            user.getUsername(),
            permission.name()
        );
    }

    public void requireOwnOrAll(
            CustomUserDetails user,
            Permission ownPermission,
            Permission allPermission,
            boolean isOwner) {

        log.info("Checking for '{}' permission from '{}'",
            allPermission.name(),
            user.getUsername()
        );

        if (user.hasPermission(allPermission)) {
            log.info("Sufficient permissions: User '{}' has '{}' permission",
                user.getUsername(),
                allPermission.name()
            );
            return;
        }

        if (isOwner && user.hasPermission(ownPermission)) {
            log.info("Sufficient permissions: User '{}' is owner and has permission '{}'",
                user.getUsername(),
                ownPermission.name());
            return;
        }

        log.warn("Insufficient permissions: User '{}' is not owner and is missing '{}' permission",
            user.getUsername(),
            allPermission.name()
        );

        throw new AccessDeniedException(
                "Insufficient permissions");
    }
}
