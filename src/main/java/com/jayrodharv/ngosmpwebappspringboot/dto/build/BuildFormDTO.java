package com.jayrodharv.ngosmpwebappspringboot.dto.build;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;

import com.jayrodharv.ngosmpwebappspringboot.dto.tag.NewTagDTO;

public record BuildFormDTO(
    String name,
    String description,
    LocalDate dateBuilt,
    Integer xCoord,
    Integer yCoord,
    Integer zCoord,
    Set<Integer> tagIds,
    List<NewTagDTO> newTags,
    List<Integer> imageIds
) {
    
}
