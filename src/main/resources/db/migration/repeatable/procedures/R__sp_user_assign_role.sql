DROP PROCEDURE IF EXISTS sp_user_assign_role;
DELIMITER $$
CREATE PROCEDURE sp_user_assign_role (
    IN p_acting_user_id INT,
    IN p_user_id        INT,
    IN p_role_id        INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM user WHERE user_id = p_user_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM role WHERE role_id = p_role_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Role not found';
    END IF;

    INSERT INTO user_role (
        user_id,
        role_id,
        created_by
    )
    VALUES (
        p_user_id,
        p_role_id,
        p_acting_user_id
    );
END$$
DELIMITER ;
