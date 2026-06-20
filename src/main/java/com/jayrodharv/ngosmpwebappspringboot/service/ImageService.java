package com.jayrodharv.ngosmpwebappspringboot.service;

import com.jayrodharv.ngosmpwebappspringboot.dao.ImageDAO;
import com.jayrodharv.ngosmpwebappspringboot.dto.image.StoredFileDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.image.UploadImageResponseDTO;

import lombok.AllArgsConstructor;

import java.io.IOException;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@AllArgsConstructor
public class ImageService {

    private final ImageDAO imageDAO;
    private final FileStorageService fileStorageService;

    public UploadImageResponseDTO uploadImage(Integer actingUserId, MultipartFile file) throws IOException {

        StoredFileDTO stored = fileStorageService.store(file);

        Integer imageId = imageDAO.insertOrGet(
                actingUserId,
                stored.fileName(),
                stored.mimeType(),
                stored.fileSize(),
                stored.filePath(),
                stored.hash());

        return new UploadImageResponseDTO(
                imageId, stored.filePath());
    }
}
