package com.jayrodharv.ngosmpwebappspringboot.dao;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.jayrodharv.ngosmpwebappspringboot.model.User;
import com.jayrodharv.ngosmpwebappspringboot.model.UserVM;

import java.util.List;
import java.util.Optional;

@Repository
public class UserDAO {

    private final NamedParameterJdbcTemplate jdbc;

    public UserDAO(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // ── Row Mappers ───────────────────────────────────────────────────────────

    private static final RowMapper<User> USER_MAPPER = (rs, rowNum) -> {
        User u = new User();
        u.setUserId(rs.getString("UserID"));
        u.setDisplayName(rs.getString("DisplayName"));
        u.setPassword(rs.getString("Password"));
        u.setLanguage(rs.getString("Language"));
        u.setStatus(rs.getString("Status"));
        u.setRoleId(rs.getString("RoleID"));
        u.setCreatedAt(rs.getTimestamp("CreatedAt") != null
                ? rs.getTimestamp("CreatedAt").toLocalDateTime() : null);
        u.setLastLoggedIn(rs.getTimestamp("LastLoggedIn") != null
                ? rs.getTimestamp("LastLoggedIn").toLocalDateTime() : null);
        u.setUpdatedAt(rs.getTimestamp("UpdatedAt") != null
                ? rs.getTimestamp("UpdatedAt").toLocalDateTime() : null);
        u.setPfpImageId(rs.getObject("PfpImageID", Integer.class));
        return u;
    };

    private static final RowMapper<UserVM> USER_VM_MAPPER = (rs, rowNum) -> {
        UserVM vm = new UserVM();
        vm.setUserId(rs.getString("UserID"));
        vm.setDisplayName(rs.getString("DisplayName"));
        vm.setLanguage(rs.getString("Language"));
        vm.setStatus(rs.getString("Status"));
        vm.setRoleId(rs.getString("RoleID"));
        vm.setCreatedAt(rs.getTimestamp("CreatedAt") != null
                ? rs.getTimestamp("CreatedAt").toLocalDateTime() : null);
        vm.setLastLoggedIn(rs.getTimestamp("LastLoggedIn") != null
                ? rs.getTimestamp("LastLoggedIn").toLocalDateTime() : null);
        vm.setUpdatedAt(rs.getTimestamp("UpdatedAt") != null
                ? rs.getTimestamp("UpdatedAt").toLocalDateTime() : null);
        // Role permissions
        vm.setCanAddBuilds(rs.getBoolean("CanAddBuilds"));
        vm.setCanEditAllBuilds(rs.getBoolean("CanEditAllBuilds"));
        vm.setCanDeleteAllBuilds(rs.getBoolean("CanDeleteAllBuilds"));
        vm.setCanViewBuildTypes(rs.getBoolean("CanViewBuildTypes"));
        vm.setCanAddBuildTypes(rs.getBoolean("CanAddBuildTypes"));
        vm.setCanEditBuildTypes(rs.getBoolean("CanEditBuildTypes"));
        vm.setCanDeleteBuildTypes(rs.getBoolean("CanDeleteBuildTypes"));
        vm.setCanViewWorlds(rs.getBoolean("CanViewWorlds"));
        vm.setCanAddWorlds(rs.getBoolean("CanAddWorlds"));
        vm.setCanEditWorlds(rs.getBoolean("CanEditWorlds"));
        vm.setCanDeleteWorlds(rs.getBoolean("CanDeleteWorlds"));
        vm.setCanViewAllVotes(rs.getBoolean("CanViewAllVotes"));
        vm.setCanAddVotes(rs.getBoolean("CanAddVotes"));
        vm.setCanEditAllVotes(rs.getBoolean("CanEditAllVotes"));
        vm.setCanDeleteAllVotes(rs.getBoolean("CanDeleteAllVotes"));
        vm.setCanViewRoles(rs.getBoolean("CanViewRoles"));
        vm.setCanAddRoles(rs.getBoolean("CanAddRoles"));
        vm.setCanEditRoles(rs.getBoolean("CanEditRoles"));
        vm.setCanDeleteRoles(rs.getBoolean("CanDeleteRoles"));
        vm.setCanViewUsers(rs.getBoolean("CanViewUsers"));
        vm.setCanAddUsers(rs.getBoolean("CanAddUsers"));
        vm.setCanEditUsers(rs.getBoolean("CanEditUsers"));
        vm.setCanBanUsers(rs.getBoolean("CanBanUsers"));
        vm.setRoleDescription(rs.getString("Description"));
        // Profile picture (nullable join)
        vm.setImageId(rs.getObject("ImageID", Integer.class));
        vm.setFileName(rs.getString("FileName"));
        vm.setMimeType(rs.getString("MimeType"));
        vm.setFilePath(rs.getString("FilePath"));
        return vm;
    };

    // ── Queries ───────────────────────────────────────────────────────────────

    public List<User> findAll() {
        return jdbc.query("CALL sp_get_all_users()", new MapSqlParameterSource(), USER_MAPPER);
    }

    public Optional<User> findById(String userId) {
        List<User> results = jdbc.query(
                "CALL sp_get_user(:userId)",
                new MapSqlParameterSource("userId", userId),
                USER_MAPPER);
        return results.stream().findFirst();
    }

    /** Returns full view model with role permissions and profile picture. */
    public Optional<UserVM> findViewModelById(String userId) {
        List<UserVM> results = jdbc.query(
                "CALL sp_get_userVM(:userId)",
                new MapSqlParameterSource("userId", userId),
                USER_VM_MAPPER);
        return results.stream().findFirst();
    }

    public void insert(String userId, String hashedPassword, String displayName) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("userId",       userId);
        p.addValue("password",     hashedPassword);
        p.addValue("displayName",  displayName);
        jdbc.update("CALL sp_insert_user(:userId, :password, :displayName)", p);
    }

    public void update(User user) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("userId",       user.getUserId());
        p.addValue("displayName",  user.getDisplayName());
        p.addValue("pfpImageId",   user.getPfpImageId());
        p.addValue("language",     user.getLanguage());
        p.addValue("status",       user.getStatus());
        p.addValue("roleId",       user.getRoleId());
        p.addValue("lastLoggedIn", user.getLastLoggedIn());
        jdbc.update("CALL sp_update_user(:userId,:displayName,:pfpImageId,:language,:status,:roleId,:lastLoggedIn)", p);
    }

    public void updatePassword(String userId, String hashedPassword) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("userId",   userId);
        p.addValue("password", hashedPassword);
        jdbc.update("CALL sp_update_user_password(:userId, :password)", p);
    }

    public void updateRole(String userId, String roleId) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("userId", userId);
        p.addValue("roleId", roleId);
        jdbc.update("CALL sp_update_user_role(:userId, :roleId)", p);
    }

    public void deleteById(String userId) {
        jdbc.update("CALL sp_delete_user(:userId)",
                new MapSqlParameterSource("userId", userId));
    }
}
