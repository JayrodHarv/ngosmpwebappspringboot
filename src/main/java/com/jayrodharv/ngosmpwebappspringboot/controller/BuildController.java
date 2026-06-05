package com.jayrodharv.ngosmpwebappspringboot.controller;

import com.jayrodharv.ngosmpwebappspringboot.model.Build;
import com.jayrodharv.ngosmpwebappspringboot.service.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDate;

@Controller
@RequestMapping("/builds")
public class BuildController extends BaseController {

    private final BuildService     buildService;
    private final WorldService     worldService;
    private final BuildTypeService buildTypeService;

    public BuildController(BuildService buildService,
                           WorldService worldService,
                           BuildTypeService buildTypeService) {
        this.buildService     = buildService;
        this.worldService     = worldService;
        this.buildTypeService = buildTypeService;
    }

    // ── LIST ──────────────────────────────────────────────────────────────────

    @GetMapping
    public String list(@RequestParam(defaultValue = "0") int page,
                       @RequestParam(defaultValue = "10") int size,
                       @RequestParam(required = false) String worldId,
                       @RequestParam(required = false) String buildTypeId,
                       @RequestParam(required = false) String displayName,
                       Model model) {
        model.addAttribute("builds",      buildService.findAll(page, size, worldId, buildTypeId, displayName));
        model.addAttribute("worlds",      worldService.findAll());
        model.addAttribute("buildTypes",  buildTypeService.findAll());
        model.addAttribute("page",        page);
        model.addAttribute("worldId",     worldId);
        model.addAttribute("buildTypeId", buildTypeId);
        model.addAttribute("displayName", displayName);
        return "build/list";
    }

    // ── DETAIL ────────────────────────────────────────────────────────────────

    @GetMapping("/{buildId}")
    public String detail(@PathVariable String buildId, Model model) {
        model.addAttribute("build", buildService.findById(buildId)
                .orElseThrow(() -> new IllegalArgumentException("Build not found: " + buildId)));
        return "build/detail";
    }

    // ── CREATE ────────────────────────────────────────────────────────────────

    @GetMapping("/new")
    public String newForm(Model model) {
        model.addAttribute("worlds",     worldService.findAll());
        model.addAttribute("buildTypes", buildTypeService.findAll());
        return "build/form";
    }

    @PostMapping("/new")
    public String create(@RequestParam String buildId,
                         @RequestParam String worldId,
                         @RequestParam String buildTypeId,
                         @RequestParam(required = false) String dateBuilt,
                         @RequestParam(required = false) Integer xCoord,
                         @RequestParam(required = false) Integer yCoord,
                         @RequestParam(required = false) Integer zCoord,
                         @RequestParam String description,
                         @RequestParam(required = false) MultipartFile image,
                         @AuthenticationPrincipal UserDetails principal,
                         RedirectAttributes ra) {
        try {
            Build build = new Build();
            build.setBuildId(buildId);
            build.setUserId(principal.getUsername());
            build.setWorldId(worldId);
            build.setBuildTypeId(buildTypeId);
            build.setDateBuilt(dateBuilt != null && !dateBuilt.isBlank()
                    ? LocalDate.parse(dateBuilt) : null);
            build.setXCoord(xCoord);
            build.setYCoord(yCoord);
            build.setZCoord(zCoord);
            build.setDescription(description);
            buildService.create(build);

            if (image != null && !image.isEmpty()) {
                buildService.addImage(buildId, image, true);
            }

            ra.addFlashAttribute("success", "Build created successfully!");
            return "redirect:/builds/" + buildId;
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Failed to create build: " + e.getMessage());
            return "redirect:/builds/new";
        }
    }

    // ── EDIT ─────────────────────────────────────────────────────────────────

    @GetMapping("/{buildId}/edit")
    public String editForm(@PathVariable String buildId, Model model) {
        model.addAttribute("build",      buildService.findById(buildId)
                .orElseThrow(() -> new IllegalArgumentException("Build not found")));
        model.addAttribute("worlds",     worldService.findAll());
        model.addAttribute("buildTypes", buildTypeService.findAll());
        return "build/form";
    }

    @PostMapping("/{buildId}/edit")
    public String update(@PathVariable String buildId,
                         @RequestParam(required = false) String worldId,
                         @RequestParam(required = false) String buildTypeId,
                         @RequestParam(required = false) String dateBuilt,
                         @RequestParam(required = false) Integer xCoord,
                         @RequestParam(required = false) Integer yCoord,
                         @RequestParam(required = false) Integer zCoord,
                         @RequestParam String description,
                         RedirectAttributes ra) {
        try {
            Build build = new Build();
            build.setBuildId(buildId);
            build.setWorldId(worldId);
            build.setBuildTypeId(buildTypeId);
            build.setDateBuilt(dateBuilt != null && !dateBuilt.isBlank()
                    ? LocalDate.parse(dateBuilt) : null);
            build.setXCoord(xCoord);
            build.setYCoord(yCoord);
            build.setZCoord(zCoord);
            build.setDescription(description);
            buildService.update(build);
            ra.addFlashAttribute("success", "Build updated!");
            return "redirect:/builds/" + buildId;
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Update failed: " + e.getMessage());
            return "redirect:/builds/" + buildId + "/edit";
        }
    }

    // ── DELETE ────────────────────────────────────────────────────────────────

    @PostMapping("/{buildId}/delete")
    public String delete(@PathVariable String buildId, RedirectAttributes ra) {
        buildService.delete(buildId);
        ra.addFlashAttribute("success", "Build deleted.");
        return "redirect:/builds";
    }

    // ── IMAGE UPLOAD ──────────────────────────────────────────────────────────

    @PostMapping("/{buildId}/images/add")
    public String addImage(@PathVariable String buildId,
                           @RequestParam MultipartFile image,
                           @RequestParam(defaultValue = "false") boolean isPrimary,
                           RedirectAttributes ra) {
        try {
            buildService.addImage(buildId, image, isPrimary);
            ra.addFlashAttribute("success", "Image uploaded.");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Image upload failed: " + e.getMessage());
        }
        return "redirect:/builds/" + buildId;
    }

    @PostMapping("/{buildId}/images/{imageId}/remove")
    public String removeImage(@PathVariable String buildId,
                              @PathVariable int imageId,
                              RedirectAttributes ra) {
        buildService.removeImage(buildId, imageId);
        ra.addFlashAttribute("success", "Image removed.");
        return "redirect:/builds/" + buildId;
    }
}
