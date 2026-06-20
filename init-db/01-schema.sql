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
    image_id        INT                 NOT NULL    AUTO_INCREMENT,
    file_name       VARCHAR(255)        NOT NULL,
    mime_type       VARCHAR(100)        NOT NULL,
    file_size       BIGINT              NOT NULL,
    file_path       VARCHAR(500)        NOT NULL,
    file_hash       CHAR(64)            NOT NULL,
    created_by      INT                 NOT NULL,
    created_at      DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_image_id              PRIMARY KEY (image_id),
    CONSTRAINT uq_image_file_hash       UNIQUE KEY (file_hash)
);

/*----------------------------------- USER ------------------------------------*/

DROP TABLE IF EXISTS user;
CREATE TABLE user (
    user_id         INT                                     NOT NULL    AUTO_INCREMENT,
    email           VARCHAR(255)                            NOT NULL,
    display_name    VARCHAR(50)                             NOT NULL,
    password_hash   VARCHAR(255)                            NOT NULL,
    status          ENUM('ACTIVE', 'INACTIVE', 'LOCKED')    NOT NULL    DEFAULT 'ACTIVE',
    last_seen       DATETIME                                NULL,
    created_at      DATETIME                                NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT                                     NULL,
    updated_at      DATETIME                                NOT NULL    DEFAULT CURRENT_TIMESTAMP   ON UPDATE CURRENT_TIMESTAMP,
    pfp_image_id    INT                                     NULL,

    CONSTRAINT pk_user_id               PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email            UNIQUE KEY (email),
    CONSTRAINT uq_user_display_name     UNIQUE KEY (display_name),
    CONSTRAINT fk_user_updated_by       FOREIGN KEY (updated_by)
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
                ON DELETE RESTRICT;

/*-------------------------------- SYSTEM USER -------------------------------------*/

DROP TABLE IF EXISTS system_user;
CREATE TABLE system_user (
    user_id    INT                      NOT NULL,

    CONSTRAINT pk_system_user           PRIMARY KEY (user_id),
    CONSTRAINT fk_system_user_user_id   FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
);

/*-------------------------------- SYSTEM CONFIG -------------------------------------*/

DROP TABLE IF EXISTS system_config;
CREATE TABLE system_config (
    system_config_id    TINYINT                 NOT NULL    CHECK (system_config_id = 1),
    system_user_id      INT                     NOT NULL,

    CONSTRAINT pk_system_config                 PRIMARY KEY (system_config_id),
    CONSTRAINT fk_system_config_system_user_id  FOREIGN KEY (system_user_id)
        REFERENCES user(user_id)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
);

/*------------------------------ AUDIT LOG (LOOKUP) -------------------------------*/

DROP TABLE IF EXISTS audit_log;
CREATE TABLE audit_log (
    audit_id        BIGINT                              NOT NULL    AUTO_INCREMENT,
    table_name      VARCHAR(100)                        NOT NULL,
    action_type     ENUM('INSERT','UPDATE','DELETE')    NOT NULL,
    record_id       INT                                 NOT NULL,
    changed_by      INT                                 NOT NULL,
    changed_at      DATETIME                            NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    old_values      JSON                                NULL,
    new_values      JSON                                NULL,

    CONSTRAINT pk_audit_log                             PRIMARY KEY (audit_id),

    INDEX idx_audit_log_table_record (table_name, record_id),
    INDEX idx_audit_log_changed_by (changed_by),
    INDEX idx_audit_log_changed_at (changed_at)
);

/*----------------------------------- ROLE ------------------------------------*/

DROP TABLE IF EXISTS role;
CREATE TABLE role (
    role_id         INT             NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(50)     NOT NULL,
    description     VARCHAR(255)    NOT NULL,
    created_by      INT             NOT NULL,
    created_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT             NOT NULL,
    updated_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_role_id               PRIMARY KEY (role_id),
    CONSTRAINT uq_role_name             UNIQUE KEY (name),
    CONSTRAINT fk_role_created_by       FOREIGN KEY (created_by)
            REFERENCES user(user_id)
                ON UPDATE CASCADE
                ON DELETE RESTRICT,
    CONSTRAINT fk_role_updated_by       FOREIGN KEY (updated_by)
            REFERENCES user(user_id)
                ON UPDATE CASCADE
                ON DELETE RESTRICT
);

/*--------------------------------- PERMISSION (LOOKUP) ----------------------------*/

DROP TABLE IF EXISTS permission;
CREATE TABLE permission (
    permission_id   INT             NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(100)    NOT NULL,
    description     VARCHAR(255)    NULL,

    CONSTRAINT pk_permission_id     PRIMARY KEY (permission_id),
    CONSTRAINT uq_permission_name   UNIQUE KEY (name)
);

/*----------------------------------- USER ROLE (JOIN) ------------------------------------*/

DROP TABLE IF EXISTS user_role;
CREATE TABLE user_role (
    user_id         INT             NOT NULL,
    role_id         INT             NOT NULL,
    created_by      INT             NOT NULL,
    created_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_user_role         PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_role_user_id FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_user_role_role_id FOREIGN KEY (role_id)
        REFERENCES role(role_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_user_role_created_by  FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*----------------------------------- ROLE PERMISSION (JOIN) ------------------------------------*/

DROP TABLE IF EXISTS role_permission;
CREATE TABLE role_permission (
    role_id         INT                             NOT NULL,
    permission_id   INT                             NOT NULL,
    created_by      INT                             NOT NULL,
    created_at      DATETIME                        NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_role_permission                   PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_role_permission_role_id           FOREIGN KEY (role_id)
        REFERENCES role(role_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_role_permission_permission_id     FOREIGN KEY (permission_id)
        REFERENCES permission(permission_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_role_permission_created_by        FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*----------------------------------- USER PERMISSION (JOIN) ------------------------------------*/

DROP TABLE IF EXISTS user_permission;
CREATE TABLE user_permission (
    user_id         INT             NOT NULL,
    permission_id   INT             NOT NULL,
    created_by      INT             NOT NULL,
    created_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_user_permission               PRIMARY KEY (user_id, permission_id),
    CONSTRAINT fk_user_permission_user_id       FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_user_permission_permission_id FOREIGN KEY (permission_id)
        REFERENCES permission(permission_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_user_permission_created_by    FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*----------------------------------- TAG TYPE ------------------------------------*/

DROP TABLE IF EXISTS tag_type;
CREATE TABLE tag_type (
    tag_type_id     INT                 NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(50)         NOT NULL,
    description     VARCHAR(100)        NULL,
    color_hex       CHAR(7)             NOT NULL    DEFAULT '#DC2545',
    created_by      INT                 NOT NULL,
    created_at      DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT                 NULL,
    updated_at      DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_tag_type              PRIMARY KEY (tag_type_id),
    CONSTRAINT uq_tag_type_name         UNIQUE KEY (name),
    CONSTRAINT uq_tag_type_color        UNIQUE KEY (color_hex),
    CONSTRAINT fk_tag_type_created_by   FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_tag_type_updated_by    FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*----------------------------------- TAG ------------------------------------*/

DROP TABLE IF EXISTS tag;
CREATE TABLE tag (
    tag_id          INT             NOT NULL    AUTO_INCREMENT,
    tag_type_id     INT             NOT NULL,
    name            VARCHAR(50)     NOT NULL,
    description     VARCHAR(255)    NULL,
    created_by      INT             NOT NULL,
    created_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT             NULL,
    updated_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_tag                   PRIMARY KEY (tag_id),
    CONSTRAINT uq_tag_name              UNIQUE KEY (tag_type_id, name),
    CONSTRAINT fk_tag_tag_type_id       FOREIGN KEY (tag_type_id)
        REFERENCES tag_type(tag_type_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_tag_created_by        FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_tag_updated_by        FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*---------------------------- POST TYPE (LOOKUP) ---------------------------------*/

DROP TABLE IF EXISTS post_type;
CREATE TABLE post_type (
    post_type_id    INT             NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(50)     NOT NULL,
    description     VARCHAR(255)    NOT NULL,

    CONSTRAINT pk_post_type         PRIMARY KEY (post_type_id),
    CONSTRAINT uq_post_type_name    UNIQUE KEY (name)
);

/*-------------------------------- POST -------------------------------------*/

DROP TABLE IF EXISTS post;
CREATE TABLE post (
    post_id             INT                 NOT NULL    AUTO_INCREMENT,
    title               VARCHAR(255)        NOT NULL,
    slug                VARCHAR(255)        NOT NULL,
    -- TODO: Add Markdown Linking functionality (wiki style linking: [[link]])
    content             TEXT                NOT NULL,
    post_type_id        INT                 NOT NULL,
    is_pinned           BIT                 NOT NULL    DEFAULT 0, -- On front page
    publish_at          DATETIME            NULL, -- Schedule publishing of post
    expires_at          DATETIME            NULL, -- Set future expire time
    featured_image_id   INT                 NULL,
    created_by          INT                 NOT NULL,
    created_at          DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by          INT                 NULL,
    updated_at          DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_post                      PRIMARY KEY (post_id),
    CONSTRAINT uq_post_title                UNIQUE KEY (title),
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
            ON DELETE RESTRICT,
    CONSTRAINT fk_post_updated_by           FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*------------------------- HOMEPAGE SECTION (LOOKUP) ------------------------------*/

-- TODO!!!!!

-- DROP TABLE IF EXISTS homepage_section;
-- CREATE TABLE homepage_section (
--     homepage_section_id     INT                 NOT NULL    AUTO_INCREMENT,

    
-- );

/*----------------------------- HOMEPAGE FEATURE ----------------------------------*/

-- TODO!!!!!

-- DROP TABLE IF EXISTS feature;
-- CREATE TABLE feature (
--     feature_id      INT             NOT NULL    AUTO_INCREMENT,

--     display_start   DATETIME        NOT NULL,
--     display_end     DATETIME        NULL,

-- );

/*-------------------------------- POST IMAGE -------------------------------------*/

DROP TABLE IF EXISTS post_image;
CREATE TABLE post_image (
    post_image_id       INT                 NOT NULL    AUTO_INCREMENT,
    post_id             INT                 NOT NULL,
    image_id            INT                 NOT NULL,
    sort_order          INT                 NOT NULL    DEFAULT 0,
    created_by          INT                 NOT NULL,
    created_at          DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by          INT                 NULL,
    updated_at          DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_post_image            PRIMARY KEY (post_image_id),
    CONSTRAINT uq_post_image            UNIQUE KEY (post_id, image_id),
    CONSTRAINT fk_post_image_post_id    FOREIGN KEY (post_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_image_image_id   FOREIGN KEY (image_id)
        REFERENCES image(image_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_image_created_by FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_post_image_updated_by FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*------------------------------ POST TAG (JOIN) -----------------------------------*/

DROP TABLE IF EXISTS post_tag;
CREATE TABLE post_tag (
    post_id         INT                 NOT NULL,
    tag_id          INT                 NOT NULL,
    created_by      INT                 NOT NULL,
    created_at      DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_post_tag              PRIMARY KEY (post_id, tag_id),
    CONSTRAINT fk_post_tag_post_id      FOREIGN KEY (post_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_tag_tag_id       FOREIGN KEY (tag_id)
        REFERENCES tag(tag_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_tag_created_by   FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*----------------------------------- BUILD ------------------------------------*/

DROP TABLE IF EXISTS build; 
CREATE TABLE build (
    build_id            INT                 NOT NULL    AUTO_INCREMENT,
    name                VARCHAR(100)        NOT NULL,
    date_built          DATE                NULL,
    x_coord             INT SIGNED          NULL,
    y_coord             INT SIGNED          NULL,
    z_coord             INT SIGNED          NULL,
    description         TEXT                NULL,
    created_by          INT                 NOT NULL,
    created_at          DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by          INT                 NULL,
    updated_at          DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_build                     PRIMARY KEY (build_id),
    CONSTRAINT uq_build_name                UNIQUE KEY (name),
    CONSTRAINT fk_build_created_by          FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_build_updated_by          FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*------------------------------- BUILD TAG (JOIN) --------------------------------*/

DROP TABLE IF EXISTS build_tag;
CREATE TABLE build_tag (
    build_id        INT                 NOT NULL,
    tag_id          INT                 NOT NULL,
    created_by      INT                 NOT NULL,
    created_at      DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_build_tag             PRIMARY KEY (build_id, tag_id),
    CONSTRAINT fk_build_tag_build_id    FOREIGN KEY (build_id)
        REFERENCES  build(build_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_build_tag_tag_id      FOREIGN KEY (tag_id)
        REFERENCES tag(tag_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_build_tag_created_by  FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*---------------------------------- BUILD IMAGE -----------------------------------*/

DROP TABLE IF EXISTS build_image;
CREATE TABLE build_image (
    build_id        INT             NOT NULL,
    image_id        INT             NOT NULL,
    sort_order      INT             NOT NULL    DEFAULT 0,
    created_by      INT             NOT NULL,
    created_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT             NULL,
    updated_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_build_image               PRIMARY KEY (build_id, image_id),
    CONSTRAINT uq_build_image_sort          UNIQUE KEY (build_id, sort_order),
    CONSTRAINT fk_build_image_build_id      FOREIGN KEY (build_id)
        REFERENCES build(build_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_build_image_image_id      FOREIGN KEY (image_id)
        REFERENCES image(image_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_build_image_created_by    FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_build_image_updated_by    FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    
    INDEX (build_id, sort_order)
);

/*----------------------------------- VOTE ------------------------------------*/

DROP TABLE IF EXISTS vote;
CREATE TABLE vote (
    vote_id         INT                             NOT NULL    AUTO_INCREMENT,
    title           VARCHAR(255)                    NOT NULL,
    description     TEXT                            NULL,
    published_at    DATETIME                        NULL,
    start_time      DATETIME                        NULL,
    end_time        DATETIME                        NULL,
    is_closed_early BOOLEAN                         NOT NULL    DEFAULT FALSE,
    max_selections  INT                             NOT NULL    DEFAULT 1,
    created_by      INT                             NOT NULL,
    created_at      DATETIME                        NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT                             NULL,
    updated_at      DATETIME                        NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT      pk_vote         PRIMARY KEY (vote_id),
    CONSTRAINT      uq_vote_title   UNIQUE KEY (title),
    CONSTRAINT fk_vote_created_by   FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_vote_updated_by   FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    INDEX idx_vote_status_start_time (start_time),
    INDEX idx_vote_start_end (start_time, end_time),
    INDEX idx_vote_created_by (created_by)
);

/*----------------------------------- VOTE OPTION ------------------------------------*/

DROP TABLE IF EXISTS vote_option;
CREATE TABLE vote_option (
    option_id       INT                 NOT NULL    AUTO_INCREMENT,
    vote_id         INT                 NOT NULL,
    title           VARCHAR(255)        NOT NULL,
    description     TEXT                NULL,
    sort_order      INT                 NOT NULL    DEFAULT 0,
    created_by      INT                 NOT NULL,
    created_at      DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT                 NULL,
    updated_at      DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_vote_option           PRIMARY KEY (option_id),
    CONSTRAINT uq_vote_option           UNIQUE KEY (vote_id, title),
    CONSTRAINT fk_vote_option_vote_id   FOREIGN KEY (vote_id)
        REFERENCES vote(vote_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_vote_option_created_by       FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_vote_option_updated_by       FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*----------------------------------- VOTE OPTION IMAGE ------------------------------------*/

DROP TABLE IF EXISTS vote_option_image;
CREATE TABLE vote_option_image (
    option_id       INT                         NOT NULL,
    image_id        INT                         NOT NULL,
    sort_order      INT                         NOT NULL    DEFAULT 0,

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
    user_id         INT                 NOT NULL,
    vote_id         INT                 NOT NULL,
    option_id       INT                 NOT NULL,
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
