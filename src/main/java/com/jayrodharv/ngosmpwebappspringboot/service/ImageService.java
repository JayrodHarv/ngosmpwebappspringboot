package com.jayrodharv.ngosmpwebappspringboot.service;

import com.jayrodharv.ngosmpwebappspringboot.dao.ImageDAO;
import com.jayrodharv.ngosmpwebappspringboot.model.Image;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.Optional;

/**
 * Saves uploaded images to disk and stores metadata in the Image table.
 * The SP de-duplicates by SHA-256 hash, so uploading the same file twice
 * is safe and returns the existing ImageID.
 */
@Service
public class ImageService {

    private final ImageDAO imageDao;
    private final Path uploadRoot;

    public ImageService(ImageDAO imageDao,
                        @Value("${app.upload.dir:./uploads}") String uploadDir) {
        this.imageDao   = imageDao;
        this.uploadRoot = Path.of(uploadDir);
    }

    /** Persist an uploaded file and return the resulting Image record. */
    public Image store(MultipartFile file) throws IOException {
        if (file.isEmpty()) throw new IllegalArgumentException("File must not be empty");

        byte[] bytes = file.getBytes();
        String hash  = sha256Hex(bytes);

        // Save to disk (skip if already stored via hash match, SP handles the rest)
        String original = file.getOriginalFilename();
        String ext      = (original != null && original.contains("."))
                        ? original.substring(original.lastIndexOf('.'))
                        : "";

        Path destination = uploadRoot.resolve(hash + ext).normalize();
        Files.createDirectories(destination.getParent());
        Files.write(destination, bytes, StandardOpenOption.CREATE, StandardOpenOption.WRITE);

        int imageId = imageDao.insertOrGet(
                file.getOriginalFilename(),
                file.getContentType(),
                file.getSize(),
                hash + ext,
                hash);

        Image img = new Image();
        img.setImageId(imageId);
        img.setFileName(file.getOriginalFilename());
        img.setMimeType(file.getContentType());
        img.setFileSize(file.getSize());
        img.setFilePath(hash + ext);
        img.setFileHash(hash);
        return img;
    }

    public Optional<Image> findById(int imageId) {
        return imageDao.findById(imageId);
    }

    public void delete(int imageId) {
        imageDao.findById(imageId).ifPresent(img -> {
            try { Files.deleteIfExists(Path.of(img.getFilePath())); } catch (IOException ignored) {}
            imageDao.deleteById(imageId);
        });
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private String sha256Hex(byte[] data) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(md.digest(data));
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }
}
