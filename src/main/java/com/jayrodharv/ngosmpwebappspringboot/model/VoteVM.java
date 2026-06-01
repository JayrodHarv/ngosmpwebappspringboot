package com.jayrodharv.ngosmpwebappspringboot.model;

import java.time.LocalDateTime;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VoteVM {
    // Vote fields
    private String voteId;
    private String userId;
    private String description;
    private LocalDateTime startTime;
    private LocalDateTime endTime;

    // User
    private String displayName;

    private int totalOptions;
    private int totalVotes;

    private List<VoteOptionVM> options;
    private List<UserVoteVM> userVotes;

    public boolean isActive() {
        if (startTime == null || endTime == null) return false;
        LocalDateTime now = LocalDateTime.now();
        return now.isAfter(startTime) && now.isBefore(endTime);
    }
    public boolean isConcluded() {
        return endTime != null && LocalDateTime.now().isAfter(endTime);
    }
    public boolean isPending() {
        return startTime == null || LocalDateTime.now().isBefore(startTime);
    }
    public boolean isDraft() {
        return startTime == null && endTime == null;
    }
}
