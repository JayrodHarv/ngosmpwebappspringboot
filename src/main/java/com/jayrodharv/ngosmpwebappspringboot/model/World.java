package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;

/** Maps to the World table. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class World {
    private String worldId;
    private LocalDate dateStarted;
    private String description;
}
