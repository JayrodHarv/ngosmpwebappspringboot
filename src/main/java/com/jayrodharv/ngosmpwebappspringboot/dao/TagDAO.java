package com.jayrodharv.ngosmpwebappspringboot.dao;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import com.jayrodharv.ngosmpwebappspringboot.dto.tag.NewTagDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.TagDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.TagTypeDTO;

@Repository
public class TagDAO {

    private final SimpleJdbcCall findByBuildIdCall;
    private final SimpleJdbcCall findAllCall;
    private final SimpleJdbcCall createCall;
    private final SimpleJdbcCall updateCall;
    private final SimpleJdbcCall deleteCall;

    public TagDAO(DataSource dataSource) {
        JdbcTemplate jdbc = new JdbcTemplate(dataSource);
        jdbc.setResultsMapCaseInsensitive(true);

        this.findByBuildIdCall = new SimpleJdbcCall(jdbc)
            .withProcedureName("sp_build_tag_list")
            .declareParameters(
                new SqlParameter("p_build_id", Types.INTEGER)
            )
            .returningResultSet(
                "tags",
                (rs, rowNum) -> mapTag(rs)
            );

        this.findAllCall = new SimpleJdbcCall(jdbc)
            .withProcedureName("sp_tag_list")
            .returningResultSet(
                "tags",
                (rs, rowNum) -> mapTag(rs)
            );

        this.createCall = new SimpleJdbcCall(jdbc)
            .withProcedureName("sp_tag_create")
            .declareParameters(
                new SqlParameter("p_acting_user_id", Types.INTEGER),
                new SqlParameter("p_tag_type_id", Types.INTEGER),
                new SqlParameter("p_name", Types.VARCHAR),
                new SqlParameter("p_description", Types.VARCHAR),
                new SqlOutParameter("p_tag_id", Types.INTEGER)
            );

        this.updateCall = new SimpleJdbcCall(jdbc)
            .withProcedureName("sp_tag_update")
            .declareParameters(
                new SqlParameter("p_acting_user_id", Types.INTEGER),
                new SqlParameter("p_tag_id", Types.INTEGER),
                new SqlParameter("p_tag_type_id", Types.INTEGER),
                new SqlParameter("p_name", Types.VARCHAR),
                new SqlParameter("p_description", Types.VARCHAR)
            );

        this.deleteCall = new SimpleJdbcCall(jdbc)
            .withProcedureName("sp_tag_delete")
            .declareParameters(
                new SqlParameter("p_acting_user_id", Types.INTEGER),
                new SqlParameter("p_tag_id", Types.INTEGER)
            );
    }

    public List<TagDTO> getTagsByBuildId(Integer buildId) {
        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_build_id", buildId);
        Map<String, Object> result = findByBuildIdCall.execute(params);
        return (List<TagDTO>) result.get("tags");
    }

    public Integer createOrGetTag(Integer actingUserId, NewTagDTO tag) {
        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("p_acting_user_id", actingUserId)
            .addValue("p_tag_type_id", tag.tagTypeId())
            .addValue("p_name", tag.name())
            .addValue("p_description", tag.description());
        Map<String, Object> result = createCall.execute(params);
        return ((Number) result.get("p_tag_id"))
                .intValue();
    }

    private TagDTO mapTag(ResultSet rs) throws SQLException {
        return new TagDTO(
            rs.getInt("tag_id"),
            rs.getString("tag_name"),
            rs.getString("tag_description"),

            new TagTypeDTO(
                rs.getInt("tag_type_id"),
                rs.getString("tag_type_name"),
                rs.getString("tag_type_description"),
                rs.getString("tag_type_color")
            )
        );
    }

}
