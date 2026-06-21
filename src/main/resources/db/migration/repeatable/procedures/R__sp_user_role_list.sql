DROP PROCEDURE IF EXISTS sp_user_role_list;
DELIMITER $$
CREATE PROCEDURE sp_user_role_list (
    IN p_user_id        INT
)
BEGIN
    SELECT  r.role_id,
            r.name,
            r.description
    FROM    user_role ur
    JOIN    role r
        ON r.role_id = ur.role_id
    WHERE   ur.user_id = p_user_id
    ORDER BY r.name;
END$$
DELIMITER ;
