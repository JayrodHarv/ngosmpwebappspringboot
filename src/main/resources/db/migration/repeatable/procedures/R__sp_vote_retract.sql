DROP PROCEDURE IF EXISTS sp_vote_retract;
DELIMITER $$
CREATE PROCEDURE sp_vote_retract (
    IN p_acting_user_id INT,
    IN p_vote_id        INT
)
BEGIN
    DECLARE v_status VARCHAR(10);

    SELECT status INTO v_status FROM vote WHERE vote_id = p_vote_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    IF v_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot retract from a non-active vote';
    END IF;

    DELETE FROM user_vote
    WHERE user_id = p_acting_user_id
        AND vote_id = p_vote_id;
END$$
DELIMITER ;
