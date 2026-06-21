DROP PROCEDURE IF EXISTS sp_audit_log_list;
DELIMITER $$
CREATE PROCEDURE sp_audit_log_list (
    IN p_acting_user_id INT,
    IN p_table_name     VARCHAR(100),   -- NULL = all tables
    IN p_changed_by     INT,   -- NULL = all users
    IN p_limit          INT,
    IN p_offset         INT
)
BEGIN
    SELECT  al.audit_id,
            al.table_name,
            al.action_type,
            al.record_id,
            al.changed_at,
            al.old_values,
            al.new_values,
            u.user_id      AS changed_by,
            u.display_name AS changed_by_name
    FROM    audit_log al
    JOIN    user u ON u.user_id = al.changed_by
    WHERE   (p_table_name IS NULL OR al.table_name = p_table_name)
      AND   (p_changed_by IS NULL OR al.changed_by = p_changed_by)
    ORDER BY al.changed_at DESC
    LIMIT p_limit OFFSET p_offset;
END$$
DELIMITER ;
