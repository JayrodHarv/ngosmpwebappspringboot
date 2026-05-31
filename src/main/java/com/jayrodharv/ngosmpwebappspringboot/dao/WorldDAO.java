package com.jayrodharv.ngosmpwebappspringboot.dao;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.jayrodharv.ngosmpwebappspringboot.model.World;

import java.util.List;
import java.util.Optional;

@Repository
public class WorldDAO {

    private final NamedParameterJdbcTemplate jdbc;

    public WorldDAO(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<World> WORLD_MAPPER = (rs, rowNum) -> new World(
            rs.getString("WorldID"),
            rs.getDate("DateStarted").toLocalDate(),
            rs.getString("Description")
    );

    public List<World> findAll() {
        return jdbc.query("CALL sp_get_all_worlds()", new MapSqlParameterSource(), WORLD_MAPPER);
    }

    public Optional<World> findById(String worldId) {
        return jdbc.query(
                "CALL sp_get_world(:worldId)",
                new MapSqlParameterSource("worldId", worldId),
                WORLD_MAPPER).stream().findFirst();
    }

    public void insert(World world) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("worldId",     world.getWorldId());
        p.addValue("dateStarted", world.getDateStarted());
        p.addValue("description", world.getDescription());
        jdbc.update("CALL sp_insert_world(:worldId,:dateStarted,:description)", p);
    }

    public void update(World world) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("worldId",     world.getWorldId());
        p.addValue("dateStarted", world.getDateStarted());
        p.addValue("description", world.getDescription());
        jdbc.update("CALL sp_update_world(:worldId,:dateStarted,:description)", p);
    }

    public void deleteById(String worldId) {
        jdbc.update("CALL sp_delete_world(:worldId)",
                new MapSqlParameterSource("worldId", worldId));
    }
}
