DROP PROCEDURE IF EXISTS sp_user_assign_permission;
DELIMITER $$
CREATE PROCEDURE sp_user_assign_permission (
    IN p_acting_user_id INT,
    IN p_user_id        INT,
    IN p_permission_id  INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    INSERT INTO user_permission (
        user_id,
        permission_id
    )
    VALUES (
        p_user_id,
        p_permission_id
    );
END$$
DELIMITER ;
