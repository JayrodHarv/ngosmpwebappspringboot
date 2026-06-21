DROP PROCEDURE IF EXISTS sp_post_delete;
DELIMITER $$
CREATE PROCEDURE sp_post_delete (
    IN p_acting_user_id INT,
    IN p_post_id        INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM post WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post not found';
    END IF;

    DELETE FROM post
    WHERE post_id = p_post_id;
END$$
DELIMITER ;

