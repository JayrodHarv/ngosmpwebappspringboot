package com.jayrodharv.ngosmpwebappspringboot.dao;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import com.jayrodharv.ngosmpwebappspringboot.dto.tag.NewTagDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.TagDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.TagTypeDTO;

import lombok.AllArgsConstructor;

@Repository
@AllArgsConstructor
public class TagDAO {

    private final JdbcTemplate jdbc;

    // Build Tags
    public Map<Integer, List<TagDTO>> getTagsForBuilds(List<Integer> buildIds) {

        if (buildIds == null || buildIds.isEmpty()) {
            return Map.of();
        }

        // Package up build ids to send as csv to procedure
        String buildIdsCsv = buildIds.stream()
            .map(String::valueOf)
            .collect(Collectors.joining(","));

        Map<Integer, List<TagDTO>> result = new HashMap<>();

        jdbc.query(
            "CALL sp_get_build_tags(?)",
            rs -> {
                int buildId = rs.getInt("build_id");
                
                TagDTO tag = new TagDTO(
                    rs.getInt("tag_id"),
                    rs.getString("tag_name"),
                    rs.getString("tag_description"),

                    new TagTypeDTO(
                        rs.getInt("tag_type_id"),
                        rs.getString("tag_type_name"),
                        rs.getString("tag_type_description")
                    )
                );

                result
                    .computeIfAbsent(buildId, k -> new ArrayList<>())
                    .add(tag);
            },
            buildIdsCsv
        );

        return result;
    }

    public Integer createOrGetTag(Integer actingUserId, NewTagDTO tag) {

        SimpleJdbcCall call = new SimpleJdbcCall(jdbc).withProcedureName("sp_insert_tag");

        Map<String, Object> result = call.execute(
            new MapSqlParameterSource()
                .addValue("p_acting_user_id", actingUserId)
                .addValue("p_tag_type_id", tag.tagTypeId())
                .addValue("p_name", tag.name())
                .addValue("p_description", tag.description())
        );

        return ((Number) result.get("p_tag_id"))
            .intValue();
    }
    
}
