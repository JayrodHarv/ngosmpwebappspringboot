DROP PROCEDURE IF EXISTS sp_user_permission_list;
DELIMITER $$
CREATE PROCEDURE sp_user_permission_list (
    IN p_user_id        INT
)
BEGIN
    SELECT DISTINCT p.permission_id,
                    p.name, 
                    p.description
    FROM   permission p
    WHERE  p.permission_id IN (
        -- via roles
        SELECT rp.permission_id
        FROM   user_role ur
        JOIN   role_permission rp 
            ON rp.role_id = ur.role_id
        WHERE  ur.user_id = p_user_id
        UNION
        -- direct grants
        SELECT up.permission_id
        FROM   user_permission up
        WHERE  up.user_id = p_user_id
    )
    ORDER BY p.name;
END$$
DELIMITER ;
