DROP PROCEDURE IF EXISTS sp_user_list;
DELIMITER $$
CREATE PROCEDURE sp_user_list (
    IN p_acting_user_id INT,
    IN p_search         VARCHAR(100),
    IN p_decending      BOOLEAN,
    IN p_limit          INT,
    IN p_offset         INT
)
BEGIN
    SELECT  u.user_id,
            u.display_name,
            u.status,
            u.last_seen,
            u.created_at,
            i.file_path AS pfp_path
    FROM    user u
    LEFT JOIN image i
        ON i.image_id = u.pfp_image_id
    WHERE
        (
            p_search IS NULL
            OR p_search = ''
            OR u.display_name LIKE CONCAT('%', p_search, '%')
        )
    ORDER BY
        CASE
            WHEN p_descending = TRUE THEN u.created_at
        END DESC,

        CASE
            WHEN p_descending = FALSE THEN u.created_at
        END ASC
    LIMIT p_limit OFFSET p_offset;
END$$
DELIMITER ;

