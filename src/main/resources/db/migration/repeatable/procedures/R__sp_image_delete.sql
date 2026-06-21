DROP PROCEDURE IF EXISTS sp_image_delete;
DELIMITER $$
CREATE PROCEDURE sp_image_delete (
    IN p_acting_user_id     INT,
    IN p_image_id           INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    -- Perform operation
    DELETE FROM image
    WHERE image_id = p_image_id;
END$$
DELIMITER ;
