DROP PROCEDURE IF EXISTS sp_permission_list;
DELIMITER $$
CREATE PROCEDURE sp_permission_list (
    IN p_acting_user_id INT
)
BEGIN
    SELECT  permission_id,
            name,
            description
    FROM    permission
    ORDER BY name;
END$$
DELIMITER ;
