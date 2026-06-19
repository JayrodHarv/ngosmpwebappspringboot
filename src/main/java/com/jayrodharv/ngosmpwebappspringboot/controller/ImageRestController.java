package com.jayrodharv.ngosmpwebappspringboot.controller;

import java.io.IOException;

import org.springframework.security.core.annotation.AuthenticationPrincipal;

import com.jayrodharv.ngosmpwebappspringboot.config.CustomUserDetails;
import com.jayrodharv.ngosmpwebappspringboot.dto.image.UploadImageResponseDTO;
import com.jayrodharv.ngosmpwebappspringboot.service.ImageService;

import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/images")
@AllArgsConstructor
public class ImageRestController {

    private final ImageService imageService;

    @PostMapping("/upload")
    public UploadImageResponseDTO upload(
            @RequestParam MultipartFile file,
            @AuthenticationPrincipal CustomUserDetails actingUser) throws IOException {
        return imageService.uploadImage(actingUser.getUserId(), file);
    }
}
