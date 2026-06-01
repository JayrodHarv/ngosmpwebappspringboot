package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VoteOptionVM {
    private Integer optionId;
    private String voteId;
    private String title;
    private String description;
    private Integer imageId;

    // Additional fields for view model
    private int voteCount;

    private Image image;

    // Helper method to check if option has an image
    public boolean hasImage() {
        return imageId != null && image != null;
    }
}
