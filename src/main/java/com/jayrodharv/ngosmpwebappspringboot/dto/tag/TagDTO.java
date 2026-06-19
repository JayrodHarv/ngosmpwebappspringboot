package com.jayrodharv.ngosmpwebappspringboot.dto.tag;

public record TagDTO(
    int tagId,
    String name,
    String description,

    TagTypeDTO tagType
) {
    
}
