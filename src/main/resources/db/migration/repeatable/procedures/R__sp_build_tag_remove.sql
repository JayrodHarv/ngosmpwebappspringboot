DROP PROCEDURE IF EXISTS sp_build_tag_remove;
DELIMITER $$
CREATE PROCEDURE sp_build_tag_remove (
    IN p_acting_user_id INT,
    IN p_build_id       INT,
    IN p_tag_id         INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM build WHERE build_id = p_build_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build not found';
    END IF;

    DELETE FROM build_tag
    WHERE build_id = p_build_id
        AND tag_id = p_tag_id;
END$$
DELIMITER ;
