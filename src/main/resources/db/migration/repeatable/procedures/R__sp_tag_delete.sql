DROP PROCEDURE IF EXISTS sp_tag_delete;
DELIMITER $$
CREATE PROCEDURE sp_tag_delete (
    IN p_acting_user_id INT,
    IN p_tag_id         INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM tag WHERE tag_id = p_tag_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tag not found';
    END IF;

    DELETE FROM tag
    WHERE tag_id = p_tag_id;
END$$
DELIMITER ;
