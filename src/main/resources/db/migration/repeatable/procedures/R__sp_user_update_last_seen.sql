DROP PROCEDURE IF EXISTS sp_user_update_last_seen;
DELIMITER $$
CREATE PROCEDURE sp_user_update_last_seen (
    IN p_user_id INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    UPDATE user 
    SET last_seen = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;
END$$
DELIMITER ;
