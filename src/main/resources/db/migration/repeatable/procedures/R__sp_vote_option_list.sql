DROP PROCEDURE IF EXISTS sp_vote_option_list;
DELIMITER $$
CREATE PROCEDURE sp_vote_option_list (
    IN p_vote_id INT
)
BEGIN
    SELECT  option_id,
            vote_id,
            title,
            description,
            sort_order
    FROM vote_option
    WHERE vote_id = p_vote_id
    ORDER BY sort_order;
END$$
DELIMITER ;
