DROP PROCEDURE IF EXISTS sp_vote_option_image_remove;
DELIMITER $$
CREATE PROCEDURE sp_vote_option_image_remove (
    IN p_acting_user_id INT,
    IN p_option_id      INT,
    IN p_image_id       INT
)
BEGIN
    DECLARE v_option_id INT;

    SELECT vo.option_id
    INTO v_option_id
    FROM vote_option vo
    JOIN vote v
        ON v.vote_id = vo.vote_id
    WHERE vo.option_id = p_option_id;

    IF v_option_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote option not found';
    END IF;

    DELETE FROM vote_option_image
    WHERE option_id = p_option_id
        AND image_id = p_image_id;
END$$
DELIMITER ;
