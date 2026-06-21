DROP PROCEDURE IF EXISTS sp_user_update;
DELIMITER $$
CREATE PROCEDURE sp_user_update (
    IN  p_acting_user_id    INT,
    IN  p_user_id           INT,
    IN  p_display_name      VARCHAR(50),
    IN  p_pfp_image_id      INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    -- Check if display_name already taken
    IF EXISTS (SELECT 1 FROM users WHERE display_name = p_display_name) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Display name already in use';
    END IF;

    -- Check that pfp image has been uploaded already
    IF NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_pfp_image_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Image not found.';
    END IF;

    -- Perform operation
    UPDATE  user
    SET     display_name    = p_display_name,
            pfp_image_id    = p_pfp_image_id,
            updated_by = p_acting_user_id
    WHERE   user_id = p_user_id;
END$$
DELIMITER ;

