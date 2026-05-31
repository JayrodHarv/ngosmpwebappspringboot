package com.jayrodharv.ngosmpwebappspringboot.controller;

import com.jayrodharv.ngosmpwebappspringboot.service.RoleService;
import com.jayrodharv.ngosmpwebappspringboot.service.UserService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/users")
@PreAuthorize("hasRole('Admin')")
public class UserController {

    private final UserService userService;
    private final RoleService roleService;

    public UserController(UserService userService, RoleService roleService) {
        this.userService = userService;
        this.roleService = roleService;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("users", userService.findAll());
        return "user/list";
    }

    @GetMapping("/{userId}")
    public String detail(@PathVariable String userId, Model model) {
        model.addAttribute("user",  userService.findViewModel(userId).orElseThrow());
        model.addAttribute("roles", roleService.findAll());
        return "user/detail";
    }

    @PostMapping("/{userId}/role")
    public String assignRole(@PathVariable String userId,
                             @RequestParam String roleId,
                             RedirectAttributes ra) {
        userService.assignRole(userId, roleId);
        ra.addFlashAttribute("success", "Role updated.");
        return "redirect:/users/" + userId;
    }

    @PostMapping("/{userId}/ban")
    public String ban(@PathVariable String userId, RedirectAttributes ra) {
        userService.ban(userId);
        ra.addFlashAttribute("success", "User banned.");
        return "redirect:/users/" + userId;
    }

    @PostMapping("/{userId}/delete")
    public String delete(@PathVariable String userId, RedirectAttributes ra) {
        userService.delete(userId);
        ra.addFlashAttribute("success", "User deleted.");
        return "redirect:/users";
    }
}
