package com.jayrodharv.ngosmpwebappspringboot.controller;

import com.jayrodharv.ngosmpwebappspringboot.model.World;
import com.jayrodharv.ngosmpwebappspringboot.service.WorldService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;

@Controller
@RequestMapping("/worlds")
public class WorldController {

    private final WorldService worldService;

    public WorldController(WorldService worldService) {
        this.worldService = worldService;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("worlds", worldService.findAll());
        return "world/list";
    }

    @GetMapping("/{worldId}")
    public String detail(@PathVariable String worldId, Model model) {
        model.addAttribute("world", worldService.findById(worldId)
                .orElseThrow(() -> new IllegalArgumentException("World not found")));
        return "world/detail";
    }

    @GetMapping("/new")
    @PreAuthorize("hasRole('Admin')")
    public String newForm() { return "world/form"; }

    @PostMapping("/new")
    @PreAuthorize("hasRole('Admin')")
    public String create(@RequestParam String worldId,
                         @RequestParam String dateStarted,
                         @RequestParam String description,
                         RedirectAttributes ra) {
        worldService.create(new World(worldId, LocalDate.parse(dateStarted), description));
        ra.addFlashAttribute("success", "World created!");
        return "redirect:/worlds/" + worldId;
    }

    @GetMapping("/{worldId}/edit")
    @PreAuthorize("hasRole('Admin')")
    public String editForm(@PathVariable String worldId, Model model) {
        model.addAttribute("world", worldService.findById(worldId).orElseThrow());
        return "world/form";
    }

    @PostMapping("/{worldId}/edit")
    @PreAuthorize("hasRole('Admin')")
    public String update(@PathVariable String worldId,
                         @RequestParam String dateStarted,
                         @RequestParam String description,
                         RedirectAttributes ra) {
        worldService.update(new World(worldId, LocalDate.parse(dateStarted), description));
        ra.addFlashAttribute("success", "World updated!");
        return "redirect:/worlds/" + worldId;
    }

    @PostMapping("/{worldId}/delete")
    @PreAuthorize("hasRole('Admin')")
    public String delete(@PathVariable String worldId, RedirectAttributes ra) {
        worldService.delete(worldId);
        ra.addFlashAttribute("success", "World deleted.");
        return "redirect:/worlds";
    }
}
