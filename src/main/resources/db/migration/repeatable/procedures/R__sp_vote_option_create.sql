DROP PROCEDURE IF EXISTS sp_vote_option_create;
DELIMITER $$
CREATE PROCEDURE sp_vote_option_create (
    IN  p_acting_user_id INT,
    IN  p_vote_id        INT,
    IN  p_title          VARCHAR(255),
    IN  p_description    TEXT,
    IN  p_sort_order     INT,
    OUT p_option_id      INT
)
BEGIN
    DECLARE v_vote_id       INT;
    DECLARE v_published_at  DATETIME;

    -- Set session user
    SET @current_user_id = p_acting_user_id;

    SELECT  vote_id,
            published_at
    INTO    v_vote_id,
            v_published_at
    FROM vote
    WHERE vote_id = p_vote_id;

    IF v_vote_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    IF v_published_at IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Options can only be added to DRAFT votes';
    END IF;

    INSERT INTO vote_option (
        vote_id,
        title,
        description,
        sort_order
    )
    VALUES (
        p_vote_id,
        p_title,
        p_description,
        p_sort_order
    );

    SET p_option_id = LAST_INSERT_ID();
END$$
DELIMITER ;
