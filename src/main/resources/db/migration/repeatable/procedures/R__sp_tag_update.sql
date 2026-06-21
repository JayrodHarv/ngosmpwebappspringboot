DROP PROCEDURE IF EXISTS sp_tag_update;
DELIMITER $$
CREATE PROCEDURE sp_tag_update (
    IN p_acting_user_id INT,
    IN p_tag_id         INT,
    IN p_name           VARCHAR(50),
    IN p_description    VARCHAR(255)
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM tag WHERE tag_id = p_tag_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tag not found';
    END IF;

    UPDATE tag
    SET    name            = p_name,
           description     = p_description,
           last_updated_by = p_acting_user_id,
           last_updated_at = CURRENT_TIMESTAMP
    WHERE  tag_id = p_tag_id;
END$$
DELIMITER ;
