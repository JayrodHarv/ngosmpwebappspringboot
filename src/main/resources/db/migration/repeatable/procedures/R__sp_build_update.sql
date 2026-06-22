DROP PROCEDURE IF EXISTS sp_build_update;
DELIMITER $$
CREATE PROCEDURE sp_build_update (
    IN p_acting_user_id  INT,
    IN p_build_id        INT,
    IN p_name            VARCHAR(100),
    IN p_description     TEXT,
    IN p_date_built      DATE,
    IN p_x_coord         INT,
    IN p_y_coord         INT,
    IN p_z_coord         INT,
    IN p_primary_image_id INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM build WHERE build_id = p_build_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build not found';
    END IF;

    IF p_primary_image_id IS NOT NULL 
        AND NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_primary_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Primary image not found';
    END IF;

    UPDATE build
    SET name             = p_name,
        description      = p_description,
        date_built       = p_date_built,
        x_coord          = p_x_coord,
        y_coord          = p_y_coord,
        z_coord          = p_z_coord,
        primary_image_id = p_primary_image_id
    WHERE build_id = p_build_id;
END$$
DELIMITER ;
