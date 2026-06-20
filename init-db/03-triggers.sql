USE smpdb;

/*****************************************************************************
                                    TRIGGERS
*****************************************************************************/

/*----------------------------------- IMAGE ------------------------------------*/

/*----------- AFTER INSERT ------------*/
DROP TRIGGER IF EXISTS trg_image_after_insert;
CREATE TRIGGER trg_image_after_insert
AFTER INSERT ON image
FOR EACH ROW
BEGIN
    CALL sp_insert_audit_log (
        'image',
        'INSERT',
        NEW.image_id,
        NEW.created_by,
        NULL,
        JSON_OBJECT (
            'file_name',    NEW.file_name,
            'mime_type',    NEW.mime_type,
            'file_size',    NEW.file_size,
            'file_path',    NEW.file_path,
            'file_hash',    NEW.file_hash
        )
    );
END;

/*----------- AFTER UPDATE ------------*/
DROP TRIGGER IF EXISTS trg_image_after_update;
CREATE TRIGGER trg_image_after_update
AFTER UPDATE ON image
FOR EACH ROW
BEGIN
    CALL sp_insert_audit_log (
        'image',
        'UPDATE',
        NEW.image_id,
        NEW.last_updated_by,
        JSON_OBJECT (
            'file_name',    OLD.file_name,
            'mime_type',    OLD.mime_type,
            'file_size',    OLD.file_size,
            'file_path',    OLD.file_path,
            'file_hash',    OLD.file_hash
        ),
        JSON_OBJECT (
            'file_name',    NEW.file_name,
            'mime_type',    NEW.mime_type,
            'file_size',    NEW.file_size,
            'file_path',    NEW.file_path,
            'file_hash',    NEW.file_hash
        )
    );
END;

/*----------- AFTER DELETE ------------*/
DROP TRIGGER IF EXISTS trg_image_after_delete;
CREATE TRIGGER trg_image_after_delete
AFTER DELETE ON image
FOR EACH ROW
BEGIN
    CALL sp_insert_audit_log (
        'image',
        'DELETE',
        OLD.image_id,
        OLD.last_updated_by,
        JSON_OBJECT (
            'file_name',    OLD.file_name,
            'mime_type',    OLD.mime_type,
            'file_size',    OLD.file_size,
            'file_path',    OLD.file_path,
            'file_hash',    OLD.file_hash
        ),
        NULL
    );
END;

/*----------------------------------- USER ------------------------------------*/

/*----------- AFTER INSERT ------------*/
DROP TRIGGER IF EXISTS trg_user_after_insert;
CREATE TRIGGER trg_user_after_insert
AFTER INSERT ON user
FOR EACH ROW
BEGIN
    CALL sp_insert_audit_log (
        'user',
        'INSERT',
        NEW.user_id,
        NEW.user_id, -- User creates itself
        NULL,
        JSON_OBJECT (
            'email',        NEW.email,
            'display_name', NEW.display_name,
            'status',       NEW.status,
            'last_seen',    NEW.last_seen,
            'pfp_image_id', NEW.pfp_image_id
        )
    );
END;

/*----------- AFTER UPDATE ------------*/
DROP TRIGGER IF EXISTS trg_user_after_update;
CREATE TRIGGER trg_user_after_update
AFTER UPDATE ON user
FOR EACH ROW
BEGIN
    CALL sp_insert_audit_log (
        'user',
        'UPDATE',
        NEW.user_id,
        NEW.last_updated_by,
        JSON_OBJECT (
            'email',        OLD.email,
            'display_name', OLD.display_name,
            'status',       OLD.status,
            'last_seen',    OLD.last_seen,
            'pfp_image_id', OLD.pfp_image_id
        ),
        JSON_OBJECT (
            'email',        NEW.email,
            'display_name', NEW.display_name,
            'status',       NEW.status,
            'last_seen',    NEW.last_seen,
            'pfp_image_id', NEW.pfp_image_id
        )
    );
END;

/*----------- AFTER DELETE ------------*/
DROP TRIGGER IF EXISTS trg_user_after_delete;
CREATE TRIGGER trg_user_after_delete
AFTER DELETE ON user
FOR EACH ROW
BEGIN
    CALL sp_insert_audit_log (
        'user',
        'DELETE',
        OLD.user_id,
        OLD.last_updated_by,
        JSON_OBJECT (
            'email',        OLD.email,
            'display_name', OLD.display_name,
            'status',       OLD.status,
            'last_seen',    OLD.last_seen,
            'pfp_image_id', OLD.pfp_image_id
        ),
        NULL
    );
END;