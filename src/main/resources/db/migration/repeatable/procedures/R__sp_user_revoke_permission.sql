DROP PROCEDURE IF EXISTS sp_user_revoke_permission;
DELIMITER $$
CREATE PROCEDURE sp_user_revoke_permission (
    IN p_acting_user_id INT,
    IN p_user_id        INT,
    IN p_permission_id  INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    DELETE FROM user_permission
    WHERE user_id = p_user_id 
        AND permission_id = p_permission_id;
END$$
DELIMITER ;
