DROP PROCEDURE IF EXISTS sp_post_get;
DELIMITER $$
CREATE PROCEDURE sp_post_get (
    IN p_post_id INT
)
BEGIN
    SELECT  p.post_id,
            p.title,
            p.slug,
            p.content,
            p.is_pinned,
            p.publish_at,
            p.expires_at,
            p.created_at,
            p.updated_at,
            pt.post_type_id,
            pt.name        AS post_type_name,
            u.user_id      AS created_by,
            u.display_name AS created_by_name,
            i.file_path    AS featured_image_path
    FROM post p
    JOIN post_type pt
        ON pt.post_type_id = p.post_type_id
    JOIN user u
        ON u.user_id = p.created_by
    LEFT JOIN image i
        ON i.image_id = p.featured_image_id
    WHERE p.post_id = p_post_id;
END$$
DELIMITER ;
