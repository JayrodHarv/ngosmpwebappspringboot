DROP PROCEDURE IF EXISTS sp_vote_option_delete;
DELIMITER $$
CREATE PROCEDURE sp_vote_option_delete (
    IN p_acting_user_id INT,
    IN p_option_id      INT
)
BEGIN
    DECLARE v_status VARCHAR(10);

    SELECT v.status
    INTO v_status
    FROM vote_option vo
    JOIN vote v
        ON v.vote_id = vo.vote_id
    WHERE vo.option_id = p_option_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote option not found';
    END IF;

    IF v_status <> 'DRAFT' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Options can only be deleted from DRAFT votes';
    END IF;

    DELETE FROM vote_option
    WHERE option_id = p_option_id;
END$$
DELIMITER ;
