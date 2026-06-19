package com.jayrodharv.ngosmpwebappspringboot.exception;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpServletRequest;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ValidationException.class)
    public String handleValidationException(
            ValidationException ex,
            RedirectAttributes ra,
            HttpServletRequest request) {

        ra.addFlashAttribute("errorMessage", ex.getMessage());

        // send user back to previous page
        String referer = request.getHeader("Referer");

        return "redirect:" + (referer != null ? referer : "/");
    }

    @ExceptionHandler(AccessDeniedException.class)
    public String handleAccessDenied(
            AccessDeniedException ex,
            RedirectAttributes ra,
            HttpServletRequest request) {

        ra.addFlashAttribute(
            "errorMessage",
            "You do not have permission to perform that action."
        );

        return "redirect:" +
            request.getHeader("Referer");
    }
    
}
