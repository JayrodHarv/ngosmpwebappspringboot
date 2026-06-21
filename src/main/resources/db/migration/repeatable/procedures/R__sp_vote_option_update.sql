DROP PROCEDURE IF EXISTS sp_vote_option_update;
DELIMITER $$
CREATE PROCEDURE sp_vote_option_update (
    IN p_acting_user_id INT,
    IN p_option_id      INT,
    IN p_title          VARCHAR(255),
    IN p_description    TEXT,
    IN p_sort_order     INT
)
BEGIN
    DECLARE v_vote_id  INT;
    DECLARE v_status   VARCHAR(10);

    -- Set session user
    SET @current_user_id = p_acting_user_id;

    SELECT  vo.vote_id,
            v.status
    INTO    v_vote_id,
            v_status
    FROM vote_option vo
    JOIN vote v
        ON v.vote_id = vo.vote_id
    WHERE vo.option_id = p_option_id;

    IF v_vote_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote option not found';
    END IF;

    IF v_status <> 'DRAFT' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Options can only be edited on DRAFT votes';
    END IF;

    UPDATE vote_option
    SET title       = p_title,
        description = p_description,
        sort_order  = p_sort_order
    WHERE option_id = p_option_id;
END$$
DELIMITER ;
