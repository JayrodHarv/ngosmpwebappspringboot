DROP PROCEDURE IF EXISTS sp_role_list;
DELIMITER $$
CREATE PROCEDURE sp_role_list (
    IN p_acting_user_id INT
)
BEGIN
    SELECT  role_id,
            name,
            description,
            created_at,
            updated_at
    FROM role
    ORDER BY name;
END$$
DELIMITER ;
