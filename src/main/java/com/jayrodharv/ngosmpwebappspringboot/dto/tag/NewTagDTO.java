package com.jayrodharv.ngosmpwebappspringboot.dto.tag;

public record NewTagDTO(
    String name,
    Integer tagTypeId,
    String description
) {
    
}
