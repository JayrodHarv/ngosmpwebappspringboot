package com.jayrodharv.ngosmpwebappspringboot.dao;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.jayrodharv.ngosmpwebappspringboot.model.BuildType;

import java.util.List;
import java.util.Optional;

@Repository
public class BuildTypeDAO {

    private final NamedParameterJdbcTemplate jdbc;

    public BuildTypeDAO(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<BuildType> BT_MAPPER = (rs, rowNum) ->
            new BuildType(rs.getString("BuildTypeID"), rs.getString("Description"));

    public List<BuildType> findAll() {
        return jdbc.query("CALL sp_get_all_buildtypes()", new MapSqlParameterSource(), BT_MAPPER);
    }

    public Optional<BuildType> findById(String id) {
        return jdbc.query(
                "CALL sp_get_buildtype(:id)",
                new MapSqlParameterSource("id", id),
                BT_MAPPER).stream().findFirst();
    }

    public void insert(BuildType bt) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("id",          bt.getBuildTypeId());
        p.addValue("description", bt.getDescription());
        jdbc.update("CALL sp_insert_buildtype(:id,:description)", p);
    }

    public void update(BuildType bt, String oldId) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("id",          bt.getBuildTypeId());
        p.addValue("description", bt.getDescription());
        p.addValue("oldId",       oldId);
        jdbc.update("CALL sp_update_buildtype(:id,:description,:oldId)", p);
    }

    public void deleteById(String id) {
        jdbc.update("CALL sp_delete_buildtype(:id)",
                new MapSqlParameterSource("id", id));
    }
}
