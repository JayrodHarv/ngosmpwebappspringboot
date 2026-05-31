package com.jayrodharv.ngosmpwebappspringboot.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Returned by sp_get_builds.
 * Carries all the denormalised columns the stored procedure provides,
 * plus a transient list of all images that gets populated by the service layer.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BuildVM {

    // ── Build ────────────────────────────────────────────────────────────────
    private String buildId;
    private String userId;
    private LocalDate dateBuilt;
    private Integer xCoord;
    private Integer yCoord;
    private Integer zCoord;
    private LocalDateTime createdAt;
    private String buildDescription;

    // ── World ────────────────────────────────────────────────────────────────
    private String worldId;
    private LocalDate worldDateStarted;
    private String worldDescription;

    // ── BuildType ────────────────────────────────────────────────────────────
    private String buildTypeId;
    private String buildTypeDescription;

    // ── Builder (User) ───────────────────────────────────────────────────────
    private String userDisplayName;

    // ── Primary image (from BuildImage + Image join) ─────────────────────────
    private Integer imageId;
    private String fileName;
    private String mimeType;
    private String filePath;

    // ── Full image gallery (populated by service, not by the SP) ─────────────
    private List<Image> images;

    // ── Convenience ──────────────────────────────────────────────────────────
    public boolean hasPrimaryImage() { return imageId != null; }
    public String coordString() {
        if (xCoord == null) return "Unknown";
        return "X:" + xCoord + " Y:" + yCoord + " Z:" + zCoord;
    }
}