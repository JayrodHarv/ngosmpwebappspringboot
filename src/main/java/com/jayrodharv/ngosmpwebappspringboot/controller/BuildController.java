package com.jayrodharv.ngosmpwebappspringboot.controller;

import com.jayrodharv.ngosmpwebappspringboot.config.CustomUserDetails;
import com.jayrodharv.ngosmpwebappspringboot.dto.build.BuildListDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.build.BuildFormDTO;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageRequest;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageResult;
import com.jayrodharv.ngosmpwebappspringboot.service.*;

import lombok.AllArgsConstructor;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.Set;

@Controller
@AllArgsConstructor
@RequestMapping("/builds")
public class BuildController extends BaseController {

    private final BuildService buildService;

    @GetMapping
    public String list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Set<Integer> tags,
            @RequestParam(defaultValue = "true") boolean decending,
            Model model) {
        PageResult<BuildListDTO> pageResult = buildService
                .getBuilds(new PageRequest(page, size, search, tags, decending));
        model.addAttribute("pageResult", pageResult);
        model.addAttribute("search", search);

        return "build/list";
    }

    @GetMapping("/{buildId}")
    public String detail(@PathVariable String buildId, Model model) {
        // model.addAttribute("build", buildService.findById(buildId)
        // .orElseThrow(() -> new IllegalArgumentException("Build not found: " +
        // buildId)));
        return "build/detail";
    }

    @PreAuthorize("hasAuthority('BUILD_CREATE')")
    @GetMapping("/new")
    public String newForm(Model model) {
        model.addAttribute(
        "buildForm",
            new BuildFormDTO(
                "",
                "",
                null,
                null,
                null,
                null,
                Set.of(),
                List.of(),
                List.of()
            )
        );
        model.addAttribute(
            "editing",
            false
        );
        return "build/form";
    }

    @PreAuthorize("hasAuthority('BUILD_CREATE')")
    @PostMapping("/new")
    public String create(
            @ModelAttribute("form") BuildFormDTO form,
            @AuthenticationPrincipal CustomUserDetails actingUser,
            RedirectAttributes ra) {
        try {
            Integer buildId = buildService.createBuild(actingUser, form);
            ra.addFlashAttribute("success", "Build created successfully!");
            return "redirect:/builds";
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Failed to create build: " + e.getMessage());
            return "redirect:/builds/new";
        }
    }

    @GetMapping("/{buildId}/edit")
    public String editForm(@PathVariable String buildId, Model model) {

        model.addAttribute(
            "editing",
            true
        );
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
            // Build build = new Build();
            // build.setBuildId(buildId);
            // build.setWorldId(worldId);
            // build.setBuildTypeId(buildTypeId);
            // build.setDateBuilt(dateBuilt != null && !dateBuilt.isBlank()
            // ? LocalDate.parse(dateBuilt) : null);
            // build.setXCoord(xCoord);
            // build.setYCoord(yCoord);
            // build.setZCoord(zCoord);
            // build.setDescription(description);
            // buildService.update(build);
            // ra.addFlashAttribute("success", "Build updated!");
            return "redirect:/builds/" + buildId;
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Update failed: " + e.getMessage());
            return "redirect:/builds/" + buildId + "/edit";
        }
    }

    // ── DELETE ────────────────────────────────────────────────────────────────

    @PostMapping("/{buildId}/delete")
    public String delete(@PathVariable Integer buildId, RedirectAttributes ra) {
        // buildService.delete(buildId);
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
            // buildService.addImage(buildId, image, isPrimary);
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
        // buildService.removeImage(buildId, imageId);
        ra.addFlashAttribute("success", "Image removed.");
        return "redirect:/builds/" + buildId;
    }
}
