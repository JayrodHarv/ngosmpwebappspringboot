DROP PROCEDURE IF EXISTS sp_post_image_remove;
DELIMITER $$
CREATE PROCEDURE sp_post_image_remove (
    IN p_acting_user_id INT,
    IN p_post_id        INT,
    IN p_image_id       INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM post WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post not found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Image not found';
    END IF;

    DELETE FROM post_image
    WHERE post_id = p_post_id
        AND image_id = p_image_id;
END$$
DELIMITER ;
