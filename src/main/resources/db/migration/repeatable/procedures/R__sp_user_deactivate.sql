DROP PROCEDURE IF EXISTS sp_user_deactivate;
DELIMITER $$
CREATE PROCEDURE sp_user_deactivate (
    IN p_acting_user_id     INT,
    IN p_user_id            INT
)
BEGIN
    -- Set user status to 'INACTIVE'
    UPDATE  user
    SET     status          = 'INACTIVE',
            updated_by = p_acting_user_id
    WHERE   user_id = p_user_id;
END$$
DELIMITER ;
