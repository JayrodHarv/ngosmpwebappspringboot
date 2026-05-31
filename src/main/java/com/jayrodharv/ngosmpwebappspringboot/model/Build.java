package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/** Maps to the Build table. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Build {
    private String buildId;
    private String userId;
    private String worldId;
    private String buildTypeId;
    private LocalDate dateBuilt;
    private Integer xCoord;
    private Integer yCoord;
    private Integer zCoord;
    private LocalDateTime createdAt;
    private String description;
}
