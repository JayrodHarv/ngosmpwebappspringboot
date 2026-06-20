package com.jayrodharv.ngosmpwebappspringboot.service;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.jayrodharv.ngosmpwebappspringboot.dto.image.StoredFileDTO;

@Service
public class FileStorageService {

    private final Path uploadRoot;

    public FileStorageService(@Value("${app.upload.dir:./uploads}") String uploadDir) {
        this.uploadRoot = Path.of(uploadDir);
    }

    public StoredFileDTO store(MultipartFile file) throws IOException {
        String hash = calculateHash(file);

        String extension = getExtension(file);

        Path relativePath = buildPath(hash, extension);

        String dbPath = relativePath.toString().replace('\\', '/');

        Path destination = uploadRoot.resolve(relativePath);

        try {
            Files.createDirectories(destination.getParent());
        } catch (IOException e) {
            throw new IOException("Unable to find or create parent directories: " + destination.getParent());
        }

        if (!Files.exists(destination)) {
            try {
                file.transferTo(destination);
            } catch (IllegalStateException | IOException e) {
                throw new IOException("Unable to store file at path: " + destination);
            }
        }

        return new StoredFileDTO(
                file.getOriginalFilename(),
                file.getContentType(),
                file.getSize(),
                dbPath,
                hash);
    }

    private String getExtension(MultipartFile file) {
        String originalName = file.getOriginalFilename();

        if (originalName == null) {
            return "";
        }

        int lastDot = originalName.lastIndexOf('.');

        if (lastDot == -1) {
            return "";
        }

        return originalName.substring(lastDot);
    }

    private Path buildPath(String hash, String extension) {
        return Path.of(
                "images/",
                hash + extension);
    }

    private String calculateHash(MultipartFile file) throws IOException {

        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");

            try (InputStream in = file.getInputStream()) {

                byte[] buffer = new byte[8192];

                int bytesRead;

                while ((bytesRead = in.read(buffer)) != -1) {
                    digest.update(buffer, 0, bytesRead);
                }
            } catch (IOException e) {
                throw new IOException("Unable to produce hash for file");
            }

            return HexFormat.of()
                    .formatHex(digest.digest());

        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(
                    "SHA-256 algorithm unavailable",
                    e);
        }
    }
}
