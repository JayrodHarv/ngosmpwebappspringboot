package com.jayrodharv.ngosmpwebappspringboot.dao;

import com.jayrodharv.ngosmpwebappspringboot.dto.build.BuildFormDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.build.BuildListDTO;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageRequest;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageResult;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import lombok.AllArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

@Repository
@AllArgsConstructor
public class BuildDAO {

    private final JdbcTemplate jdbc;

    public PageResult<BuildListDTO> getBuilds(PageRequest request) {
        AtomicInteger resultCount = new AtomicInteger();

        List<BuildListDTO> builds = jdbc.query(
            "CALL sp_get_builds(?, ?, ?, ?)",
            (rs, rowNum) -> {
                if (rowNum == 0) {
                    resultCount.set(rs.getInt("total_count"));
                }

                return new BuildListDTO(
                    rs.getInt("build_id"),
                    rs.getString("name"),
                    rs.getString("description"),
                    rs.getDate("date_built") == null
                        ? null
                        : rs.getDate("date_built").toLocalDate(),
                    rs.getObject("x_coord", Integer.class),
                    rs.getObject("y_coord", Integer.class),
                    rs.getObject("z_coord", Integer.class),
                    rs.getTimestamp("created_at").toLocalDateTime(),
                    rs.getInt("primary_image_id"),
                    rs.getString("primary_image_path"),

                    rs.getInt("created_by"),
                    rs.getString("creator_display_name"),

                    List.of()
                );
            },

            request.search(),
            request.descending(),
            request.size(),
            request.offset()
        );

        return PageResult.of(builds, request, resultCount.get());
    }

    // getBuild

    public Integer createBuild(Integer actingUserId, BuildFormDTO dto) {
        SimpleJdbcCall call = new SimpleJdbcCall(jdbc).withProcedureName(
            "sp_insert_build"
        );

        Map<String, Object> result = call.execute(
            new MapSqlParameterSource()
                .addValue("p_acting_user_id", actingUserId)
                .addValue("p_name", dto.name())
                .addValue("p_description", dto.description())
                .addValue("p_date_built", dto.dateBuilt())
                .addValue("p_x_coord", dto.xCoord())
                .addValue("p_y_coord", dto.yCoord())
                .addValue("p_z_coord", dto.zCoord())
        );

        return ((Number) result.get("p_build_id")).intValue();
    }

    public void addBuildTag(
        Integer actingUserId,
        Integer buildId,
        Integer tagId
    ) {
        SimpleJdbcCall call = new SimpleJdbcCall(jdbc).withProcedureName(
            "sp_add_build_tag"
        );

        call.execute(
            new MapSqlParameterSource()
                .addValue("p_acting_user_id", actingUserId)
                .addValue("p_build_id", buildId)
                .addValue("p_tag_id", tagId)
        );
    }
}
