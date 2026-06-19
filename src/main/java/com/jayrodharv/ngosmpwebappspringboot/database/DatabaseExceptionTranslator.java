package com.jayrodharv.ngosmpwebappspringboot.database;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Component;

import com.jayrodharv.ngosmpwebappspringboot.exception.ValidationException;

@Component
public class DatabaseExceptionTranslator {

    public ValidationException translate(DataIntegrityViolationException ex) {

        String message = ex.getMostSpecificCause().getMessage();

        // MySQL/MariaDB unique constraint violations usually contain the index name
        if (message.contains("uq_user_email")) {
            return new ValidationException("email", "Email is already in use.");
        }

        if (message.contains("uq_user_display_name")) {
            return new ValidationException("displayName", "Display name is already in use.");
        }

        // fallback
        return new ValidationException("general", "A database error occurred.");
    }
}
