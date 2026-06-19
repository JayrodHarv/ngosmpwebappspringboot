package com.jayrodharv.ngosmpwebappspringboot.dao;

import java.util.List;
import java.util.Map;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import com.jayrodharv.ngosmpwebappspringboot.dto.PermissionDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.RoleDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.user.UserAccountDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.user.UserDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.user.UserLoginDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.user.UserProfileDTO;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageRequest;

import lombok.RequiredArgsConstructor;

@Repository
@RequiredArgsConstructor
public class UserDAO {

    private final JdbcTemplate jdbc;

    public Integer registerUser(
        String email,
        String displayName,
        String passwordHash
    ) throws DataAccessException {
        
        SimpleJdbcCall call = new SimpleJdbcCall(jdbc).withProcedureName("sp_register_user");

        Map<String, Object> result = call.execute(
            new MapSqlParameterSource()
                .addValue("p_email", email)
                .addValue("p_display_name", displayName)
                .addValue("p_password_hash", passwordHash)
        );

        return ((Integer) result.get("p_user_id"));
    }

    public UserLoginDTO loginUser(String email) throws DataAccessException {
        
        List<UserLoginDTO> results = 
            jdbc.query(
                "CALL sp_login_user(?)",
                (rs, rowNum) ->
                    new UserLoginDTO(
                        rs.getInt("user_id"),
                        rs.getString("display_name"),
                        rs.getString("password_hash"),
                        rs.getString("status")
                    ),
            email
        );

        return results.stream()
            .findFirst()
            .orElse(null);
    }

    public UserAccountDTO getUserAccount(
        Integer actingUserId,
        Integer userId
    ) throws DataAccessException {

        return jdbc.queryForObject(
            "CALL sp_get_user_account(?, ?)",
            (rs, rowNum) ->
                new UserAccountDTO(
                    rs.getInt("user_id"),
                    rs.getString("email"),
                    rs.getString("display_name"),
                    rs.getString("status"),
                    rs.getTimestamp("last_seen") == null
                        ? null
                        : rs.getTimestamp("last_seen")
                        .toLocalDateTime(),
                    rs.getTimestamp("created_at")
                        .toLocalDateTime(),
                    rs.getTimestamp("last_updated_at") == null
                        ? null
                        : rs.getTimestamp("last_updated_at").toLocalDateTime(),
                    rs.getString("pfp_path")
                ),
            actingUserId,
            userId
        );
    }

    public UserProfileDTO getUserProfile(
        Integer actingUserId,
        Integer userId
    ) throws DataAccessException {

        return jdbc.queryForObject(
            "CALL sp_get_user(?, ?)",
            (rs, rowNum) ->
                new UserProfileDTO(
                    rs.getInt("user_id"),
                    rs.getString("display_name"),
                    rs.getTimestamp("last_seen") == null
                        ? null
                        : rs.getTimestamp("last_seen")
                        .toLocalDateTime(),
                    rs.getTimestamp("created_at")
                        .toLocalDateTime(),
                    rs.getString("pfp_path")
                ),
            actingUserId,
            userId
        );
    }

    public List<UserDTO> getUsers(
        Integer actingUserId,
        PageRequest request
    ) throws DataAccessException {

        return jdbc.query(
            "CALL sp_get_users(?, ?, ?, ?, ?)",
            (rs, rowNum) ->
                new UserDTO(
                    rs.getInt("user_id"),
                    rs.getString("display_name"),
                    rs.getString("status"),
                    rs.getTimestamp("last_seen") == null
                        ? null
                        : rs.getTimestamp("last_seen")
                        .toLocalDateTime(),
                    rs.getTimestamp("created_at")
                        .toLocalDateTime(),
                    rs.getString("pfp_path")
                ),
            actingUserId,
            request.search(),
            request.descending(),
            request.size(),
            request.offset()
        );
    }

    public int countUsers() {

        Integer count = jdbc.queryForObject(
            "CALL sp_count_users()",
            (rs, rowNum) -> rs.getInt("total")
        );

        return count == null ? 0 : count;
    }

    public void updateUser(
        Integer actingUserId,
        Integer userId,
        String displayName,
        Integer pfpImageId
    ) throws DataAccessException {

        jdbc.update(
            "CALL sp_update_user(?, ?, ?, ?)",
            actingUserId,
            userId,
            displayName,
            pfpImageId
        );
    }

    public void deleteUser(
        Integer actingUserId,
        Integer userId
    ) throws DataAccessException {

        jdbc.update(
            "CALL sp_delete_user(?, ?)",
            actingUserId,
            userId
        );
    }

    public void banUser(Integer actingUserId, Integer userId) {
        
        jdbc.update(
            "CALL sp_ban_user(?, ?)",
            actingUserId,
            userId
        );
    }

    public List<PermissionDTO> getUserPermissions(Integer userId) {
        
        return jdbc.query(
            "CALL sp_get_user_permissions(?)",
            (rs, rowNum) ->
                new PermissionDTO(
                    rs.getInt("permission_id"),
                    rs.getString("name"),
                    rs.getString("description")
                ),
            userId
        );
    }

    public List<RoleDTO> getUserRoles(Integer userId) {
        
        return jdbc.query(
            "CALL sp_get_user_roles(?)",
            (rs, rowNum) ->
                new RoleDTO(
                    rs.getInt("role_id"),
                    rs.getString("name"),
                    rs.getString("description")
                ),
            userId
        );
    }
}
