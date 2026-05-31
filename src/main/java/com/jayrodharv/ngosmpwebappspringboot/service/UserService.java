package com.jayrodharv.ngosmpwebappspringboot.service;

import com.jayrodharv.ngosmpwebappspringboot.dao.UserDAO;
import com.jayrodharv.ngosmpwebappspringboot.model.User;
import com.jayrodharv.ngosmpwebappspringboot.model.UserVM;

import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Handles user lifecycle operations and implements UserDetailsService
 * so Spring Security can authenticate against the smpdb User table.
 */
@Service
public class UserService implements UserDetailsService {

    private final UserDAO       userDao;
    private final PasswordEncoder encoder;

    public UserService(UserDAO userDao, PasswordEncoder encoder) {
        this.userDao = userDao;
        this.encoder = encoder;
    }

    // ── Spring Security ───────────────────────────────────────────────────────

    /**
     * Called by Spring Security on every login attempt.
     * Loads the user by email (UserID), wraps their RoleID as a granted authority.
     */
    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userDao.findById(email)
                .orElseThrow(() -> new UsernameNotFoundException("No user: " + email));

        if (user.isLocked()) {
            throw new LockedException("Account is locked: " + email);
        }

        return org.springframework.security.core.userdetails.User
                .withUsername(user.getUserId())
                .password(user.getPassword())
                .authorities(new SimpleGrantedAuthority("ROLE_" + user.getRoleId()))
                .accountLocked(user.isLocked())
                .disabled(user.isInactive())
                .build();
    }

    // ── CRUD ──────────────────────────────────────────────────────────────────

    public List<User> findAll() { return userDao.findAll(); }

    public Optional<User> findById(String userId) { return userDao.findById(userId); }

    public Optional<UserVM> findViewModel(String userId) {
        return userDao.findViewModelById(userId);
    }

    public void register(String email, String displayName, String rawPassword) {
        userDao.insert(email, encoder.encode(rawPassword), displayName);
    }

    public void update(User user) { userDao.update(user); }

    public void changePassword(String userId, String rawPassword) {
        userDao.updatePassword(userId, encoder.encode(rawPassword));
    }

    public void assignRole(String userId, String roleId) {
        userDao.updateRole(userId, roleId);
    }

    public void ban(String userId) {
        userDao.findById(userId).ifPresent(u -> {
            u.setStatus("locked");
            userDao.update(u);
        });
    }

    public void delete(String userId) { userDao.deleteById(userId); }

    /** Stamp the last-logged-in time after successful auth. */
    public void recordLogin(String userId) {
        userDao.findById(userId).ifPresent(u -> {
            u.setLastLoggedIn(LocalDateTime.now());
            userDao.update(u);
        });
    }
}
