DROP PROCEDURE IF EXISTS sp_vote_option_image_add;
DELIMITER $$
CREATE PROCEDURE sp_vote_option_image_add (
    IN p_acting_user_id INT,
    IN p_option_id      INT,
    IN p_image_id       INT,
    IN p_sort_order     INT
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

    IF NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Image not found';
    END IF;

    INSERT INTO vote_option_image (
        option_id,
        image_id,
        sort_order
    )
    VALUES (
        p_option_id,
        p_image_id,
        p_sort_order
    );
END$$
DELIMITER ;
