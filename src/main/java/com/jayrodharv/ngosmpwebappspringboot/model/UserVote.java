package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

/** Maps to the UserVote table. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserVote {
    private String userId;
    private String voteId;
    private Integer optionId;
    private LocalDateTime voteTime;
}
