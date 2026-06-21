DROP PROCEDURE IF EXISTS sp_vote_user_vote_list;
DELIMITER $$
CREATE PROCEDURE sp_vote_user_vote_list (
    IN p_user_id INT,
    IN p_vote_id INT
)
BEGIN
    SELECT  uv.option_id,
            vo.title,
            uv.vote_time
    FROM user_vote uv
    JOIN vote_option vo
        ON vo.option_id = uv.option_id
    WHERE uv.user_id = p_user_id
        AND uv.vote_id = p_vote_id;
END$$
DELIMITER ;
