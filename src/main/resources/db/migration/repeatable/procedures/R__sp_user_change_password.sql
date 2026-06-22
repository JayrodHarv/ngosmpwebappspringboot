DROP PROCEDURE IF EXISTS sp_user_change_password;
DELIMITER $$
CREATE PROCEDURE sp_user_change_password (
    IN  p_acting_user_id        INT,
    IN  p_user_id               INT,
    IN  p_new_password_hash     VARCHAR(255)
)
BEGIN
    UPDATE  user
    SET     password_hash   = p_password_hash,
            updated_by = p_acting_user_id
    WHERE   user_id = p_user_id;
END$$
DELIMITER ;
