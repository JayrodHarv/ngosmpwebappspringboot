package com.jayrodharv.ngosmpwebappspringboot.dto.image;

public record ImageDTO(
    Integer imageId,
    String fileName,
    String mimeType,
    long fileSize,
    String filePath
) {
    
}
