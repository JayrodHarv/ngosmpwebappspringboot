DROP PROCEDURE IF EXISTS sp_role_create;
DELIMITER $$
CREATE PROCEDURE sp_role_create (
    IN  p_acting_user_id INT,
    IN  p_name           VARCHAR(50),
    IN  p_description    VARCHAR(255),
    OUT p_role_id        INT
)
BEGIN
    IF EXISTS (SELECT 1 FROM role WHERE name = p_name) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Role name already in use';
    END IF;

    INSERT INTO role (
        name,
        description,
        created_by,
        updated_by
    )
    VALUES (
        p_name,
        p_description,
        p_acting_user_id,
        p_acting_user_id
    );

    SET p_role_id = LAST_INSERT_ID();
END$$
DELIMITER ;
