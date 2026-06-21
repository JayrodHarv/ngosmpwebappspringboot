DROP PROCEDURE IF EXISTS sp_role_permission_list;
DELIMITER $$
CREATE PROCEDURE sp_role_permission_list (
    IN p_acting_user_id INT,
    IN p_role_id        INT
)
BEGIN
    SELECT  p.permission_id, p.name, p.description
    FROM    role_permission rp
    JOIN    permission p 
        ON p.permission_id = rp.permission_id
    WHERE   rp.role_id = p_role_id
    ORDER BY p.name;
END$$
DELIMITER ;
