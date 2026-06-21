package com.jayrodharv.ngosmpwebappspringboot.service;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.jayrodharv.ngosmpwebappspringboot.config.CustomUserDetails;

@Service
public class CurrentUserService {

    public CustomUserDetails getCurrentUser() {

        Authentication auth =
            SecurityContextHolder
                .getContext()
                .getAuthentication();

        return (CustomUserDetails) auth.getPrincipal();
    }

    public Integer getCurrentUserId() {
        return getCurrentUser().getUserId();
    }

    public String getUsername() {
        return getCurrentUser().getUsername();
    }
}
