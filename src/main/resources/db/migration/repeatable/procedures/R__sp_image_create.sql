DROP PROCEDURE IF EXISTS sp_image_create;
DELIMITER $$
CREATE PROCEDURE sp_image_create (
    IN  p_acting_user_id    INT,
    IN  p_file_name         VARCHAR(255),
    IN  p_mime_type         VARCHAR(100),
    IN  p_file_size         BIGINT,
    IN  p_file_path         VARCHAR(500),
    IN  p_file_hash         CHAR(64),
    OUT p_image_id          INT
)
proc: BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    -- Check if image exists already
    SELECT image_id
    INTO p_image_id
    FROM image
    WHERE file_hash = p_file_hash
    LIMIT 1;

    -- Return existing id and exit
    IF p_image_id IS NOT NULL THEN
        LEAVE proc;
    END IF;

    -- Perform operation
    INSERT INTO image (
        file_name,
        mime_type,
        file_size,
        file_path,
        file_hash,
        created_by
    )
    VALUES (
        p_file_name,
        p_mime_type,
        p_file_size,
        p_file_path,
        p_file_hash,
        p_acting_user_id
    );

    -- Return inserted id
    SET p_image_id = LAST_INSERT_ID();
END proc$$
DELIMITER ;
