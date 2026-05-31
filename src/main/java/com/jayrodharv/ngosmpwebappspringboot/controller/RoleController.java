package com.jayrodharv.ngosmpwebappspringboot.controller;

import com.jayrodharv.ngosmpwebappspringboot.model.Role;
import com.jayrodharv.ngosmpwebappspringboot.service.RoleService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/roles")
@PreAuthorize("hasRole('Admin')")
public class RoleController {

    private final RoleService roleService;

    public RoleController(RoleService roleService) {
        this.roleService = roleService;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("roles", roleService.findAll());
        return "role/list";
    }

    @GetMapping("/{roleId}")
    public String detail(@PathVariable String roleId, Model model) {
        model.addAttribute("role", roleService.findById(roleId).orElseThrow());
        return "role/detail";
    }

    @GetMapping("/new")
    public String newForm(Model model) {
        model.addAttribute("role", new Role());
        return "role/form";
    }

    @PostMapping("/new")
    public String create(@ModelAttribute Role role, RedirectAttributes ra) {
        roleService.create(role);
        ra.addFlashAttribute("success", "Role created!");
        return "redirect:/roles/" + role.getRoleId();
    }

    @GetMapping("/{roleId}/edit")
    public String editForm(@PathVariable String roleId, Model model) {
        model.addAttribute("role",    roleService.findById(roleId).orElseThrow());
        model.addAttribute("oldId",   roleId);
        return "role/form";
    }

    @PostMapping("/{roleId}/edit")
    public String update(@PathVariable String roleId,
                         @ModelAttribute Role role,
                         RedirectAttributes ra) {
        roleService.update(role, roleId);
        ra.addFlashAttribute("success", "Role updated!");
        return "redirect:/roles/" + role.getRoleId();
    }

    @PostMapping("/{roleId}/delete")
    public String delete(@PathVariable String roleId, RedirectAttributes ra) {
        roleService.delete(roleId);
        ra.addFlashAttribute("success", "Role deleted.");
        return "redirect:/roles";
    }
}
