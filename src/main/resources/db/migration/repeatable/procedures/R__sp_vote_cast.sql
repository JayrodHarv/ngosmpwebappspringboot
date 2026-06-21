DROP PROCEDURE IF EXISTS sp_vote_cast;
DELIMITER $$
CREATE PROCEDURE sp_vote_cast (
    IN p_acting_user_id INT,
    IN p_vote_id        INT,
    IN p_option_id      INT
)
BEGIN
    DECLARE v_status        VARCHAR(10);
    DECLARE v_max_sel       INT;
    DECLARE v_option_vote   INT;
    DECLARE v_current_sel   INT;

    -- Verify vote is active
    SELECT status, max_selections
    INTO v_status, v_max_sel
    FROM vote WHERE vote_id = p_vote_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    IF v_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote is not active';
    END IF;

    -- Verify option belongs to this vote
    SELECT COUNT(*) INTO v_option_vote
    FROM   vote_option
    WHERE  option_id = p_option_id AND vote_id = p_vote_id;

    IF v_option_vote = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Option does not belong to this vote';
    END IF;

    -- Enforce max_selections
    SELECT COUNT(*) INTO v_current_sel
    FROM   user_vote
    WHERE  user_id = p_acting_user_id AND vote_id = p_vote_id;

    IF v_current_sel >= v_max_sel THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Maximum selections reached for this vote';
    END IF;

    -- Prevent duplicate selection
    IF EXISTS (SELECT 1 FROM user_vote
               WHERE user_id = p_acting_user_id
                    AND vote_id = p_vote_id
                    AND option_id = p_option_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'You have already selected this option';
    END IF;

    INSERT INTO user_vote (
        user_id,
        vote_id,
        option_id
    )
    VALUES (
        p_acting_user_id,
        p_vote_id,
        p_option_id
    );
END$$
DELIMITER ;
