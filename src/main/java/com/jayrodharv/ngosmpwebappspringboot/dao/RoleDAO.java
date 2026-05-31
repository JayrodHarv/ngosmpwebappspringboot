package com.jayrodharv.ngosmpwebappspringboot.dao;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.jayrodharv.ngosmpwebappspringboot.model.Role;

import java.util.List;
import java.util.Optional;

/**
 * Data Access Object for the Role table.
 * All queries are delegated to the stored procedures defined in create_smp_db.sql.
 */
@Repository
public class RoleDAO {

    private final NamedParameterJdbcTemplate jdbc;

    public RoleDAO(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // ── Row Mapper ────────────────────────────────────────────────────────────

    private static final RowMapper<Role> ROLE_MAPPER = (rs, rowNum) -> {
        Role r = new Role();
        r.setRoleId(rs.getString("RoleID"));
        r.setDescription(rs.getString("Description"));
        // Builds
        r.setCanAddBuilds(rs.getBoolean("CanAddBuilds"));
        r.setCanEditAllBuilds(rs.getBoolean("CanEditAllBuilds"));
        r.setCanDeleteAllBuilds(rs.getBoolean("CanDeleteAllBuilds"));
        // BuildTypes
        r.setCanViewBuildTypes(rs.getBoolean("CanViewBuildTypes"));
        r.setCanAddBuildTypes(rs.getBoolean("CanAddBuildTypes"));
        r.setCanEditBuildTypes(rs.getBoolean("CanEditBuildTypes"));
        r.setCanDeleteBuildTypes(rs.getBoolean("CanDeleteBuildTypes"));
        // Worlds
        r.setCanViewWorlds(rs.getBoolean("CanViewWorlds"));
        r.setCanAddWorlds(rs.getBoolean("CanAddWorlds"));
        r.setCanEditWorlds(rs.getBoolean("CanEditWorlds"));
        r.setCanDeleteWorlds(rs.getBoolean("CanDeleteWorlds"));
        // Votes
        r.setCanViewAllVotes(rs.getBoolean("CanViewAllVotes"));
        r.setCanAddVotes(rs.getBoolean("CanAddVotes"));
        r.setCanEditAllVotes(rs.getBoolean("CanEditAllVotes"));
        r.setCanDeleteAllVotes(rs.getBoolean("CanDeleteAllVotes"));
        // Roles
        r.setCanViewRoles(rs.getBoolean("CanViewRoles"));
        r.setCanAddRoles(rs.getBoolean("CanAddRoles"));
        r.setCanEditRoles(rs.getBoolean("CanEditRoles"));
        r.setCanDeleteRoles(rs.getBoolean("CanDeleteRoles"));
        // Users
        r.setCanViewUsers(rs.getBoolean("CanViewUsers"));
        r.setCanAddUsers(rs.getBoolean("CanAddUsers"));
        r.setCanEditUsers(rs.getBoolean("CanEditUsers"));
        r.setCanBanUsers(rs.getBoolean("CanBanUsers"));
        return r;
    };

    // ── CRUD ──────────────────────────────────────────────────────────────────

    public List<Role> findAll() {
        return jdbc.query("CALL sp_get_all_roles()", new MapSqlParameterSource(), ROLE_MAPPER);
    }

    public Optional<Role> findById(String roleId) {
        List<Role> results = jdbc.query(
                "CALL sp_get_role(:roleId)",
                new MapSqlParameterSource("roleId", roleId),
                ROLE_MAPPER);
        return results.stream().findFirst();
    }

    public void insert(Role role) {
        jdbc.update("CALL sp_insert_role(:roleId,:canAddBuilds,:canEditAllBuilds,:canDeleteAllBuilds," +
                        ":canViewBuildTypes,:canAddBuildTypes,:canEditBuildTypes,:canDeleteBuildTypes," +
                        ":canViewWorlds,:canAddWorlds,:canEditWorlds,:canDeleteWorlds," +
                        ":canViewAllVotes,:canAddVotes,:canEditAllVotes,:canDeleteAllVotes," +
                        ":canViewRoles,:canAddRoles,:canEditRoles,:canDeleteRoles," +
                        ":canViewUsers,:canAddUsers,:canEditUsers,:canBanUsers,:description)",
                buildParams(role, null));
    }

    public void update(Role role, String oldRoleId) {
        jdbc.update("CALL sp_update_role(:roleId,:canAddBuilds,:canEditAllBuilds,:canDeleteAllBuilds," +
                        ":canViewBuildTypes,:canAddBuildTypes,:canEditBuildTypes,:canDeleteBuildTypes," +
                        ":canViewWorlds,:canAddWorlds,:canEditWorlds,:canDeleteWorlds," +
                        ":canViewAllVotes,:canAddVotes,:canEditAllVotes,:canDeleteAllVotes," +
                        ":canViewRoles,:canAddRoles,:canEditRoles,:canDeleteRoles," +
                        ":canViewUsers,:canAddUsers,:canEditUsers,:canBanUsers,:description,:oldRoleId)",
                buildParams(role, oldRoleId));
    }

    public void deleteById(String roleId) {
        jdbc.update("CALL sp_delete_role(:roleId)",
                new MapSqlParameterSource("roleId", roleId));
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private MapSqlParameterSource buildParams(Role r, String oldRoleId) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("roleId",               r.getRoleId());
        p.addValue("canAddBuilds",         r.isCanAddBuilds());
        p.addValue("canEditAllBuilds",     r.isCanEditAllBuilds());
        p.addValue("canDeleteAllBuilds",   r.isCanDeleteAllBuilds());
        p.addValue("canViewBuildTypes",    r.isCanViewBuildTypes());
        p.addValue("canAddBuildTypes",     r.isCanAddBuildTypes());
        p.addValue("canEditBuildTypes",    r.isCanEditBuildTypes());
        p.addValue("canDeleteBuildTypes",  r.isCanDeleteBuildTypes());
        p.addValue("canViewWorlds",        r.isCanViewWorlds());
        p.addValue("canAddWorlds",         r.isCanAddWorlds());
        p.addValue("canEditWorlds",        r.isCanEditWorlds());
        p.addValue("canDeleteWorlds",      r.isCanDeleteWorlds());
        p.addValue("canViewAllVotes",      r.isCanViewAllVotes());
        p.addValue("canAddVotes",          r.isCanAddVotes());
        p.addValue("canEditAllVotes",      r.isCanEditAllVotes());
        p.addValue("canDeleteAllVotes",    r.isCanDeleteAllVotes());
        p.addValue("canViewRoles",         r.isCanViewRoles());
        p.addValue("canAddRoles",          r.isCanAddRoles());
        p.addValue("canEditRoles",         r.isCanEditRoles());
        p.addValue("canDeleteRoles",       r.isCanDeleteRoles());
        p.addValue("canViewUsers",         r.isCanViewUsers());
        p.addValue("canAddUsers",          r.isCanAddUsers());
        p.addValue("canEditUsers",         r.isCanEditUsers());
        p.addValue("canBanUsers",          r.isCanBanUsers());
        p.addValue("description",          r.getDescription());
        if (oldRoleId != null) p.addValue("oldRoleId", oldRoleId);
        return p;
    }
}
