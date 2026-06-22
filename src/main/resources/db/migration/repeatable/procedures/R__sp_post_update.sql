DROP PROCEDURE IF EXISTS sp_post_update;
DELIMITER $$
CREATE PROCEDURE sp_post_update (
    IN p_acting_user_id    INT,
    IN p_post_id           INT,
    IN p_title             VARCHAR(255),
    IN p_slug              VARCHAR(255),
    IN p_content           TEXT,
    IN p_post_type_id      INT,
    IN p_is_pinned         BIT,
    IN p_publish_at        DATETIME,
    IN p_expires_at        DATETIME,
    IN p_featured_image_id INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM post WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post not found';
    END IF;

    IF p_featured_image_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_featured_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Featured image not found';
    END IF;

    UPDATE post
    SET title             = p_title,
        slug              = p_slug,
        content           = p_content,
        post_type_id      = p_post_type_id,
        is_pinned         = p_is_pinned,
        publish_at        = p_publish_at,
        expires_at        = p_expires_at,
        featured_image_id = p_featured_image_id,
        updated_by        = p_acting_user_id
    WHERE post_id = p_post_id;
END$$
DELIMITER ;
