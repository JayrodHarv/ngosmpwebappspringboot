package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

/**
 * Maps to the Image table.
 * Images are stored on disk; this record holds metadata + path.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Image {

    private Integer imageId;
    private String fileName;
    private String mimeType;
    private long fileSize;
    private String filePath;
    private LocalDateTime createdAt;
    private String fileHash;
}
