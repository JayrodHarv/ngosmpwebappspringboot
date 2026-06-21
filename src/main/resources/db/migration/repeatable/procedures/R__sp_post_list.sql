DROP PROCEDURE IF EXISTS sp_post_list;
DELIMITER $$
CREATE PROCEDURE sp_post_list (
    IN p_post_type_id INT,  -- NULL = all types
    IN p_pinned_only  BIT,           -- 1 = pinned only
    IN p_limit        INT,
    IN p_offset       INT
)
BEGIN
    SELECT  p.post_id,
            p.title,
            p.slug,
            p.is_pinned,
            p.publish_at,
            p.expires_at,
            p.created_at,
            pt.post_type_id,
            pt.name AS 'post_type_name',
            u.user_id AS 'created_by',
            u.display_name AS 'created_by_name',
            i.file_path AS 'featured_image_path'
    FROM post p
    JOIN post_type pt ON pt.post_type_id = p.post_type_id
    JOIN user u
        ON u.user_id = p.created_by
    LEFT JOIN image i
        ON i.image_id = p.featured_image_id
    WHERE (p_post_type_id IS NULL OR p.post_type_id = p_post_type_id)
        AND (p_pinned_only = 0 OR p.is_pinned = 1)
        AND (p.publish_at IS NULL OR p.publish_at <= NOW())
        AND (p.expires_at IS NULL OR p.expires_at > NOW())
    ORDER BY p.is_pinned DESC,
             p.created_at DESC
    LIMIT p_limit OFFSET p_offset;
END$$
DELIMITER ;
