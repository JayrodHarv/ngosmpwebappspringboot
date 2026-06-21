DROP PROCEDURE IF EXISTS sp_vote_get;
DELIMITER $$
CREATE PROCEDURE sp_vote_get (
    IN p_vote_id INT
)
BEGIN
    SELECT  v.vote_id,
            v.title,
            v.description,
            v.status,
            v.start_time,
            v.end_time,
            v.max_selections,
            v.created_at,
            u.user_id AS 'created_by',
            u.display_name AS 'created_by_name'
    FROM vote v
    JOIN user u
        ON u.user_id = v.user_id
    WHERE v.vote_id = p_vote_id;
END$$
DELIMITER ;
