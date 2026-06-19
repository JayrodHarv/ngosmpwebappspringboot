package com.jayrodharv.ngosmpwebappspringboot.dao;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.jayrodharv.ngosmpwebappspringboot.model.Image;

import java.util.List;
import java.util.Optional;

@Repository
public class ImageDAO {

    private final NamedParameterJdbcTemplate jdbc;

    public ImageDAO(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<Image> IMAGE_MAPPER = (rs, rowNum) -> {
        Image img = new Image();
        img.setImageId(rs.getInt("ImageID"));
        img.setFileName(rs.getString("FileName"));
        img.setMimeType(rs.getString("MimeType"));
        img.setFileSize(rs.getLong("FileSize"));
        img.setFilePath(rs.getString("FilePath"));
        img.setCreatedAt(rs.getTimestamp("CreatedAt") != null
                ? rs.getTimestamp("CreatedAt").toLocalDateTime() : null);
        return img;
    };

    public Optional<Image> findById(int imageId) {
        return jdbc.query(
                "CALL sp_get_image(:imageId)",
                new MapSqlParameterSource("imageId", imageId),
                IMAGE_MAPPER).stream().findFirst();
    }

    /**
     * Calls sp_insert_image which de-duplicates by file hash.
     * Returns the ImageID (new or existing).
     */
    public Integer insertOrGet(
        Integer actingUserId,
        String fileName,
        String mimeType,
        long fileSize,
        String filePath,
        String fileHash
    ) {
        MapSqlParameterSource p = new MapSqlParameterSource();
            p.addValue("actingUserId", actingUserId);
            p.addValue("fileName", fileName);
            p.addValue("mimeType", mimeType);
            p.addValue("fileSize", fileSize);
            p.addValue("filePath", filePath);
            p.addValue("fileHash", fileHash);
        List<Integer> ids = jdbc.query(
                "CALL sp_insert_image(:actingUserId,:fileName,:mimeType,:fileSize,:filePath,:fileHash)",
                p, (rs, rowNum) -> rs.getInt("ImageID"));
        return ids.isEmpty() ? -1 : ids.get(0);
    }

    public void deleteById(int imageId) {
        jdbc.update("CALL sp_delete_image(:imageId)",
                new MapSqlParameterSource("imageId", imageId));
    }
}
