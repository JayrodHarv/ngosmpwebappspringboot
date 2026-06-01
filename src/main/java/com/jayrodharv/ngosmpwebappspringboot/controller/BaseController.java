package com.jayrodharv.ngosmpwebappspringboot.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.ui.Model;
import jakarta.servlet.http.HttpServletRequest;

public abstract class BaseController {
    
    /**
     * Simple pagination helper - just add page info to model
     */
    protected void addPagination(Model model, Page<?> page, HttpServletRequest request) {
        model.addAttribute("page", page);
        model.addAttribute("currentPage", page.getNumber());
        model.addAttribute("totalPages", page.getTotalPages());
        model.addAttribute("totalItems", page.getTotalElements());
        
        // Keep existing query parameters for pagination links
        String queryString = request.getQueryString();
        if (queryString != null && !queryString.contains("page=")) {
            model.addAttribute("queryString", queryString);
        } else if (queryString != null) {
            // Remove page parameter to avoid duplication
            model.addAttribute("queryString", queryString.replaceAll("&?page=\\d+", ""));
        } else {
            model.addAttribute("queryString", "");
        }
    }
    
    /**
     * Simple Pageable creator with default sorting
     */
    protected Pageable createPageable(HttpServletRequest request, String defaultSort) {
        int page = parseInt(request.getParameter("page"), 0);
        int size = parseInt(request.getParameter("size"), 12);
        String sort = request.getParameter("sort");
        String direction = request.getParameter("dir");
        
        if (sort != null && !sort.isEmpty()) {
            Sort.Direction dir = "desc".equalsIgnoreCase(direction) ? 
                Sort.Direction.DESC : Sort.Direction.ASC;
            return PageRequest.of(page, size, Sort.by(dir, sort));
        }
        
        return PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, defaultSort));
    }
    
    private int parseInt(String value, int defaultValue) {
        if (value == null) return defaultValue;
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}