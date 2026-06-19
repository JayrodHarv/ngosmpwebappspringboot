package com.jayrodharv.ngosmpwebappspringboot.dto.build;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import com.jayrodharv.ngosmpwebappspringboot.dto.tag.TagDTO;

public record BuildListDTO(
    Integer buildId,
    String name,
    String description,
    LocalDate dateBuilt,
    Integer xCoord,
    Integer yCoord,
    Integer zCoord,
    LocalDateTime createdAt,
    Integer primaryImageId,
    String primaryImagePath,
    
    // User info
    Integer creatorId,
    String creatorDisplayName,

    // Tags
    List<TagDTO> tags
) {

}
