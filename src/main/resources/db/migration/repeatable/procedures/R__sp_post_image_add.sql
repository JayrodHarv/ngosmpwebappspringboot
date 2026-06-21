DROP PROCEDURE IF EXISTS sp_post_image_add;
DELIMITER $$
CREATE PROCEDURE sp_post_image_add (
    IN p_acting_user_id INT,
    IN p_post_id        INT,
    IN p_image_id       INT,
    IN p_sort_order     INT
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

    INSERT INTO post_image (
        post_id,
        image_id,
        sort_order
    )
    VALUES (
        p_post_id,
        p_image_id,
        p_sort_order
    );
END$$
DELIMITER ;
