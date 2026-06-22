DROP PROCEDURE IF EXISTS sp_role_assign_permission;
DELIMITER $$
CREATE PROCEDURE sp_role_assign_permission (
    IN p_acting_user_id INT,
    IN p_role_id        INT,
    IN p_permission_id  INT
)
BEGIN
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
