DROP PROCEDURE IF EXISTS sp_vote_update;
DELIMITER $$
CREATE PROCEDURE sp_vote_update (
    IN p_acting_user_id INT,
    IN p_vote_id        INT,
    IN p_title          VARCHAR(255),
    IN p_description    TEXT,
    IN p_max_selections INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;
    
    IF NOT EXISTS (SELECT 1 FROM vote WHERE vote_id = p_vote_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    UPDATE vote
    SET title          = p_title,
        description    = p_description,
        max_selections = p_max_selections
    WHERE vote_id = p_vote_id;
END$$
DELIMITER ;
