DROP PROCEDURE IF EXISTS sp_role_revoke_permission;
DELIMITER $$
CREATE PROCEDURE sp_role_revoke_permission (
    IN p_acting_user_id INT,
    IN p_role_id        INT,
    IN p_permission_id  INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;
    
    DELETE FROM role_permission
    WHERE role_id = p_role_id
        AND permission_id = p_permission_id;
END$$
DELIMITER ;
