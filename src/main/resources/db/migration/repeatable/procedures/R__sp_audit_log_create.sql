DROP PROCEDURE IF EXISTS sp_audit_log_create;
DELIMITER $$
CREATE PROCEDURE sp_audit_log_create (
    IN p_table_name     VARCHAR(100),
    IN p_action_type    ENUM('INSERT','UPDATE','DELETE'),
    IN p_record_id      INT UNSIGNED,
    IN p_changed_by     INT UNSIGNED,
    IN p_old_values     JSON,
    IN p_new_values     JSON
)
BEGIN
    INSERT INTO audit_log (
        table_name,
        action_type,
        record_id,
        changed_by,
        old_values,
        new_values
    )
    VALUES (
        p_table_name,
        p_action_type,
        p_record_id,
        p_changed_by,
        p_old_values,
        p_new_values
    );
END$$
DELIMITER ;
