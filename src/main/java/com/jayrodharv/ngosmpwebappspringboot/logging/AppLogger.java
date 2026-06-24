package com.jayrodharv.ngosmpwebappspringboot.logging;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class AppLogger {

    private static final Logger log = LoggerFactory.getLogger(AppLogger.class);

    public void action(ActivityAction action, String detail) {
        log.info("ACTIVITY | {} | {} | {}", currentUser(), action.name(), detail);
    }

    public void warn(String message) {
        log.warn(message);
    }

    public void warn(String message, Object... args) {
        log.warn(message, args);
    }

    public void error(String message) {
        log.error(message);
    }

    public void error(String message, Throwable cause) {
        log.error(message, cause);
    }

    public void error(String message, Object... args) {
        log.error(message, args);
    }

    private String currentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return (auth != null && auth.isAuthenticated()) ? auth.getName() : "anonymous";
    }
}
