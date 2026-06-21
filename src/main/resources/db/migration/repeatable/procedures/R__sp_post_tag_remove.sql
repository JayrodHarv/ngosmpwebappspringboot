DROP PROCEDURE IF EXISTS sp_post_tag_remove;
DELIMITER $$
CREATE PROCEDURE sp_post_tag_remove (
    IN p_acting_user_id INT,
    IN p_post_id        INT,
    IN p_tag_id         INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM post WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post not found';
    END IF;

    DELETE FROM post_tag
    WHERE post_id = p_post_id
        AND tag_id = p_tag_id;
END$$
DELIMITER ;
