package com.jayrodharv.ngosmpwebappspringboot.controller;

import com.jayrodharv.ngosmpwebappspringboot.model.Vote;
import com.jayrodharv.ngosmpwebappspringboot.model.VoteOption;
import com.jayrodharv.ngosmpwebappspringboot.model.VoteVM;
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
    private final int PAGE_SIZE = 10;

    public VoteController(VoteService voteService) {
        this.voteService = voteService;
    }

     @GetMapping
    public String list(
            @RequestParam(defaultValue = "active") String tab,
            @RequestParam(defaultValue = "1") int page,
            @AuthenticationPrincipal UserDetails principal,
            Model model) {
        
        String userId = principal != null ? principal.getUsername() : null;
        
        switch (tab) {
            case "active":
                int totalActive = voteService.countActiveVotes();
                int activeTotalPages = (int) Math.ceil((double) totalActive / PAGE_SIZE);
                model.addAttribute("votes", voteService.findActiveVotes(page, PAGE_SIZE));
                model.addAttribute("totalPages", activeTotalPages);
                model.addAttribute("totalItems", totalActive);
                model.addAttribute("currentTab", "active");
                break;
                
            case "pending":
                int totalPending = voteService.countPendingVotes();
                int pendingTotalPages = (int) Math.ceil((double) totalPending / PAGE_SIZE);
                model.addAttribute("votes", voteService.findPendingVotes(userId, page, PAGE_SIZE));
                model.addAttribute("totalPages", pendingTotalPages);
                model.addAttribute("totalItems", totalPending);
                model.addAttribute("currentTab", "pending");
                break;
                
            case "concluded":
                int totalConcluded = voteService.countConcludedVotes();
                int concludedTotalPages = (int) Math.ceil((double) totalConcluded / PAGE_SIZE);
                model.addAttribute("votes", voteService.findConcludedVotes(page, PAGE_SIZE));
                model.addAttribute("totalPages", concludedTotalPages);
                model.addAttribute("totalItems", totalConcluded);
                model.addAttribute("currentTab", "concluded");
                break;
                
            case "drafts":
                if (userId != null) {
                    int totalDrafts = voteService.countDraftVotes(userId);
                    model.addAttribute("votes", voteService.findDraftVotes(userId, page, PAGE_SIZE));
                    model.addAttribute("totalItems", totalDrafts);
                    model.addAttribute("currentTab", "drafts");
                }
                break;
        }
        
        model.addAttribute("currentPage", page);
        model.addAttribute("pageSize", PAGE_SIZE);
        return "vote/list";
    }

    @GetMapping("/{voteId}")
    public String detail(@PathVariable String voteId,
                         @AuthenticationPrincipal UserDetails principal,
                         Model model) {
        VoteVM vote = voteService.findById(voteId);
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
