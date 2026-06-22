DROP PROCEDURE IF EXISTS sp_build_tag_add;
DELIMITER $$
CREATE PROCEDURE sp_build_tag_add (
    IN p_acting_user_id INT,
    IN p_build_id       INT,
    IN p_tag_id         INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM build WHERE build_id = p_build_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build not found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tag WHERE tag_id = p_tag_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tag not found';
    END IF;

    INSERT INTO build_tag (
        build_id,
        tag_id
    )
    VALUES (
        p_build_id,
        p_tag_id
    );
END$$
DELIMITER ;
