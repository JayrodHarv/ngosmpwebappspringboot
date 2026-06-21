DROP PROCEDURE IF EXISTS sp_build_image_list;
DELIMITER $$
CREATE PROCEDURE sp_build_image_list (
    IN p_build_id INT
)
BEGIN
    SELECT  bi.build_image_id,
            bi.sort_order,
            i.image_id,
            i.file_path,
            i.file_name,
            i.mime_type
    FROM build_image bi
    JOIN image i
        ON i.image_id = bi.image_id
    WHERE bi.build_id = p_build_id
    ORDER BY bi.sort_order;
END$$
DELIMITER ;
