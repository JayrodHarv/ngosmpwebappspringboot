DROP PROCEDURE IF EXISTS sp_post_create;
DELIMITER $$
CREATE PROCEDURE sp_post_create (
    IN  p_acting_user_id    INT,
    IN  p_title             VARCHAR(255),
    IN  p_slug              VARCHAR(255),
    IN  p_content           TEXT,
    IN  p_post_type_id      INT,
    IN  p_is_pinned         BIT,
    IN  p_publish_at        DATETIME,
    IN  p_expires_at        DATETIME,
    IN  p_featured_image_id INT,
    OUT p_post_id           INT
)
BEGIN
    IF EXISTS (SELECT 1 FROM post WHERE title = p_title) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post title already in use';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM post_type WHERE post_type_id = p_post_type_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post type not found';
    END IF;

    IF p_featured_image_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_featured_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Featured image not found';
    END IF;

    INSERT INTO post (
        title,
        slug,
        content,
        post_type_id,
        is_pinned,
        publish_at,
        expires_at,
        featured_image_id,
        created_by
    )
    VALUES (
        p_title,
        p_slug,
        p_content,
        p_post_type_id,
        p_is_pinned,
        p_publish_at,
        p_expires_at,
        p_featured_image_id,
        p_acting_user_id
    );

    SET p_post_id = LAST_INSERT_ID();
END$$
DELIMITER ;
