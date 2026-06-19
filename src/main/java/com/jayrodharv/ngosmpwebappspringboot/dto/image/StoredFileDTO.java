package com.jayrodharv.ngosmpwebappspringboot.dto.image;

public record StoredFileDTO(
    String fileName,
    String mimeType,
    long fileSize,
    String filePath,
    String hash
) {
    
}
