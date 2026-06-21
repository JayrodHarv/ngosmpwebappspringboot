DROP PROCEDURE IF EXISTS sp_vote_results;
DELIMITER $$
CREATE PROCEDURE sp_vote_results (
    IN p_vote_id INT
)
BEGIN
    SELECT  vo.option_id,
            vo.title,
            vo.sort_order,
            COUNT(uv.user_id) AS 'vote_count'
    FROM vote_option vo
    LEFT JOIN user_vote uv
        ON uv.option_id = vo.option_id 
            AND uv.vote_id = p_vote_id
    WHERE vo.vote_id = p_vote_id
    GROUP BY    vo.option_id,
                vo.title,
                vo.sort_order
    ORDER BY vo.sort_order;
END$$
DELIMITER ;
