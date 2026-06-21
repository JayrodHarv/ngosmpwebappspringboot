DROP PROCEDURE IF EXISTS sp_user_login;
DELIMITER $$
CREATE PROCEDURE sp_user_login (
    IN  p_email         VARCHAR(255)
)
BEGIN
    SELECT  user_id,
            display_name,
            password_hash,
            status
    FROM user
    WHERE email = p_email;
END$$
DELIMITER ;
