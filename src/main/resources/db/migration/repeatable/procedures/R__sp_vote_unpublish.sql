DROP PROCEDURE IF EXISTS sp_vote_unpublish;
DELIMITER $$
CREATE PROCEDURE sp_vote_unpublish (
    IN p_acting_user_id INT,
    IN p_vote_id        INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM vote
        WHERE vote_id = p_vote_id
            AND published_at IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No published vote exists';
    END IF;

    START TRANSACTION;

    -- Un-publish this vote
    UPDATE vote
    SET published_at    = NULL,
        start_time      = NULL,
        end_time        = NULL,
        updated_by      = p_acting_user_id
    WHERE vote_id = p_vote_id
        AND published_at IS NOT NULL;
    
    -- Remove all user votes from this vote
    DELETE FROM user_vote
    WHERE vote_id = p_vote_id;

    COMMIT;
END$$
DELIMITER ;
