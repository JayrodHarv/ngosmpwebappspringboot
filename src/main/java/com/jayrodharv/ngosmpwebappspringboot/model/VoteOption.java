package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/** Maps to the VoteOption table. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class VoteOption {
    private Integer optionId;
    private String voteId;
    private String title;
    private String description;
    private Integer imageId;

    // Populated by the SP (number_of_votes count)
    private int numberOfVotes;
}
