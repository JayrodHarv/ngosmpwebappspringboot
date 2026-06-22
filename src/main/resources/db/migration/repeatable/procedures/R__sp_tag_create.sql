DROP PROCEDURE IF EXISTS sp_tag_create;
DELIMITER $$
CREATE PROCEDURE sp_tag_create (
    IN  p_acting_user_id INT,
    IN  p_tag_type_id    INT,
    IN  p_name           VARCHAR(50),
    IN  p_description    VARCHAR(255),
    OUT p_tag_id         INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM tag_type
        WHERE tag_type_id = p_tag_type_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tag type not found';
    END IF;

    INSERT INTO tag (
        tag_type_id,
        name,
        description,
        created_by,
        updated_by
    )
    VALUES (
        p_tag_type_id,
        p_name,
        p_description,
        p_acting_user_id,
        p_acting_user_id
    )
    ON DUPLICATE KEY UPDATE
        tag_id = LAST_INSERT_ID(tag_id);

    SET p_tag_id = LAST_INSERT_ID();
END$$
DELIMITER ;
