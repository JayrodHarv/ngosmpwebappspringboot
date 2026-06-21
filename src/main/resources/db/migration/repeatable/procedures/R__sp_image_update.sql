DROP PROCEDURE IF EXISTS sp_image_update;
DELIMITER $$
CREATE PROCEDURE sp_image_update (
    IN p_acting_user_id    INT,
    IN p_image_id          INT,
    IN p_file_name         VARCHAR(255),
    IN p_mime_type         VARCHAR(100),
    IN p_file_size         BIGINT,
    IN p_file_path         VARCHAR(500),
    IN p_file_hash         CHAR(64)
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    -- Perform operation
    UPDATE image
    SET     file_name = p_file_name,
            mime_type = p_mime_type,
            file_size = p_file_size,
            file_path = p_file_path,
            file_hash = p_file_hash
    WHERE image_id = p_image_id;
END$$
DELIMITER ;
