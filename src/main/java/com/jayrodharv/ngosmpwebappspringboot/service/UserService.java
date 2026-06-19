package com.jayrodharv.ngosmpwebappspringboot.service;

import com.jayrodharv.ngosmpwebappspringboot.config.CustomUserDetails;
import com.jayrodharv.ngosmpwebappspringboot.dao.UserDAO;
import com.jayrodharv.ngosmpwebappspringboot.dto.RoleDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.user.UserAccountDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.user.UserDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.user.UserLoginDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.user.UserProfileDTO;
import com.jayrodharv.ngosmpwebappspringboot.model.Permission;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageRequest;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageResult;

import lombok.AllArgsConstructor;

import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class UserService implements UserDetailsService {

    private final UserDAO           userDao;
    private final PasswordEncoder   passwordEncoder;
    private final AuthorizationService auth;

    // ─────────────────────────────────────────────
    // SPRING SECURITY
    // ─────────────────────────────────────────────

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {

        UserLoginDTO user = userDao.loginUser(email);

        if (user == null) {
            throw new UsernameNotFoundException("No user found: " + email);
        }

        if ("locked".equalsIgnoreCase(user.status())) {
            throw new LockedException("Account is locked: " + email);
        }

        Integer userId = user.userId();

        // ── LOAD PERMISSIONS (SPRING SECURITY AUTHORITY SOURCE)
        Set<Permission> permissions = userDao.getUserPermissions(userId)
            .stream()
            .map(dto -> Permission.valueOf(dto.name()))
            .collect(Collectors.toSet());

        List<SimpleGrantedAuthority> authorities = 
            permissions.stream()
                .map(p -> new SimpleGrantedAuthority(p.name()))
                .toList();

        Set<RoleDTO> roles = userDao.getUserRoles(userId)
            .stream()
            .collect(Collectors.toSet());

        return new CustomUserDetails(
            email,
            user.passwordHash(),
            authorities,
            userId,
            permissions,
            roles
        );
    }

    // ─────────────────────────────────────────────
    // CRUD (DAO-backed)
    // ─────────────────────────────────────────────

    public Integer register(String email, String displayName, String rawPassword) {
        return userDao.registerUser(
            email,
            displayName,
            passwordEncoder.encode(rawPassword)
        );
    }

    public UserProfileDTO getUserProfile(CustomUserDetails actingUser, Integer userId) {

        UserProfileDTO userProfile = userDao.getUserProfile(actingUser.getUserId(), userId);

        boolean isOwner = actingUser.getUserId() == userProfile.userId();
        
        auth.requireOwnOrAll(
            actingUser,
            Permission.USER_VIEW_PROFILE_OWN,
            Permission.USER_VIEW_PROFILE_ALL,
            isOwner
        );

        return userProfile;
    }

    public UserAccountDTO getUserAccount(CustomUserDetails actingUser, Integer userId) {

        UserAccountDTO userAccount = userDao.getUserAccount(actingUser.getUserId(), userId);

        boolean isOwner = actingUser.getUserId() == userAccount.userId();
        
        auth.requireOwnOrAll(
            actingUser,
            Permission.USER_VIEW_ACCOUNT_OWN,
            Permission.USER_VIEW_ACCOUNT_ALL,
            isOwner
        );

        return userAccount;
    }

    public PageResult<UserDTO> getUsers(CustomUserDetails actingUser, PageRequest request) {

        auth.requirePermission(actingUser, Permission.USER_LIST_VIEW);

        List<UserDTO> users = userDao.getUsers(
            actingUser.getUserId(),
            request
        );

        int totalItems = userDao.countUsers();

        return PageResult.of(
            users,
            request,
            totalItems
        );
    }

    public void updateUser(
        CustomUserDetails actingUser,
        Integer userId,
        String displayName,
        Integer pfpImageId) {

        userDao.updateUser(actingUser.getUserId(), userId, displayName, pfpImageId);
    }

    public void deleteUser(CustomUserDetails actingUser, Integer userId) {
        userDao.deleteUser(actingUser.getUserId(), userId);
    }

    // ─────────────────────────────────────────────
    // BUSINESS ACTIONS
    // ─────────────────────────────────────────────

    public void changePassword(CustomUserDetails actingUser, String email, String rawPassword) {
        // you don’t currently have a DAO method for this
        // either add stored procedure OR extend DAO
        throw new UnsupportedOperationException("Not implemented yet");
    }

    public void banUser(CustomUserDetails actingUser, Integer userId) {
        
        auth.requirePermission(
            actingUser,
            Permission.USER_LOCK
        );

        userDao.banUser(actingUser.getUserId(), userId);
    }
}
