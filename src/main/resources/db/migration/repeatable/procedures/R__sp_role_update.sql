DROP PROCEDURE IF EXISTS sp_role_update;
DELIMITER $$
CREATE PROCEDURE sp_role_update (
    IN p_acting_user_id INT,
    IN p_role_id        INT,
    IN p_name           VARCHAR(50),
    IN p_description    VARCHAR(255)
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM role WHERE role_id = p_role_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Role not found';
    END IF;

    UPDATE role
    SET    name        = p_name,
           description = p_description,
           updated_by  = p_acting_user_id
    WHERE  role_id = p_role_id;
END$$
DELIMITER ;

