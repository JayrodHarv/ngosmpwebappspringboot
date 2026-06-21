DROP PROCEDURE IF EXISTS sp_user_register;
DELIMITER $$
CREATE PROCEDURE sp_user_register (
    IN  p_email         VARCHAR(255),
    IN  p_display_name  VARCHAR(50),
    IN  p_password_hash VARCHAR(255),
    OUT p_user_id       INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Create user
    INSERT INTO user (
        email,
        display_name,
        password_hash
    )
    VALUES (
        p_email,
        p_display_name,
        p_password_hash
    );
    
    -- Get user_id of created user
    SET p_user_id = LAST_INSERT_ID();

    -- Assign new user the default 'User' role
    INSERT INTO user_role (
        user_id,
        role_id,
        created_by
    )
    VALUES (
        p_user_id,
        2, -- User role
        1  -- Created by system
    );

    COMMIT;
END$$
DELIMITER ;

