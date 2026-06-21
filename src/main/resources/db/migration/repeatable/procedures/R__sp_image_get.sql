DROP PROCEDURE IF EXISTS sp_image_get;
DELIMITER $$
CREATE PROCEDURE sp_image_get (
    IN      p_image_id      INT
)
BEGIN
    SELECT  i.image_id,
            i.file_name,
            i.mime_type,
            i.file_size,
            i.file_path,
            i.created_by,
            u.display_name AS 'created_by_name'
    FROM image i
    LEFT JOIN user u
        ON u.user_id = i.created_by
    WHERE image_id = p_image_id;
END$$
DELIMITER ;
