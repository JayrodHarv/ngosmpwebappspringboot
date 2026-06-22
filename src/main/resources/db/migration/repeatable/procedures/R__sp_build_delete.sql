DROP PROCEDURE IF EXISTS sp_build_delete;
DELIMITER $$
CREATE PROCEDURE sp_build_delete (
    IN p_acting_user_id INT,
    IN p_build_id       INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM build WHERE build_id = p_build_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build not found';
    END IF;

    DELETE FROM build
    WHERE build_id = p_build_id;
END$$
DELIMITER ;
