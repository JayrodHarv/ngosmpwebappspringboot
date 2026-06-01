package com.jayrodharv.ngosmpwebappspringboot.model;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserVoteVM {
    private String userId;
    private String voteId;
    private Integer optionId;
    private LocalDateTime voteTime;

    // User info
    private String displayName;
}
