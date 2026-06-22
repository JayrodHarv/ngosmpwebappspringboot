DROP PROCEDURE IF EXISTS sp_vote_delete;
DELIMITER $$
CREATE PROCEDURE sp_vote_delete (
    IN p_acting_user_id INT,
    IN p_vote_id        INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM vote WHERE vote_id = p_vote_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    DELETE FROM vote
    WHERE vote_id = p_vote_id;
END$$
DELIMITER ;
