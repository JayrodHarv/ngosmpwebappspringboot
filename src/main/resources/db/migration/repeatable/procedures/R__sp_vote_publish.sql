DROP PROCEDURE IF EXISTS sp_vote_publish;
DELIMITER $$
CREATE PROCEDURE sp_vote_publish (
    IN p_acting_user_id INT,
    IN p_vote_id        INT,
    IN p_start_time     DATETIME,
    IN p_end_time       DATETIME
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM vote WHERE vote_id = p_vote_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    UPDATE vote
    SET published_at    = CURRENT_TIMESTAMP,
        start_time      = p_start_time,
        end_time        = p_end_time,
        updated_by      = p_acting_user_id
    WHERE vote_id = p_vote_id
        AND published_at IS NULL;
END$$
DELIMITER ;
