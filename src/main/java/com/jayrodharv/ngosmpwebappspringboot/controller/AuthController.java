package com.jayrodharv.ngosmpwebappspringboot.controller;

import com.jayrodharv.ngosmpwebappspringboot.service.UserService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/auth")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/login")
    public String loginPage(@RequestParam(required = false) String error,
                            @RequestParam(required = false) String logout,
                            Model model) {
        if (error  != null) model.addAttribute("error",  "Invalid email or password.");
        if (logout != null) model.addAttribute("logout", "You have been logged out.");
        return "auth/login";
    }

    @GetMapping("/register")
    public String registerPage() {
        return "auth/register";
    }

    @PostMapping("/register")
    public String register(@RequestParam String email,
                           @RequestParam String displayName,
                           @RequestParam String password,
                           @RequestParam String confirmPassword,
                           RedirectAttributes ra) {
        if (!password.equals(confirmPassword)) {
            ra.addFlashAttribute("error", "Passwords do not match.");
            return "redirect:/auth/register";
        }
        try {
            userService.register(email, displayName, password);
            ra.addFlashAttribute("success", "Account created! Please log in.");
            return "redirect:/auth/login";
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Registration failed: " + e.getMessage());
            return "redirect:/auth/register";
        }
    }
}
