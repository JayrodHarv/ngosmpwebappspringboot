package com.jayrodharv.ngosmpwebappspringboot.dao;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.jayrodharv.ngosmpwebappspringboot.model.Build;
import com.jayrodharv.ngosmpwebappspringboot.model.BuildVM;
import com.jayrodharv.ngosmpwebappspringboot.model.Image;

import java.util.List;
import java.util.Optional;

@Repository
public class BuildDAO {

    private final NamedParameterJdbcTemplate jdbc;

    public BuildDAO(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // ── Row Mappers ───────────────────────────────────────────────────────────

    private static final RowMapper<BuildVM> BUILD_VM_MAPPER = (rs, rowNum) -> {
        BuildVM b = new BuildVM();
        b.setBuildId(rs.getString("BuildID"));
        b.setUserId(rs.getString("UserID"));
        b.setDateBuilt(rs.getDate("DateBuilt") != null
                ? rs.getDate("DateBuilt").toLocalDate() : null);
        b.setXCoord(rs.getObject("XCoord", Integer.class));
        b.setYCoord(rs.getObject("YCoord", Integer.class));
        b.setZCoord(rs.getObject("ZCoord", Integer.class));
        b.setCreatedAt(rs.getTimestamp("CreatedAt") != null
                ? rs.getTimestamp("CreatedAt").toLocalDateTime() : null);
        b.setBuildDescription(rs.getString("build_desc"));
        // World
        b.setWorldId(rs.getString("WorldID"));
        b.setWorldDateStarted(rs.getDate("DateStarted") != null
                ? rs.getDate("DateStarted").toLocalDate() : null);
        b.setWorldDescription(rs.getString("world_desc"));
        // BuildType
        b.setBuildTypeId(rs.getString("BuildTypeID"));
        b.setBuildTypeDescription(rs.getString("buildtype_desc"));
        // User
        b.setUserDisplayName(rs.getString("UserDisplayName"));
        // Primary image
        b.setImageId(rs.getObject("ImageID", Integer.class));
        b.setFileName(rs.getString("FileName"));
        b.setMimeType(rs.getString("MimeType"));
        b.setFilePath(rs.getString("FilePath"));
        return b;
    };

    private static final RowMapper<Image> IMAGE_MAPPER = (rs, rowNum) -> {
        Image img = new Image();
        img.setImageId(rs.getObject("ImageID", Integer.class));
        img.setFileName(rs.getString("FileName"));
        img.setMimeType(rs.getString("MimeType"));
        img.setFilePath(rs.getString("FilePath"));
        img.setFileSize(rs.getLong("FileSize"));
        return img;
    };

    // ── Queries ───────────────────────────────────────────────────────────────

    /**
     * Paginated/filtered build list.
     * Pass null for any filter to skip it (the SP handles NULLs as wildcards).
     */
    public List<BuildVM> findAll(int limit, int offset,
                                        String worldId, String buildTypeId,
                                        String userDisplayName) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("limit",           limit);
        p.addValue("offset",          offset);
        p.addValue("worldId",         worldId);
        p.addValue("buildTypeId",     buildTypeId);
        p.addValue("userDisplayName", userDisplayName);
        return jdbc.query(
                "CALL sp_get_builds(:limit,:offset,:worldId,:buildTypeId,:userDisplayName)",
                p, BUILD_VM_MAPPER);
    }

    public Optional<BuildVM> findById(String buildId) {
        List<BuildVM> results = jdbc.query(
                "CALL sp_get_build(:buildId)",
                new MapSqlParameterSource("buildId", buildId),
                BUILD_VM_MAPPER);
        return results.stream().findFirst();
    }

    public List<BuildVM> findByUser(String userId) {
        return jdbc.query(
                "CALL sp_get_builds_by_user(:userId)",
                new MapSqlParameterSource("userId", userId),
                BUILD_VM_MAPPER);
    }

    public void insert(Build build) {
        jdbc.update(
                "CALL sp_insert_build(:buildId,:userId,:worldId,:buildTypeId,:dateBuilt,:x,:y,:z,:description)",
                buildParams(build));
    }

    public void update(Build build) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("buildId",     build.getBuildId());
        p.addValue("worldId",     build.getWorldId());
        p.addValue("buildTypeId", build.getBuildTypeId());
        p.addValue("dateBuilt",   build.getDateBuilt());
        p.addValue("x",           build.getXCoord());
        p.addValue("y",           build.getYCoord());
        p.addValue("z",           build.getZCoord());
        p.addValue("description", build.getDescription());
        jdbc.update("CALL sp_update_build(:buildId,:worldId,:buildTypeId,:dateBuilt,:x,:y,:z,:description)", p);
    }

    public void deleteById(String buildId) {
        jdbc.update("CALL sp_delete_build(:buildId)",
                new MapSqlParameterSource("buildId", buildId));
    }

    // ── Build Images ──────────────────────────────────────────────────────────

    public List<Image> findImages(String buildId) {
        return jdbc.query(
                "CALL sp_get_build_images(:buildId)",
                new MapSqlParameterSource("buildId", buildId),
                IMAGE_MAPPER);
    }

    public void addImage(String buildId, int imageId, boolean isPrimary, int sortOrder) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("buildId",   buildId);
        p.addValue("imageId",   imageId);
        p.addValue("isPrimary", isPrimary);
        p.addValue("sortOrder", sortOrder);
        jdbc.update("CALL sp_insert_build_image(:buildId,:imageId,:isPrimary,:sortOrder)", p);
    }

    public void removeImage(String buildId, int imageId) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("buildId", buildId);
        p.addValue("imageId", imageId);
        jdbc.update("CALL sp_delete_build_image(:buildId,:imageId)", p);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private MapSqlParameterSource buildParams(Build b) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("buildId",     b.getBuildId());
        p.addValue("userId",      b.getUserId());
        p.addValue("worldId",     b.getWorldId());
        p.addValue("buildTypeId", b.getBuildTypeId());
        p.addValue("dateBuilt",   b.getDateBuilt());
        p.addValue("x",           b.getXCoord());
        p.addValue("y",           b.getYCoord());
        p.addValue("z",           b.getZCoord());
        p.addValue("description", b.getDescription());
        return p;
    }
}
