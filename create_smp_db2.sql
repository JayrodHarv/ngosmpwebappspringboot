/*
    FILE: 	create_smp_db2.sql
    DATE:	2026-06-02
    AUTHOR:	Jared Harvey
    DESCRIPTION:
        No Go Outside website database creation script
*/

/*****************************************************************************
                            DATABASE CREATION
*****************************************************************************/

DROP DATABASE IF EXISTS smpdb;
CREATE DATABASE smpdb;
USE smpdb;

/*****************************************************************************
                              TABLE CREATION
*****************************************************************************/

/*-------------------------------- IMAGE -------------------------------------*/

DROP TABLE IF EXISTS image;
CREATE TABLE image (
    image_id            INT UNSIGNED        NOT NULL    AUTO_INCREMENT,
    file_name           VARCHAR(255)        NOT NULL,
    mime_type           VARCHAR(100)        NOT NULL,
    file_size           BIGINT UNSIGNED     NOT NULL,
    file_path           VARCHAR(500)        NOT NULL,
    file_hash           CHAR(64)            NOT NULL,
    created_by          INT UNSIGNED        NOT NULL,
    created_at          DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    last_updated_by     INT UNSIGNED        NOT NULL,
    last_updated_at     DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_image_id                  PRIMARY KEY (image_id),
    CONSTRAINT uq_image_file_hash           UNIQUE (file_hash)
);

/*----------------------------------- USER ------------------------------------*/

