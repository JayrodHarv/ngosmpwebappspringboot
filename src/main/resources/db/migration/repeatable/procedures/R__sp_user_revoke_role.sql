DROP PROCEDURE IF EXISTS sp_user_revoke_role;
DELIMITER $$
CREATE PROCEDURE sp_user_revoke_role (
    IN p_acting_user_id INT,
    IN p_user_id        INT,
    IN p_role_id        INT
)
BEGIN
    DELETE FROM user_role
    WHERE user_id = p_user_id 
        AND role_id = p_role_id;
END$$
DELIMITER ;
