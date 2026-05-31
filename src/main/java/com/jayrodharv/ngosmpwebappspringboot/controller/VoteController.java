package com.jayrodharv.ngosmpwebappspringboot.controller;

import com.jayrodharv.ngosmpwebappspringboot.model.Vote;
import com.jayrodharv.ngosmpwebappspringboot.model.VoteOption;
import com.jayrodharv.ngosmpwebappspringboot.service.VoteService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;

@Controller
@RequestMapping("/votes")
public class VoteController {

    private final VoteService voteService;

    public VoteController(VoteService voteService) {
        this.voteService = voteService;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("activeVotes",    voteService.findActive());
        model.addAttribute("concludedVotes", voteService.findConcluded());
        return "vote/list";
    }

    @GetMapping("/{voteId}")
    public String detail(@PathVariable String voteId,
                         @AuthenticationPrincipal UserDetails principal,
                         Model model) {
        Vote vote = voteService.findById(voteId)
                .orElseThrow(() -> new IllegalArgumentException("Vote not found"));
        model.addAttribute("vote",    vote);
        model.addAttribute("options", voteService.findOptions(voteId));
        return "vote/detail";
    }

    @GetMapping("/new")
    public String newForm() { return "vote/form"; }

    @PostMapping("/new")
    public String create(@RequestParam String voteId,
                         @RequestParam String description,
                         @RequestParam(required = false) String startTime,
                         @RequestParam(required = false) String endTime,
                         @AuthenticationPrincipal UserDetails principal,
                         RedirectAttributes ra) {
        Vote vote = new Vote();
        vote.setVoteId(voteId);
        vote.setUserId(principal.getUsername());
        vote.setDescription(description);
        vote.setStartTime(startTime != null && !startTime.isBlank()
                ? LocalDateTime.parse(startTime) : null);
        vote.setEndTime(endTime != null && !endTime.isBlank()
                ? LocalDateTime.parse(endTime) : null);
        voteService.create(vote);
        ra.addFlashAttribute("success", "Vote created!");
        return "redirect:/votes/" + voteId;
    }

    @PostMapping("/{voteId}/cast")
    public String cast(@PathVariable String voteId,
                       @RequestParam int optionId,
                       @AuthenticationPrincipal UserDetails principal,
                       RedirectAttributes ra) {
        try {
            voteService.cast(principal.getUsername(), voteId, optionId);
            ra.addFlashAttribute("success", "Vote cast!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Could not cast vote: " + e.getMessage());
        }
        return "redirect:/votes/" + voteId;
    }

    @PostMapping("/{voteId}/options/add")
    public String addOption(@PathVariable String voteId,
                            @RequestParam String title,
                            @RequestParam String description,
                            RedirectAttributes ra) {
        VoteOption option = new VoteOption();
        option.setVoteId(voteId);
        option.setTitle(title);
        option.setDescription(description);
        voteService.addOption(option);
        ra.addFlashAttribute("success", "Option added.");
        return "redirect:/votes/" + voteId;
    }

    @PostMapping("/{voteId}/delete")
    public String delete(@PathVariable String voteId, RedirectAttributes ra) {
        voteService.delete(voteId);
        ra.addFlashAttribute("success", "Vote deleted.");
        return "redirect:/votes";
    }
}
