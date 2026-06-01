package com.jayrodharv.ngosmpwebappspringboot.config;

import com.jayrodharv.ngosmpwebappspringboot.service.UserService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Central Spring Security configuration.
 *
 * Route security rules live here. Fine-grained method-level security
 * (e.g. @PreAuthorize) is enabled via @EnableMethodSecurity.
 *
 * Role mapping:
 *   DB RoleID "Admin" → Spring authority ROLE_Admin
 *   DB RoleID "User"  → Spring authority ROLE_User
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    // ── Beans ──────────────────────────────────────────────────────────────────

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public DaoAuthenticationProvider authProvider(UserService userService,
                                                   PasswordEncoder encoder) {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider(userService);
        provider.setPasswordEncoder(encoder);
        return provider;
    }

    // ── HTTP Security ─────────────────────────────────────────────────────────

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                // Public pages
                .requestMatchers("/", "/auth/**", "/css/**", "/js/**", "/images/**",
                                 "/uploads/**", "/error").permitAll()
                // Build listing is public; creation/edit requires login
                .requestMatchers("/builds").permitAll()
                .requestMatchers("/builds/new", "/builds/*/edit",
                                 "/builds/*/images/**").authenticated()

                // Vote listing is public; details/voting requires login
                .requestMatchers("/votes").permitAll()
                .requestMatchers("/votes/*", "/votes/*/vote").authenticated()
                // Admin-only sections
                .requestMatchers("/admin/**", "/roles/**", "/users/**").hasRole("Admin")
                // Everything else requires authentication
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/auth/login")
                .loginProcessingUrl("/auth/login")
                .defaultSuccessUrl("/", true)
                .failureUrl("/auth/login?error=true")
                .permitAll()
            )
            .logout(logout -> logout
                .logoutUrl("/auth/logout")
                .logoutSuccessUrl("/auth/login?logout=true")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
                .permitAll()
            )
            .rememberMe(remember -> remember.key("smp-remember-me-key"))
            .sessionManagement(session -> session
                .maximumSessions(1)
            );

        return http.build();
    }
}
