DROP PROCEDURE IF EXISTS sp_role_delete;
DELIMITER $$
CREATE PROCEDURE sp_role_delete (
    IN p_acting_user_id INT,
    IN p_role_id        INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM role WHERE role_id = p_role_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Role not found';
    END IF;

    DELETE FROM role
    WHERE role_id = p_role_id;
END$$
DELIMITER ;

