DROP PROCEDURE IF EXISTS sp_role_get;
DELIMITER $$
CREATE PROCEDURE sp_role_get (
    IN p_acting_user_id INT,
    IN p_role_id        INT
)
BEGIN
    SELECT  role_id,
            name,
            description,
            created_at,
            updated_at
    FROM role
    WHERE role_id = p_role_id;
END$$
DELIMITER ;
