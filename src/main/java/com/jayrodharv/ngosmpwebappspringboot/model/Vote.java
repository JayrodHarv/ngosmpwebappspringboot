package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

/** Maps to the Vote table. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Vote {
    private String voteId;
    private String userId;
    private String description;
    private LocalDateTime startTime;
    private LocalDateTime endTime;

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
}