DROP TABLE IF EXISTS user;
CREATE TABLE user (
    user_id             INT UNSIGNED                            NOT NULL AUTO_INCREMENT,
    email               VARCHAR(255)                            NOT NULL,
    display_name        VARCHAR(50)                             NOT NULL,
    password_hash       VARCHAR(255)                            NOT NULL,
    status              ENUM('ACTIVE', 'INACTIVE', 'LOCKED')    NOT NULL    DEFAULT 'ACTIVE',
    last_seen           DATETIME                                NULL,
    created_at          DATETIME                                NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    last_updated_by     INT UNSIGNED                            NULL,
    last_updated_at     DATETIME                                NOT NULL    DEFAULT CURRENT_TIMESTAMP   ON UPDATE CURRENT_TIMESTAMP,
    pfp_image_id        INT UNSIGNED                            NULL,

    CONSTRAINT pk_user_id               PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email            UNIQUE (email),
    CONSTRAINT uq_user_display_name     UNIQUE (display_name),
    CONSTRAINT fk_user_last_updated_by  FOREIGN KEY (last_updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_user_pfp_image_id     FOREIGN KEY (pfp_image_id)
        REFERENCES image (image_id)
            ON UPDATE CASCADE
            ON DELETE SET NULL,

    INDEX idx_user_status (status)
);

ALTER TABLE image
    ADD CONSTRAINT fk_image_created_by
        FOREIGN KEY (created_by)
            REFERENCES user(user_id)
                ON UPDATE CASCADE
                ON DELETE RESTRICT,
    ADD CONSTRAINT fk_image_last_updated_by
        FOREIGN KEY (last_updated_by)
            REFERENCES user(user_id)
                ON UPDATE CASCADE
                ON DELETE RESTRICT;

/*-------------------------------- SYSTEM USER -------------------------------------*/

DROP TABLE IF EXISTS system_user;
CREATE TABLE system_user (
    user_id    INT UNSIGNED             NOT NULL,

    CONSTRAINT pk_system_user           PRIMARY KEY (user_id),
    CONSTRAINT fk_system_user_user_id   FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
);

/*-------------------------------- SYSTEM CONFIG -------------------------------------*/

DROP TABLE IF EXISTS system_config;
CREATE TABLE system_config (
    system_config_id    TINYINT UNSIGNED        NOT NULL    CHECK (system_config_id = 1),
    system_user_id      INT UNSIGNED            NOT NULL,

    CONSTRAINT pk_system_config                 PRIMARY KEY (system_config_id),
    CONSTRAINT fk_system_config_system_user_id  FOREIGN KEY (system_user_id)
        REFERENCES user(user_id)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
);

/*----------------------------------- TAG TYPE ------------------------------------*/

DROP TABLE IF EXISTS tag_type;
CREATE TABLE tag_type (
    tag_type_id     INT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(50)     NOT NULL,
    description     VARCHAR(100)    NULL,

    CONSTRAINT pk_tag_type          PRIMARY KEY (tag_type_id),
    CONSTRAINT uq_tag_type_name     UNIQUE (name)
);

/*----------------------------------- TAG ------------------------------------*/

DROP TABLE IF EXISTS tag;
CREATE TABLE tag (
    tag_id          INT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    tag_type_id     INT UNSIGNED    NOT NULL,
    name            VARCHAR(50)     NOT NULL,
    description     VARCHAR(255)    NULL,

    CONSTRAINT pk_tag               PRIMARY KEY (tag_id),
    CONSTRAINT uq_tag_name          UNIQUE (tag_type_id, name),
    CONSTRAINT fk_tag_tag_type_id   FOREIGN KEY (tag_type_id)
        REFERENCES tag_type(tag_type_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*---------------------------- POST TYPE (LOOKUP) ---------------------------------*/

DROP TABLE IF EXISTS post_type;
CREATE TABLE post_type (
    post_type_id    INT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(50)     NOT NULL,
    description     VARCHAR(255)    NOT NULL,

    CONSTRAINT pk_post_type         PRIMARY KEY (post_type_id),
    CONSTRAINT uq_post_type_name    UNIQUE (name)
);

/*-------------------------------- POST -------------------------------------*/

DROP TABLE IF EXISTS post;
CREATE TABLE post (
    post_id             INT UNSIGNED        NOT NULL    AUTO_INCREMENT,
    title               VARCHAR(255)        NOT NULL,
    slug                VARCHAR(255)        NOT NULL,
    -- TODO: Add Markdown Linking functionality (wiki style linking: [[link]])
    content             TEXT                NOT NULL,
    post_type_id        INT UNSIGNED        NOT NULL,
    is_pinned           BIT                 NOT NULL    DEFAULT 0, -- On front page
    publish_at          DATETIME            NULL, -- Schedule publishing of post
    expires_at          DATETIME            NULL, -- Set future expire time
    featured_image_id   INT UNSIGNED        NULL,
    created_by          INT UNSIGNED        NOT NULL,
    created_at          DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by          INT UNSIGNED        NULL,
    updated_at          DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_post                      PRIMARY KEY (post_id),
    CONSTRAINT uq_post_title                UNIQUE (title),
    CONSTRAINT fk_post_post_type            FOREIGN KEY (post_type_id)
        REFERENCES post_type
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_post_featured_image_id    FOREIGN KEY (featured_image_id)
        REFERENCES image(image_id)
            ON UPDATE CASCADE
            ON DELETE SET NULL,
    CONSTRAINT fk_post_created_by           FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*------------------------- HOMEPAGE SECTION (LOOKUP) ------------------------------*/

DROP TABLE IF EXISTS homepage_section;
CREATE TABLE homepage_section (
    homepage_section_id     INT UNSIGNED        NOT NULL    AUTO_INCREMENT,

    
)

/*----------------------------- HOMEPAGE FEATURE ----------------------------------*/

DROP TABLE IF EXISTS feature;
CREATE TABLE feature (
    feature_id      INT UNSIGNED    NOT NULL    AUTO_INCREMENT,

    display_start   DATETIME        NOT NULL,
    display_end     DATETIME        NULL,

);

/*-------------------------------- POST IMAGE -------------------------------------*/

DROP TABLE IF EXISTS post_image;
CREATE TABLE post_image (
    post_image_id       INT UNSIGNED        NOT NULL    AUTO_INCREMENT,
    post_id             INT UNSIGNED        NOT NULL,
    image_id            INT UNSIGNED        NOT NULL,
    sort_order          INT UNSIGNED        NOT NULL    DEFAULT 0,

    CONSTRAINT pk_post_image            PRIMARY KEY (post_image_id),
    CONSTRAINT uq_post_image            UNIQUE (post_id, image_id),
    CONSTRAINT fk_post_image_post_id    FOREIGN KEY (post_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_image_image_id   FOREIGN KEY (image_id)
        REFERENCES image(image_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*------------------------------ POST TAG (JOIN) -----------------------------------*/

DROP TABLE IF EXISTS post_tag;
CREATE TABLE post_tag (
    post_id     INT UNSIGNED        NOT NULL,
    tag_id      INT UNSIGNED        NOT NULL,

    CONSTRAINT pk_post_tag          PRIMARY KEY (post_id, tag_id),
    CONSTRAINT fk_post_tag_post_id  FOREIGN KEY (post_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_tag_tag_id   FOREIGN KEY (tag_id)
        REFERENCES tag(tag_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*------------------------------ AUDIT LOG (LOOKUP) -------------------------------*/

DROP TABLE IF EXISTS audit_log;
CREATE TABLE audit_log (
    audit_id        BIGINT UNSIGNED                     NOT NULL    AUTO_INCREMENT,
    table_name      VARCHAR(100)                        NOT NULL,
    action_type     ENUM('INSERT','UPDATE','DELETE')    NOT NULL,
    record_id       INT UNSIGNED                        NOT NULL,
    changed_by      INT UNSIGNED                        NOT NULL,
    changed_at      DATETIME                            NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    old_values      JSON                                NULL,
    new_values      JSON                                NULL,

    CONSTRAINT pk_audit_log                             PRIMARY KEY (audit_id),
    CONSTRAINT fk_audit_log_changed_by                  FOREIGN KEY (changed_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    INDEX idx_audit_log_table_record (table_name, record_id),
    INDEX idx_audit_log_changed_by (changed_by),
    INDEX idx_audit_log_changed_at (changed_at)
);

/*----------------------------------- ROLE ------------------------------------*/

DROP TABLE IF EXISTS role;
CREATE TABLE role (
    role_id         INT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(50)     NOT NULL,
    description     VARCHAR(255)    NOT NULL,
    created_by      INT UNSIGNED    NOT NULL,
    created_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT UNSIGNED    NOT NULL,
    updated_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_role_id           PRIMARY KEY (role_id),
    CONSTRAINT uq_role_name         UNIQUE (name),
    CONSTRAINT fk_role_created_by
        FOREIGN KEY (created_by)
            REFERENCES user(user_id)
                ON UPDATE CASCADE
                ON DELETE RESTRICT,
    CONSTRAINT fk_role_updated_by
        FOREIGN KEY (updated_by)
            REFERENCES user(user_id)
                ON UPDATE CASCADE
                ON DELETE RESTRICT
);

/*--------------------------------- PERMISSION (LOOKUP) ----------------------------*/

DROP TABLE IF EXISTS permission;
CREATE TABLE permission (
    permission_id   INT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(100)    NOT NULL,
    description     VARCHAR(255)    NULL,

    CONSTRAINT pk_permission_id     PRIMARY KEY (permission_id),
    CONSTRAINT uq_permission_name   UNIQUE (name)
);

/*----------------------------------- USER ROLE ------------------------------------*/

DROP TABLE IF EXISTS user_role;
CREATE TABLE user_role (
    user_id         INT UNSIGNED    NOT NULL,
    role_id         INT UNSIGNED    NOT NULL,
    created_by      INT UNSIGNED    NOT NULL,
    created_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_user_role         PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_role_user_id FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_user_role_role_id FOREIGN KEY (role_id)
        REFERENCES role(role_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*----------------------------------- ROLE PERMISSION ------------------------------------*/

DROP TABLE IF EXISTS role_permission;
CREATE TABLE role_permission (
    role_id         INT UNSIGNED                    NOT NULL,
    permission_id   INT UNSIGNED                    NOT NULL,

    CONSTRAINT pk_role_permission                   PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_role_permission_role_id           FOREIGN KEY (role_id)
        REFERENCES role(role_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_role_permission_permission_id     FOREIGN KEY (permission_id)
        REFERENCES permission(permission_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*----------------------------------- USER PERMISSION ------------------------------------*/

DROP TABLE IF EXISTS user_permission;
CREATE TABLE user_permission (
    user_id         INT     NOT NULL,
    permission_id   INT     NOT NULL,

    CONSTRAINT pk_user_permission                   PRIMARY KEY (user_id, permission_id),
    CONSTRAINT fk_user_permission_user_id           FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_user_permission_permission_id     FOREIGN KEY (permission_id)
        REFERENCES permission(permission_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*----------------------------------- BUILD ------------------------------------*/

DROP TABLE IF EXISTS build;
CREATE TABLE build (
    build_id            INT UNSIGNED        NOT NULL    AUTO_INCREMENT,
    user_id             INT UNSIGNED        NOT NULL,
    name                VARCHAR(100)        NOT NULL,
    date_built          DATE                NULL,
    x_coord             INT SIGNED          NULL,
    y_coord             INT SIGNED          NULL,
    z_coord             INT SIGNED          NULL,
    created_at          DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    description         TEXT                NULL,
    primary_image_id    INT UNSIGNED        NULL,

    CONSTRAINT pk_build                     PRIMARY KEY (build_id),
    CONSTRAINT uq_build_name                UNIQUE (name),
    CONSTRAINT fk_build_user_id             FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_build_primary_image_id    FOREIGN KEY (primary_image_id)
        REFERENCES image(image_id)
            ON UPDATE CASCADE
            ON DELETE SET NULL
);

/*------------------------------- BUILD TAG (JOIN) --------------------------------*/

DROP TABLE IF EXISTS build_tag;
CREATE TABLE build_tag (
    build_id        INT UNSIGNED            NOT NULL,
    tag_id          INT UNSIGNED            NOT NULL,

    CONSTRAINT      pk_build_tag            PRIMARY KEY (build_id, tag_id),
    CONSTRAINT      fk_build_tag_build_id   FOREIGN KEY (build_id)
        REFERENCES  build(build_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT

);

/*---------------------------------- BUILD IMAGE -----------------------------------*/

DROP TABLE IF EXISTS build_image;
CREATE TABLE build_image (
    build_image_id  INT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    build_id        INT UNSIGNED    NOT NULL,
    image_id        INT UNSIGNED    NOT NULL,
    sort_order      INT UNSIGNED    NOT NULL    DEFAULT 0,

    CONSTRAINT      pk_build_image  PRIMARY KEY (build_image_id),
    CONSTRAINT      uq_build_image  UNIQUE (build_id, image_id),
    
    INDEX (build_id, sort_order)
);

/*----------------------------------- VOTE ------------------------------------*/

DROP TABLE IF EXISTS vote;
CREATE TABLE vote (
    vote_id         INT UNSIGNED                    NOT NULL    AUTO_INCREMENT,
    user_id         INT UNSIGNED                    NOT NULL,
    title           VARCHAR(255)                    NOT NULL,
    description     TEXT                            NULL,
    status          ENUM('DRAFT','ACTIVE','CLOSED') NOT NULL    DEFAULT 'DRAFT',
    start_time      DATETIME                        NULL,
    end_time        DATETIME                        NULL,
    max_selections  INT UNSIGNED                    NOT NULL    DEFAULT 1,
    created_at      DATETIME                        NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT      pk_vote                         PRIMARY KEY (vote_id),
    CONSTRAINT      uq_vote_title                   UNIQUE (title),
    CONSTRAINT      fk_vote_user_id                 FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*----------------------------------- VOTE OPTION ------------------------------------*/

DROP TABLE IF EXISTS vote_option;
CREATE TABLE vote_option (
    option_id       INT UNSIGNED        NOT NULL    AUTO_INCREMENT,
    vote_id         INT UNSIGNED        NOT NULL,
    title           VARCHAR(255)        NOT NULL,
    description     TEXT                NULL,
    sort_order      INT UNSIGNED        NOT NULL    DEFAULT 0,

    CONSTRAINT pk_vote_option           PRIMARY KEY (option_id),
    CONSTRAINT uq_vote_option           UNIQUE (vote_id, title),
    CONSTRAINT fk_vote_option_vote_id   FOREIGN KEY (vote_id)
        REFERENCES vote(vote_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*----------------------------------- VOTE OPTION IMAGE ------------------------------------*/

DROP TABLE IF EXISTS vote_option_image;
CREATE TABLE vote_option_image (
    option_id       INT UNSIGNED                NOT NULL,
    image_id        INT UNSIGNED                NOT NULL,
    sort_order      INT UNSIGNED                NOT NULL    DEFAULT 0,

    CONSTRAINT pk_vote_option_image             PRIMARY KEY (option_id, image_id),
    CONSTRAINT fk_vote_option_image_option_id   FOREIGN KEY (option_id)
        REFERENCES vote_option(option_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_vote_option_image_image_id   FOREIGN KEY (image_id)
        REFERENCES image(image_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*----------------------------------- USER VOTE ------------------------------------*/

DROP TABLE IF EXISTS user_vote;
CREATE TABLE user_vote (
    user_id         INT UNSIGNED        NOT NULL,
    vote_id         INT UNSIGNED        NOT NULL,
    option_id       INT UNSIGNED        NOT NULL,
    vote_time       DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_user_vote             PRIMARY KEY (user_id, vote_id, option_id),
    CONSTRAINT fk_user_vote_user_id     FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_user_vote_vote_id     FOREIGN KEY (vote_id)
        REFERENCES vote(vote_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_user_vote_option_id   FOREIGN KEY (option_id)
        REFERENCES vote_option(option_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

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
AFTER INSERT ON image
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
AFTER INSERT ON image
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
AFTER INSERT ON user
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
AFTER INSERT ON user
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

/*****************************************************************************
                     LOGGING & USER VALIDATION
*****************************************************************************/

/*----------- INSERT AUDIT LOG ------------*/
DROP PROCEDURE IF EXISTS sp_insert_audit_log;
CREATE PROCEDURE sp_insert_audit_log (
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

END;

/*----------- VALIDATE USER ------------*/
DROP PROCEDURE IF EXISTS sp_validate_user;
CREATE PROCEDURE sp_validate_user (
    IN p_user_id            INT UNSIGNED
)
BEGIN
    
    DECLARE v_status            VARCHAR(20);
    
    -- Validate user exists with active status
    SELECT status
    INTO v_status
    FROM user
    WHERE user_id = p_user_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User does not exist';
    END IF;

    IF v_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User is not active';
    END IF;

    -- Update user last_seen
    UPDATE user
    SET last_seen = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;

END;

/*----------- REQUIRE PERMISSION ------------*/
DROP PROCEDURE IF EXISTS sp_require_permission;
CREATE PROCEDURE sp_require_permission (
    IN p_user_id INT UNSIGNED,
    IN p_permission_name VARCHAR(100)
)
BEGIN
    DECLARE v_user_status VARCHAR(20);
    DECLARE v_permission_count INT UNSIGNED DEFAULT 0;

    -- Validate user exists and is active
    SELECT status
    INTO v_user_status
    FROM user
    WHERE user_id = p_user_id;

    IF v_user_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User does not exist';
    END IF;

    IF v_user_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User is not active';
    END IF;

    -- Check permission
    SELECT COUNT(*)
    INTO v_permission_count
    FROM user_role ur
    JOIN role_permission rp
        ON rp.role_id = ur.role_id
    JOIN permission p
        ON p.permission_id = rp.permission_id
    WHERE ur.user_id = p_user_id
      AND p.name = p_permission_name;

    IF v_permission_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = CONCAT(
                'Missing permission: ',
                p_permission_name
            );
    END IF;

    -- Update activity timestamp
    UPDATE user
    SET last_seen = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;

END;

/*----------- REQUIRE ACCESS ------------*/
DROP PROCEDURE IF EXISTS sp_require_access;
CREATE PROCEDURE sp_require_access (
    IN p_acting_user_id INT UNSIGNED,
    IN p_target_user_id INT UNSIGNED,
    IN p_own_permission VARCHAR(100),
    IN p_all_permission VARCHAR(100)
)
BEGIN
    DECLARE v_has_permission INT UNSIGNED DEFAULT 0;

    IF p_acting_user_id = p_target_user_id THEN

        CALL sp_require_permission(
            p_acting_user_id,
            p_own_permission
        );

    ELSE

        CALL sp_require_permission(
            p_acting_user_id,
            p_all_permission
        );

    END IF;

END;

/*****************************************************************************
                    STORED PROCEDURES / CRUD FUNCTIONS
*****************************************************************************/

/*----------------------------------- IMAGE ------------------------------------*/

/*----------- INSERT IMAGE ------------*/
DROP PROCEDURE IF EXISTS sp_insert_image;
CREATE PROCEDURE sp_insert_image (
    IN  p_file_name         VARCHAR(255),
    IN  p_mime_type         VARCHAR(100),
    IN  p_file_size         BIGINT UNSIGNED,
    IN  p_file_path         VARCHAR(500),
    IN  p_file_hash         CHAR(64),
    IN  p_acting_user_id    INT UNSIGNED,
    OUT p_image_id          INT UNSIGNED
)
BEGIN

    -- Validate user
    CALL sp_require_permission (p_acting_user_id, 'IMAGE_CREATE');

    -- Check if image exists already
    SELECT  image_id
    INTO    p_image_id
    FROM    image
    WHERE   file_hash = p_file_hash
    LIMIT   1;

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

END;

/*----------- UPDATE IMAGE ------------*/
DROP PROCEDURE IF EXISTS sp_update_image;
CREATE PROCEDURE sp_update_image (
    IN  p_image_id          INT UNSIGNED,
    IN  p_file_name         VARCHAR(255),
    IN  p_mime_type         VARCHAR(100),
    IN  p_file_size         BIGINT UNSIGNED,
    IN  p_file_path         VARCHAR(500),
    IN  p_file_hash         CHAR(64),
    IN  p_acting_user_id    INT UNSIGNED
)
BEGIN

    -- Get image creator
    DECLARE v_image_user_id INT UNSIGNED;

    SELECT created_by
    INTO v_image_user_id
    FROM image
    WHERE image_id = p_image_id;

    IF v_image_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Image not found';
    END IF;

    -- Validate user
    CALL sp_require_access(
        p_acting_user_id,
        v_image_user_id,
        'IMAGE_UPDATE_OWN',
        'IMAGE_UPDATE_ALL'
    );

    -- Perform operation
    UPDATE  image
    SET     file_name = p_file_name,
            mime_type = p_mime_type,
            file_size = p_file_size,
            file_path = p_file_path,
            file_hash = p_file_hash

    WHERE   image_id = p_image_id;

END;

/*----------- DELETE IMAGE ------------*/
DROP PROCEDURE IF EXISTS sp_delete_image;
CREATE PROCEDURE sp_delete_image (
    IN p_image_id           INT UNSIGNED,
    IN p_acting_user_id     INT UNSIGNED
)
BEGIN

    -- Get image creator
    DECLARE v_image_user_id INT UNSIGNED;

    SELECT created_by
    INTO v_image_user_id
    FROM image
    WHERE image_id = p_image_id;

    IF v_image_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Image not found';
    END IF;

    -- Validate user
    CALL sp_require_access(
        p_acting_user_id,
        v_image_user_id,
        'IMAGE_DELETE_OWN',
        'IMAGE_DELETE_ALL'
    );

    -- Perform operation
    DELETE  FROM image
    WHERE   image_id = p_image_id;

END;

/*----------- GET IMAGE ------------*/
DROP PROCEDURE IF EXISTS sp_get_image;
CREATE PROCEDURE sp_get_image (
    IN      p_image_id      INT UNSIGNED
)
BEGIN
    SELECT  i.image_id,
            i.file_name,
            i.mime_type,
            i.file_size,
            i.file_path,

            u.user_id,
            u.display_name AS 'created_by_name'

    FROM image i
    LEFT JOIN user u
        ON u.user_id = i.created_by
    WHERE image_id = p_image_id;
END;

/*----------- GET IMAGES ------------*/
DROP PROCEDURE IF EXISTS sp_get_images;
CREATE PROCEDURE sp_get_images (
    IN p_limit  INT UNSIGNED,
    IN p_offset INT UNSIGNED
)
BEGIN
    SELECT  i.image_id,
            i.file_name,
            i.mime_type,
            i.file_size,
            i.file_path,

            u.user_id,
            u.display_name AS 'created_by_name'
            
    FROM image i
    LEFT JOIN user u
        ON u.user_id = i.created_by
    WHERE image_id = p_image_id
    LIMIT p_limit OFFSET p_offset;
END;

/*----------------------------------- USER ------------------------------------*/

/*----------- INSERT USER ------------*/
DROP PROCEDURE IF EXISTS sp_insert_user;
CREATE PROCEDURE sp_insert_user (
    IN  p_email         VARCHAR(255),
    IN  p_display_name  VARCHAR(50),
    IN  p_password_hash VARCHAR(255),
    OUT p_user_id       INT UNSIGNED
)
BEGIN

    -- Check if email already taken
    IF EXISTS (SELECT 1 FROM users WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Email already in use';
    END IF;

    -- Check if display_name already taken
    IF EXISTS (SELECT 1 FROM users WHERE display_name = p_display_name) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Display name already in use';
    END IF;

    -- Perform operation
    INSERT INTO user (
        email,
        display_name,
        password_hash,
        created_at
    )
    VALUES (
        p_email,
        p_display_name,
        p_password_hash,
        CURRENT_TIMESTAMP
    );

    -- Return inserted id
    SET p_user_id = LAST_INSERT_ID();

END;

/*----------- UPDATE USER ------------*/
DROP PROCEDURE IF EXISTS sp_update_user;
CREATE PROCEDURE sp_update_user (
    IN  p_user_id           INT UNSIGNED,
    IN  p_display_name      VARCHAR(50),
    IN  p_password_hash     VARCHAR(255),
    IN  p_status            ENUM('ACTIVE', 'INACTIVE', 'LOCKED'),
    IN  p_pfp_image_id      INT UNSIGNED,
    IN  p_acting_user_id    INT UNSIGNED
)
BEGIN

    -- Check that user performing operation is either the user or has the proper privileges
    DECLARE v_is_self           INT UNSIGNED DEFAULT 0;
    DECLARE v_has_permission    INT UNSIGNED DEFAULT 0;

    -- Self check
    SET v_is_self = (p_user_id = p_acting_user_id);

    -- Permission check
    SELECT COUNT(*)
    INTO v_is_admin
    FROM user_role ur
    JOIN role_permission rp
        ON rp.role_id = ur.role_id
    JOIN permission p ON p.permission_id = rp.permission_id
    WHERE ur.user_id = p_acting_user


    -- Check if display_name already taken
    IF EXISTS (SELECT 1 FROM users WHERE display_name = p_display_name) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Display name already in use';
    END IF;

    -- Check that image has been uploaded already
    IF NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_pfp_image_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Image not uploaded.';
    END IF;

    -- Perform operation
    UPDATE  user
    SET     display_name,
            password_hash,
            status,
            pfp_image_id

    WHERE   user_id = p_user_id;

END;

/*----------- DELETE USER ------------*/
DROP PROCEDURE IF EXISTS sp_delete_user;
CREATE PROCEDURE sp_delete_user (
    IN p_user_id            INT UNSIGNED,
    IN p_acting_user_id     INT UNSIGNED
)
BEGIN

    -- Validate user
    CALL sp_validate_user(p_acting_user_id);

    -- Check if acting user is user
    DECLARE v_is_self   INT UNSIGNED DEFAULT 0;
    SET v_is_self = (p_user_id = p_acting_user_id);

    IF 


    -- Set user status to 'INACTIVE'
    UPDATE  user
    SET     last_updated_by = p_changed_by
    WHERE   image_id = p_image_id;

    -- Perform operation
    DELETE  FROM image
    WHERE   image_id = p_image_id;

END;

/*----------- GET USER ------------*/
DROP PROCEDURE IF EXISTS sp_get_image;
CREATE PROCEDURE sp_get_image (
    IN      p_image_id      INT UNSIGNED
)
BEGIN
    SELECT  i.image_id,
            i.file_name,
            i.mime_type,
            i.file_size,
            i.file_path,

            u.user_id,
            u.display_name AS 'created_by_name'

    FROM image i
    LEFT JOIN user u
        ON u.user_id = i.created_by
    WHERE image_id = p_image_id;
END;

/*----------- GET ALL IMAGES ------------*/
DROP PROCEDURE IF EXISTS sp_get_all_images;
CREATE PROCEDURE sp_get_all_images ()
BEGIN
    SELECT  i.image_id,
            i.file_name,
            i.mime_type,
            i.file_size,
            i.file_path,

            u.created_by,
            u.display_name AS 'created_by_name'
            
    FROM image i
    LEFT JOIN user u
        ON u.user_id = i.created_by
    WHERE image_id = p_image_id;
END;

/*----------------------------------- AUDIT LOG ------------------------------------*/

-- TODO: Implement crud functions for audit log, for now just view in database

/*----------------------------------- ROLE ------------------------------------*/

/*----------------------------------- PERMISSION ------------------------------------*/

-- No crud stored procedures needed, only system user allowed to perform crud functions on permission table

/*----------- GET ALL PERMISSIONS ------------*/

/*----------------------------------- USER ROLE ------------------------------------*/

/*----------------------------------- ROLE PERMISSION ------------------------------------*/

/*----------- GET ROLE PERMISSIONS ------------*/

/*----------------------------------- USER PERMISSION ------------------------------------*/

/*----------------------------------- TAG TYPE ------------------------------------*/

/*----------------------------------- TAG ------------------------------------*/

/*----------------------------------- BUILD ------------------------------------*/

/*----------------------------------- BUILD TAG ------------------------------------*/

/*----------------------------------- BUILD IMAGE ------------------------------------*/

/*----------------------------------- VOTE ------------------------------------*/

/*----------------------------------- VOTE OPTION ------------------------------------*/

/*----------------------------------- VOTE OPTION IMAGE ------------------------------------*/

/*----------------------------------- USER VOTE ------------------------------------*/

/*****************************************************************************
                            GENERATE INITIAL DATA
*****************************************************************************/

/*----------------------------------- PERMISSIONS ------------------------------------*/

-- Create system user (used to seed initial data, cannot be logged into or deleted)
-- For use only in the database
INSERT INTO user (
    user_id,
    email,
    display_name,
    password_hash,
    status
)
VALUES (
    1,
    'system@localhost',
    'SYSTEM',
    '',
    'ACTIVE'
);

-- Make this user the system user
INSERT INTO system_user (user_id) VALUES (1);

-- Create system-made roles (can only be modified by system user)
INSERT INTO role (
    name,
    description,
    created_by,
    updated_by
)
VALUES
(
    'ADMIN',
    'Full administrative access',
    1,
    1
),
(
    'USER',
    'Standard user access',
    1,
    1
);

-- Create permissions (can only be modified by system user)
INSERT INTO permission (name, description)
VALUES
    /* Images */
    ('IMAGE_VIEW'),
    ('IMAGE_CREATE'),
    ('IMAGE_EDIT_OWN'),
    ('IMAGE_EDIT_ALL'),
    ('IMAGE_DELETE_OWN'),
    ('IMAGE_DELETE_ALL'),

    /* Users */
    ('USER_VIEW'),
    ('USER_LOCK'),
    ('USER_EDIT_OWN'),
    ('USER_EDIT_ALL'),
    ('USER_DELETE_OWN'),
    ('USER_DELETE_ALL'),

    /* Roles */
    ('ROLE_VIEW'),
    ('ROLE_ASSIGN'),
    ('ROLE_CREATE'),
    ('ROLE_EDIT'),
    ('ROLE_DELETE'),

    /* Permissions */
    ('PERMISSION_VIEW'),
    ('PERMISSION_ASSIGN'),

    /* Builds */
    ('BUILD_VIEW'),
    ('BUILD_CREATE'),
    ('BUILD_EDIT_OWN'),
    ('BUILD_EDIT_ALL'),
    ('BUILD_DELETE_OWN'),
    ('BUILD_DELETE_ALL'),

    /* Tags */
    ('TAG_VIEW'),
    ('TAG_CREATE'),
    ('TAG_EDIT'),
    ('TAG_DELETE'),

    /* Votes */
    ('VOTE_VIEW'),
    ('VOTE_CREATE'),
    ('VOTE_EDIT_OWN'),
    ('VOTE_EDIT_ALL'),
    ('VOTE_DELETE_OWN'),
    ('VOTE_DELETE_ALL'),
    ('VOTE_CAST'),

    /* Audit */
    ('AUDIT_VIEW'),

    /* Posts */
    ('POST_CREATE'),
    ('POST_EDIT_OWN'),
    ('POST_EDIT_ALL'),
    ('POST_DELETE_OWN'),
    ('POST_DELETE_ALL'),
    ('POST_PUBLISH_NEWS'),
    ('POST_PUBLISH_ANNOUNCEMENT');

-- Assign all permissions to ADMIN role (role_id = 1)
INSERT INTO role_permission (role_id, permission_id)
SELECT 1, permission_id
FROM permission;

-- Assign permissions to USER role (role_id = 2)
INSERT INTO role_permission (role_id, permission_id)
SELECT 2, permission_id
FROM permission
WHERE name IN (
    'IMAGE_CREATE',

    'USER_EDIT_OWN',
    'USER_DELETE_OWN',

    'BUILD_VIEW',
    'BUILD_CREATE',
    'BUILD_EDIT_OWN',
    'BUILD_DELETE_OWN',

    'VOTE_VIEW',
    'VOTE_CAST',

    'POST_CREATE',
    'POST_EDIT_OWN',
    'POST_DELETE_OWN'
);

INSERT INTO post_type (name, description)
VALUES
    ('ANNOUNCEMENT', 'Important announcements'),
    ('NEWS', 'Server news and updates'),
    ('LORE', 'In-universe lore'),
    ('HISTORY', 'Historical records and timelines'),
    ('GUIDE', 'Player guides and tutorials');