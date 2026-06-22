DROP PROCEDURE IF EXISTS sp_post_tag_add;
DELIMITER $$
CREATE PROCEDURE sp_post_tag_add (
    IN p_acting_user_id INT,
    IN p_post_id        INT,
    IN p_tag_id         INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM post WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post not found';
    END IF;

    INSERT INTO post_tag (
        post_id,
        tag_id
    ) 
    VALUES (
        p_post_id,
        p_tag_id
    );
END$$
DELIMITER ;
