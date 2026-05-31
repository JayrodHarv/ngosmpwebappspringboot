package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/** Maps to the BuildType table. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BuildType {
    private String buildTypeId;
    private String description;
}
