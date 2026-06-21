DROP PROCEDURE IF EXISTS sp_build_get;
DELIMITER $$
CREATE PROCEDURE sp_build_get (
    IN p_build_id INT
)
BEGIN
    SELECT  b.build_id,
            b.name,
            b.description,
            b.date_built,
            b.x_coord,
            b.y_coord,
            b.z_coord,
            b.created_at,
            b.primary_image_id,
            pi.file_path  AS primary_image_path,
            u.user_id,
            u.display_name AS owner_name
    FROM build b
    JOIN user u
        ON u.user_id = b.user_id
    LEFT JOIN image pi
        ON pi.image_id = b.primary_image_id
    WHERE b.build_id = p_build_id;
END$$
DELIMITER ;
