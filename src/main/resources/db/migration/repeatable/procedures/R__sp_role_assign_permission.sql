DROP PROCEDURE IF EXISTS sp_role_assign_permission;
DELIMITER $$
CREATE PROCEDURE sp_role_assign_permission (
    IN p_acting_user_id INT,
    IN p_role_id        INT,
    IN p_permission_id  INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    INSERT INTO role_permission (
        role_id,
        permission_id
    )
    VALUES (
        p_role_id,
        p_permission_id
    );
END$$
DELIMITER ;
