DROP PROCEDURE IF EXISTS sp_vote_create;
DELIMITER $$
CREATE PROCEDURE sp_vote_create (
    IN  p_acting_user_id    INT,
    IN  p_title             VARCHAR(255),
    IN  p_description       TEXT,
    IN  p_max_selections    INT,
    OUT p_vote_id           INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF EXISTS (SELECT 1 FROM vote WHERE title = p_title) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote title already in use';
    END IF;

    INSERT INTO vote (
        user_id,
        title,
        description,
        max_selections,
        created_by
    )
    VALUES (
        p_acting_user_id,
        p_title,
        p_description,
        p_max_selections,
        p_acting_user_id
    );

    SET p_vote_id = LAST_INSERT_ID();
END$$
DELIMITER ;
