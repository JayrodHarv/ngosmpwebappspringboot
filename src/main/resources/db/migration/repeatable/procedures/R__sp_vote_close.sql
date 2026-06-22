DROP PROCEDURE IF EXISTS sp_vote_close;
DELIMITER $$
CREATE PROCEDURE sp_vote_close (
    IN p_acting_user_id INT,
    IN p_vote_id        INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM vote WHERE vote_id = p_vote_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    UPDATE vote
    SET is_closed_early = TRUE,
        updated_by      = p_acting_user_id
    WHERE vote_id = p_vote_id;
END$$
DELIMITER ;

