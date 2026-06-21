DROP PROCEDURE IF EXISTS sp_vote_list;
DELIMITER $$
CREATE PROCEDURE sp_vote_list (
    IN p_status ENUM('DRAFT','ACTIVE','CLOSED'),  -- NULL = all
    IN p_limit  INT,
    IN p_offset INT
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
    WHERE p_status IS NULL
        OR v.status = p_status
    ORDER BY v.created_at DESC
    LIMIT p_limit OFFSET p_offset;
END$$
DELIMITER ;
