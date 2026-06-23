DROP PROCEDURE IF EXISTS sp_tag_update;
DELIMITER $$
CREATE PROCEDURE sp_tag_update (
    IN p_acting_user_id INT,
    IN p_tag_id         INT,
    IN p_tag_type_id    INT,
    IN p_name           VARCHAR(50),
    IN p_description    VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tag WHERE tag_id = p_tag_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tag not found';
    END IF;

    UPDATE tag
    SET tag_type_id = p_tag_type_id,
        name            = p_name,
        description     = p_description,
        updated_by = p_acting_user_id
    WHERE tag_id = p_tag_id;
END$$
DELIMITER ;
