DROP PROCEDURE IF EXISTS sp_build_image_remove_all;
DELIMITER $$
CREATE PROCEDURE sp_build_image_remove_all (
    IN p_acting_user_id INT,
    IN p_build_id       INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM build WHERE build_id = p_build_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build not found';
    END IF;

    DELETE FROM build_image
    WHERE build_id = p_build_id;
END$$
DELIMITER ;
