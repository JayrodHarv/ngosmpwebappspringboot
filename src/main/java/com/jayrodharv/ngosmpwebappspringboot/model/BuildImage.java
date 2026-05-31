package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/** Maps to the BuildImage junction table. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BuildImage {
    private String buildId;
    private Integer imageId;
    private boolean isPrimary;
    private int sortOrder;
}
