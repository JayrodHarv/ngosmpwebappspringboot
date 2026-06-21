DROP PROCEDURE IF EXISTS sp_build_create;
DELIMITER $$
CREATE PROCEDURE sp_build_create (
    IN  p_acting_user_id INT,
    IN  p_name           VARCHAR(100),
    IN  p_description    TEXT,
    IN  p_date_built     DATE,
    IN  p_x_coord        INT,
    IN  p_y_coord        INT,
    IN  p_z_coord        INT,
    OUT p_build_id       INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF EXISTS (SELECT 1 FROM build WHERE name = p_name) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build name already in use';
    END IF;

    INSERT INTO build (
        user_id,
        name,
        description,
        date_built,
        x_coord,
        y_coord,
        z_coord
    )
    VALUES (
        p_acting_user_id,
        p_name,
        p_description,
        p_date_built,
        p_x_coord,
        p_y_coord,
        p_z_coord
    );

    SET p_build_id = LAST_INSERT_ID();
END$$
DELIMITER ;
