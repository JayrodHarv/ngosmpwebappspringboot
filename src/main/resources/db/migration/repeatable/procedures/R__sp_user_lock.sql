DROP PROCEDURE IF EXISTS sp_user_lock;
DELIMITER $$
CREATE PROCEDURE sp_user_lock (
	IN p_acting_user_id INT,
	IN p_user_id        INT
)
BEGIN
	UPDATE user
	SET status = 'LOCKED',
		last_updated_by = p_acting_user_id
	WHERE user_id = p_user_id;
END$$
DELIMITER ;
