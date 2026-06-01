package com.jayrodharv.ngosmpwebappspringboot.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;

import org.springframework.boot.webmvc.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class GenericErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {
        // Get error status code
        Object statusCodeAttr = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        Object errorMessageAttr = request.getAttribute(RequestDispatcher.ERROR_MESSAGE);
        
        int statusCode = 500;
        if (statusCodeAttr != null) {
            statusCode = Integer.parseInt(statusCodeAttr.toString());
        }
        
        // Get HTTP status reason
        HttpStatus httpStatus = HttpStatus.resolve(statusCode);
        String errorType = httpStatus != null ? httpStatus.getReasonPhrase() : "Unknown Error";
        
        // Get error message
        String errorMessage = errorMessageAttr != null ? errorMessageAttr.toString() : 
                              "An unexpected error occurred while processing your request.";
        
        model.addAttribute("errorType", errorType);
        model.addAttribute("errorMessage", errorMessage);
        model.addAttribute("statusCode", statusCode);
        
        return "error/generic";
    }
}
