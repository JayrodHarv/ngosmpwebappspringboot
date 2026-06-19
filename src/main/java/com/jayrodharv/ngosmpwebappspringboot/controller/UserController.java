package com.jayrodharv.ngosmpwebappspringboot.controller;

import com.jayrodharv.ngosmpwebappspringboot.config.CustomUserDetails;
import com.jayrodharv.ngosmpwebappspringboot.dto.user.UserDTO;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageRequest;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageResult;
import com.jayrodharv.ngosmpwebappspringboot.service.UserService;
import java.util.Set;
import lombok.AllArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@AllArgsConstructor
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    @GetMapping
    public String list(
        @RequestParam(defaultValue = "1") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(required = false) String search,
        @RequestParam(required = false) Set<Integer> tags,
        @RequestParam(defaultValue = "true") boolean decending,
        Model model,
        @AuthenticationPrincipal CustomUserDetails actingUser
    ) {
        PageResult<UserDTO> result = userService.getUsers(
            actingUser,
            new PageRequest(page, size, search, tags, decending)
        );

        model.addAttribute("usersListVM", result);
        return "user/list";
    }

    // @GetMapping("/{userId}")
    // public String detail(
    //     @PathVariable String userId,
    //     Model model,
    //     @AuthenticationPrincipal CustomUserDetails actingUser
    // ) {
    //     model.addAttribute("user",  userService.findViewModel(userId).orElseThrow());
    //     model.addAttribute("roles", roleService.findAll());
    //     return "user/detail";
    // }

    // @PostMapping("/{userId}/role")
    // public String assignRole(@PathVariable String userId,
    //                          @RequestParam String roleId,
    //                          RedirectAttributes ra) {
    //     userService.assignRole(userId, roleId);
    //     ra.addFlashAttribute("success", "Role updated.");
    //     return "redirect:/users/" + userId;
    // }

    // @PostMapping("/{userId}/ban")
    // public String ban(
    //     @PathVariable Integer userId,
    //     RedirectAttributes ra,
    //     @AuthenticationPrincipal CustomUserDetails actingUser
    // ) {
    //     userService.banUser(actingUser, userId);
    //     ra.addFlashAttribute("success", "User banned.");
    //     return "redirect:/users/" + userId;
    // }

    // @PostMapping("/{userId}/delete")
    // public String delete(@PathVariable Integer userId, RedirectAttributes ra) {
    //     userService.delete(userId);
    //     ra.addFlashAttribute("success", "User deleted.");
    //     return "redirect:/users";
    // }
}
