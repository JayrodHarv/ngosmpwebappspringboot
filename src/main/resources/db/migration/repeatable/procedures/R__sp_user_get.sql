DROP PROCEDURE IF EXISTS sp_user_get;
DELIMITER $$
CREATE PROCEDURE sp_user_get (
    IN p_acting_user_id INT,
    IN p_user_id        INT
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
    WHERE   u.user_id = p_user_id;
END$$
DELIMITER ;
