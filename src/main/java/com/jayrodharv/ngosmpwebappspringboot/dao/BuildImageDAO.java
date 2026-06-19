package com.jayrodharv.ngosmpwebappspringboot.dao;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import lombok.AllArgsConstructor;

@Repository
@AllArgsConstructor
public class BuildImageDAO {

    private final JdbcTemplate jdbc;
    
    public void create(
        Integer actingUserId,
        Integer buildId,
        Integer imageId,
        Integer sortOrder
    ) {
        SimpleJdbcCall call = new SimpleJdbcCall(jdbc).withProcedureName(
            "sp_add_build_image"
        );
        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_acting_user_id", actingUserId)
            .addValue("p_build_id", buildId)
            .addValue("p_image_id", imageId)
            .addValue("p_sort_order", sortOrder);

        call.execute(params);
    }

    public void deleteByBuildId(
        Integer actingUserId,
        Integer buildId
    ) {
        SimpleJdbcCall call = new SimpleJdbcCall(jdbc).withProcedureName("sp_delete_build_images");

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_acting_user_id", actingUserId)
            .addValue("p_build_id", buildId);

        call.execute(params);
    }
}
