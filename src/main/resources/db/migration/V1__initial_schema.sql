/*****************************************************************************
                              TABLE CREATION
*****************************************************************************/

/*-------------------------------- FILE -------------------------------------*/

CREATE TABLE file (
    file_id         INT UNSIGNED            NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(255),           NOT NULL,
    file_type       ENUM('IMAGE', 'VIDEO')  NOT NULL,
    hash            CHAR(64)                NOT NULL,
    path            VARCHAR(500)            NOT NULL,
    extension       VARCHAR(20)             NOT NULL,
    mime_type       VARCHAR(100)            NOT NULL,
    size_bytes      BIGINT UNSIGNED         NOT NULL,
    created_by      INT UNSIGNED            NOT NULL,
    created_at      DATETIME                NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_file              PRIMARY KEY (file_id),
    CONSTRAINT uq_file_hash         UNIQUE KEY (hash)
);

/*----------------------------------- USER ------------------------------------*/

CREATE TABLE user (
    user_id         INT UNSIGNED                            NOT NULL    AUTO_INCREMENT,
    email           VARCHAR(255)                            NOT NULL,
    display_name    VARCHAR(50)                             NOT NULL,
    password_hash   VARCHAR(255)                            NOT NULL,
    status          ENUM('ACTIVE', 'INACTIVE', 'LOCKED')    NOT NULL    DEFAULT 'ACTIVE',
    pfp_image_id    INT UNSIGNED                            NULL,
    created_at      DATETIME                                NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT UNSIGNED                            NULL,
    updated_at      DATETIME                                NOT NULL    DEFAULT CURRENT_TIMESTAMP   ON UPDATE CURRENT_TIMESTAMP,

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

ALTER TABLE file
    ADD CONSTRAINT fk_file_created_by
        FOREIGN KEY (created_by)
            REFERENCES user(user_id)
                ON UPDATE CASCADE
                ON DELETE RESTRICT;

ALTER TABLE file
    ADD INDEX idx_file_created_by (created_by);

/*----------------------------------- IMAGE (DETAIL) ------------------------------------*/

CREATE TABLE image (
    image_id    INT UNSIGNED     NOT NULL,
    width_px    INT UNSIGNED     NOT NULL,
    height_px   INT UNSIGNED     NOT NULL,

    CONSTRAINT pk_image             PRIMARY KEY (image_id),
    CONSTRAINT fk_image_image_id     FOREIGN KEY (image_id)
        REFERENCES file(file_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*----------------------------------- VIDEO (DETAIL) ------------------------------------*/

CREATE video (
    video_id                INT UNSIGNED     NOT NULL,
    width_px                INT UNSIGNED     NOT NULL,
    height_px               INT UNSIGNED     NOT NULL,
    duration_seconds        INT UNSIGNED     NOT NULL,
    thumbnail_image_id      INT UNSIGNED     NULL,

    CONSTRAINT pk_video                     PRIMARY KEY (video_id),
    CONSTRAINT fk_video_video_id            FOREIGN KEY (video_id)
        REFERENCES file(file_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_video_thumbnail_image_id  FOREIGN KEY (thumbnail_image_id)
        REFERENCES image(image_id)
            ON UPDATE CASCADE
            ON DELETE SET NULL
);

/*-------------------------------- SYSTEM USER -------------------------------------*/

CREATE TABLE system_user (
    user_id    INT UNSIGNED     NOT NULL,

    CONSTRAINT pk_system_user           PRIMARY KEY (user_id),
    CONSTRAINT fk_system_user_user_id   FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
);

/*-------------------------------- SYSTEM CONFIG -------------------------------------*/

CREATE TABLE system_config (
    system_config_id    TINYINT UNSIGNED    NOT NULL    CHECK (system_config_id = 1),
    system_user_id      INT UNSIGNED        NOT NULL,

    CONSTRAINT pk_system_config                 PRIMARY KEY (system_config_id),
    CONSTRAINT fk_system_config_system_user_id  FOREIGN KEY (system_user_id)
        REFERENCES user(user_id)
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
);

/*----------------------------------- ROLE ------------------------------------*/

CREATE TABLE role (
    role_id         INT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(50)     NOT NULL,
    description     VARCHAR(255)    NOT NULL,
    color_hex       CHAR(7)         NULL,
    created_by      INT UNSIGNED    NOT NULL,
    created_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT UNSIGNED    NOT NULL,
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

CREATE TABLE permission (
    permission_id   INT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(100)    NOT NULL,
    description     VARCHAR(255)    NULL,

    CONSTRAINT pk_permission_id     PRIMARY KEY (permission_id),
    CONSTRAINT uq_permission_name   UNIQUE KEY (name)
);

/*----------------------------------- USER ROLE (JOIN) ------------------------------------*/

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
            ON DELETE CASCADE,
    CONSTRAINT fk_user_role_created_by  FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    INDEX idx_user_role_role_id (role_id)
);

/*----------------------------------- ROLE PERMISSION (JOIN) ------------------------------------*/

CREATE TABLE role_permission (
    role_id         INT UNSIGNED    NOT NULL,
    permission_id   INT UNSIGNED    NOT NULL,
    created_by      INT UNSIGNED    NOT NULL,
    created_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,

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
            ON DELETE RESTRICT,

    INDEX idx_role_permission_permission_id (permission_id)
);

/*----------------------------------- USER PERMISSION (JOIN) ------------------------------------*/

CREATE TABLE user_permission (
    user_id         INT UNSIGNED            NOT NULL,
    permission_id   INT UNSIGNED            NOT NULL,
    effect          ENUM('GRANT','DENY')    NOT NULL    DEFAULT 'GRANT',
    created_by      INT UNSIGNED            NOT NULL,
    created_at      DATETIME                NOT NULL    DEFAULT CURRENT_TIMESTAMP,

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
            ON DELETE RESTRICT,

    INDEX idx_user_permission_permission_id (permission_id)
);

/*----------------------------------- TAG TYPE ------------------------------------*/

CREATE TABLE tag_type (
    tag_type_id     INT UNSIGNED        NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(50)         NOT NULL,
    description     VARCHAR(100)        NULL,
    color_hex       CHAR(7)             NOT NULL    DEFAULT '#DC2545',
    created_by      INT UNSIGNED        NOT NULL,
    created_at      DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT UNSIGNED        NULL,
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

CREATE TABLE tag (
    tag_id          INT UNSIGNED   	NOT NULL    AUTO_INCREMENT,
    tag_type_id     INT UNSIGNED    NOT NULL,
    name            VARCHAR(50)     NOT NULL,
    description     VARCHAR(255)    NULL,
    created_by      INT UNSIGNED    NOT NULL,
    created_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT UNSIGNED    NULL,
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

/*----------------------------------- POST TYPE ------------------------------------*/

CREATE TABLE post_type (
    post_type_id    INT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    name            VARCHAR(50)     NOT NULL,
    slug            VARCHAR(50)     NOT NULL,
    description     VARCHAR(255)    NULL,
    is_system       BIT             NOT NULL    DEFAULT 0,
    created_by      INT UNSIGNED   	NOT NULL,
    created_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT UNSIGNED    NULL,
    updated_at      DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_post_type              PRIMARY KEY (post_type_id),
    CONSTRAINT uq_post_type_name         UNIQUE KEY (name),
    CONSTRAINT uq_post_type_slug         UNIQUE KEY (slug),
    CONSTRAINT fk_post_type_created_by   FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_post_type_updated_by   FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT
);

/*----------------------------- POST TYPE FIELD (DEFINITION) -----------------------------*/

CREATE TABLE post_type_field (
    field_id        INT UNSIGNED                                                            NOT NULL    AUTO_INCREMENT,
    post_type_id    INT UNSIGNED                                                            NOT NULL,
    field_key       VARCHAR(64)                                                             NOT NULL,
    label           VARCHAR(128)                                                            NOT NULL,
    data_type       ENUM('TEXT','NUMBER','BOOLEAN','DATE','DATETIME','URL','SELECT','FILE')	NOT NULL,
    is_required     BIT                                                                     NOT NULL    DEFAULT 0,
    sort_order      INT UNSIGNED                                                            NOT NULL    DEFAULT 0,
    options         JSON                                                                    NULL,
    created_by      INT UNSIGNED                                                            NOT NULL,
    created_at      DATETIME                                                                NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT UNSIGNED                                                            NULL,
    updated_at      DATETIME                                                                NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_post_type_field                PRIMARY KEY (field_id),
    CONSTRAINT uq_post_type_field_key            UNIQUE KEY (post_type_id, field_key),
    CONSTRAINT fk_post_type_field_post_type_id   FOREIGN KEY (post_type_id)
        REFERENCES post_type(post_type_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_type_field_created_by     FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_post_type_field_updated_by     FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    INDEX idx_post_type_field_post_type_id (post_type_id)
);

/*-------------------------------- POST -------------------------------------*/

CREATE TABLE post (
    post_id         INT UNSIGNED                                        NOT NULL    AUTO_INCREMENT,
    post_type_id    INT UNSIGNED                                        NOT NULL,
    title           VARCHAR(255)                                        NOT NULL,
    slug            VARCHAR(255)                                        NOT NULL,
    body            MEDIUMTEXT                                          NOT NULL,
    status          ENUM('DRAFT','PUBLISHED','ARCHIVED')                NOT NULL    DEFAULT 'DRAFT',
    pinned          BIT                                                 NOT NULL    DEFAULT 0,
    view_count      BIGINT UNSIGNED                                     NOT NULL    DEFAULT 0,
    like_count      BIGINT UNSIGNED                                     NOT NULL    DEFAULT 0,
    published_at    DATETIME                                            NULL,
    created_by      INT UNSIGNED                                        NOT NULL,
    created_at      DATETIME                                            NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT UNSIGNED                                        NULL,
    updated_at      DATETIME                                            NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_post                      PRIMARY KEY (post_id),
    CONSTRAINT uq_post_title                UNIQUE KEY (title),
    CONSTRAINT uq_post_slug                 UNIQUE KEY (slug),
    CONSTRAINT fk_post_post_type_id         FOREIGN KEY (post_type_id)
        REFERENCES post_type(post_type_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_post_created_by           FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_post_updated_by           FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    INDEX idx_post_post_type_id (post_type_id),
    INDEX idx_post_status (status),
    INDEX idx_post_created_by (created_by),
    INDEX idx_post_published_at (published_at)
);

/*------------------------------ POST TAG (JOIN) -----------------------------------*/

CREATE TABLE post_tag (
    post_id         INT UNSIGNED        NOT NULL,
    tag_id          INT UNSIGNED        NOT NULL,
    sort_order      INT UNSIGNED        NOT NULL    DEFAULT 0,
    created_by      INT UNSIGNED        NOT NULL,
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
            ON DELETE RESTRICT,

    INDEX idx_post_tag_tag_id (tag_id)
);

/*----------------------------- POST FIELD VALUE -----------------------------*/

CREATE TABLE post_field_value (
    post_id         INT UNSIGNED    NOT NULL,
    field_id        INT UNSIGNED    NOT NULL,
    value_text      VARCHAR(1024)   NULL,
    value_number    DECIMAL(20,6)   NULL,
    value_boolean   BIT             NULL,
    value_date      DATE            NULL,
    value_datetime  DATETIME        NULL,

    CONSTRAINT pk_post_field_value            PRIMARY KEY (post_id, field_id),
    CONSTRAINT fk_post_field_value_post_id    FOREIGN KEY (post_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_field_value_field_id   FOREIGN KEY (field_id)
        REFERENCES post_type_field(field_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,

    INDEX idx_post_field_value_field_text      (field_id, value_text),
    INDEX idx_post_field_value_field_number    (field_id, value_number),
    INDEX idx_post_field_value_field_boolean   (field_id, value_boolean),
    INDEX idx_post_field_value_field_date      (field_id, value_date),
    INDEX idx_post_field_value_field_datetime  (field_id, value_datetime)
);

/*----------------------------- POST FILE (JOIN) -----------------------------*/

CREATE TABLE post_file (
    post_id     INT UNSIGNED                NOT NULL,
    file_id     INT UNSIGNED                NOT NULL,
    role        ENUM('COVER','GALLERY')     NOT NULL    DEFAULT 'GALLERY',
    caption     VARCHAR(255)                NULL,
    sort_order  INT UNSIGNED                NOT NULL    DEFAULT 0,
    created_by  INT UNSIGNED                NOT NULL,
    created_at  DATETIME                    NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_post_file             PRIMARY KEY (post_id, file_id),
    CONSTRAINT fk_post_file_post_id     FOREIGN KEY (post_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_file_file_id     FOREIGN KEY (file_id)
        REFERENCES file(file_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_post_file_created_by  FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    INDEX idx_post_file_file_id (file_id)
);

/*----------------------------- POST REFERENCE (JOIN) -----------------------------*/

CREATE TABLE post_reference (
    post_id               INT UNSIGNED    NOT NULL,
    referenced_post_id    INT UNSIGNED    NOT NULL,
    note                  VARCHAR(255)    NULL,
    sort_order            INT UNSIGNED    NOT NULL    DEFAULT 0,
    created_by            INT UNSIGNED    NOT NULL,
    created_at            DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_post_reference                     PRIMARY KEY (post_id, referenced_post_id),
    CONSTRAINT fk_post_reference_post_id             FOREIGN KEY (post_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_reference_referenced_post_id  FOREIGN KEY (referenced_post_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_reference_created_by          FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT chk_post_reference_not_self
        CHECK (post_id <> referenced_post_id),

    INDEX idx_post_reference_referenced_post_id (referenced_post_id)
);

/*-------------------------------- BUILD (DETAIL) ----------------------------------*/

CREATE TABLE build (
    build_id            INT UNSIGNED        NOT NULL,
    date_built          DATE                NULL,
    x_coord             INT SIGNED          NULL,
    y_coord             INT SIGNED          NULL,
    z_coord             INT SIGNED          NULL,

    CONSTRAINT pk_build                     PRIMARY KEY (build_id),
    CONSTRAINT fk_build_post_id             FOREIGN KEY (build_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*--------------------------------- VOTE (DETAIL) ----------------------------------*/

CREATE TABLE vote (
    vote_id         INT UNSIGNED                    NOT NULL    AUTO_INCREMENT,
    start_at        DATETIME                        NULL,
    end_at          DATETIME                        NULL,
    max_selections  INT UNSIGNED                    NOT NULL    DEFAULT 1,

    CONSTRAINT pk_vote              PRIMARY KEY (vote_id),
    CONSTRAINT fk_vote_post_id      FOREIGN KEY (vote_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,

    INDEX idx_vote_start_end (start_at, end_at)
);

/*----------------------------------- VOTE OPTION ------------------------------------*/

CREATE TABLE vote_option (
    option_id       INT UNSIGNED        NOT NULL    AUTO_INCREMENT,
    vote_id         INT UNSIGNED        NOT NULL,
    title           VARCHAR(255)        NOT NULL,
    description     TEXT                NULL,
    sort_order      INT UNSIGNED        NOT NULL    DEFAULT 0,
    created_by      INT UNSIGNED        NOT NULL,
    created_at      DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by      INT UNSIGNED        NULL,
    updated_at      DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    vote_count      BIGINT UNSIGNED     NOT NULL    DEFAULT 0,

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

DELIMITER $$

CREATE TRIGGER trg_user_vote_after_insert
AFTER INSERT ON user_vote
FOR EACH ROW
BEGIN
    UPDATE vote_option SET vote_count = vote_count + 1 WHERE option_id = NEW.option_id;
END$$

CREATE TRIGGER trg_user_vote_after_delete
AFTER DELETE ON user_vote
FOR EACH ROW
BEGIN
    UPDATE vote_option SET vote_count = GREATEST(vote_count - 1, 0) WHERE option_id = OLD.option_id;
END$$

DELIMITER ;

/*----------------------------------- VOTE OPTION FILE ------------------------------------*/

CREATE TABLE vote_option_file (
    option_id       INT UNSIGNED    NOT NULL,
    file_id         INT UNSIGNED    NOT NULL,
    sort_order      INT UNSIGNED    NOT NULL    DEFAULT 0,

    CONSTRAINT pk_vote_option_file              PRIMARY KEY (option_id, file_id),
    CONSTRAINT fk_vote_option_file_option_id    FOREIGN KEY (option_id)
        REFERENCES vote_option(option_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_vote_option_file_file_id     FOREIGN KEY (file_id)
        REFERENCES file(file_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*----------------------------------- USER VOTE ------------------------------------*/

CREATE TABLE user_vote (
    user_id         INT UNSIGNED        NOT NULL,
    vote_id         INT UNSIGNED        NOT NULL,
    option_id       INT UNSIGNED        NOT NULL,
    created_at      DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,

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

/*----------------------------------- LIKE ------------------------------------*/

CREATE TABLE content_like (
    post_id     INT UNSIGNED        NOT NULL,
    user_id     INT UNSIGNED        NOT NULL,
    created_at  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_like          PRIMARY KEY (post_id, user_id),
    CONSTRAINT fk_like_post_id  FOREIGN KEY (post_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_like_user_id  FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    INDEX idx_like_user_id (user_id)
);

DELIMITER $$

CREATE TRIGGER trg_content_like_after_insert
AFTER INSERT ON content_like
FOR EACH ROW
BEGIN
    UPDATE post SET like_count = like_count + 1 WHERE post_id = NEW.post_id;
END$$

CREATE TRIGGER trg_content_like_after_delete
AFTER DELETE ON content_like
FOR EACH ROW
BEGIN
    UPDATE post SET like_count = GREATEST(like_count - 1, 0) WHERE post_id = OLD.post_id;
END$$

DELIMITER ;

/*---------------------------------- CONVERSATION -----------------------------------*/

CREATE TABLE conversation (
    conversation_id     INT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    is_group            BIT             NOT NULL    DEFAULT 0,
    title               VARCHAR(100)    NULL,
    created_by          INT UNSIGNED    NOT NULL,
    created_at          DATETIME        NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_conversation              PRIMARY KEY (conversation_id),
    CONSTRAINT fk_conversation_created_by   FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON UPDATE RESTRICT
);

/*---------------------------------- CONVERSATION PARTICIPANT -----------------------------------*/

CREATE TABLE conversation_participant (
    conversation_id     INT UNSIGNED            NOT NULL,
    user_id             INT UNSIGNED            NOT NULL,
    role                ENUM('OWNER','MEMBER')  NOT NULL    DEFAULT 'MEMBER',
    joined_at           DATETIME                NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    last_read_at        DATETIME                NULL,

    CONSTRAINT pk_conversation_participant                  PRIMARY KEY (conversation_id, user_id),
    CONSTRAINT fk_conversation_participant_conversation_id  FOREIGN KEY (conversation_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_conversation_participant_user_id          FOREIGN KEY (user_id)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    INDEX idx_conversation_paricipant_user_id (user_id)
);

/*---------------------------------- MESSAGE -----------------------------------*/

CREATE TABLE message (
    message_id          BIGINT UNSIGNED             NOT NULL    AUTO_INCREMENT,
    message_type        ENUM('COMMENT','DIRECT')    NOT NULL,
    parent_message_id   BIGINT UNSIGNED             NULL,
    body                TEXT                        NOT NULL,
    created_by          INT UNSIGNED                NOT NULL,
    created_at          DATETIME                    NOT NULL    DEFAULT CURRENT_TIMESTAMP,
    updated_by          INT UNSIGNED                NULL,
    updated_at          DATETIME                    NOT NULL    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT pk_message                       PRIMARY KEY (message_id),
    CONSTRAINT uq_message_message_type          UNIQUE KEY (message_id, message_type),
    CONSTRAINT fk_message_parent_message_id     FOREIGN KEY (parent_message_id)
        REFERENCES message(message_id)
            ON UPDATE CASCADE
            ON DELETE SET NULL,
    CONSTRAINT fk_message_created_by            FOREIGN KEY (created_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,
    CONSTRAINT fk_message_updated_by            FOREIGN KEY (updated_by)
        REFERENCES user(user_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    INDEX idx_message_parent_message_id (parent_message_id),
    INDEX idx_message_created_by (created_by)
);

/*------------------------------ MESSAGE FILE (JOIN) ------------------------------*/

CREATE TABLE message_file (
    message_id  BIGINT UNSIGNED         NOT NULL,
    file_id     INT UNSIGNED            NOT NULL,
    sort_order  INT UNSIGNED            NOT NULL    DEFAULT 0,
    created_at  DATETIME                NOT NULL    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_message_file             PRIMARY KEY (message_id, file_id),
    CONSTRAINT fk_message_file_message_id  FOREIGN KEY (message_id)
        REFERENCES message(message_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_message_file_file_id     FOREIGN KEY (file_id)
        REFERENCES file(file_id)
            ON UPDATE CASCADE
            ON DELETE RESTRICT,

    INDEX idx_message_file_file_id (file_id)
);

/*------------------------------ POST COMMENT (JOIN) ------------------------------*/

CREATE TABLE post_comment (
    message_id      BIGINT UNSIGNED  NOT NULL,
    post_id         INT UNSIGNED     NOT NULL,

    CONSTRAINT pk_post_comment              PRIMARY KEY (message_id, post_id),
    CONSTRAINT fk_post_comment_message_id   FOREIGN KEY (message_id)
        REFERENCES message(message_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_post_comment_post_id      FOREIGN KEY (post_id)
        REFERENCES post(post_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*-------------------------- CONVERSATION MESSAGE (JOIN) --------------------------*/

CREATE TABLE conversation_message (
    message_id          BIGINT UNSIGNED  NOT NULL,
    conversation_id     INT UNSIGNED     NOT NULL,

    CONSTRAINT pk_conversation_message                  PRIMARY KEY (message_id, conversation_id),
    CONSTRAINT fk_conversation_message_message_id       FOREIGN KEY (message_id)
        REFERENCES message(message_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_conversation_message_conversation_id  FOREIGN KEY (conversation_id)
        REFERENCES conversation(conversation_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

/*------------------------------ AUDIT LOG (LOOKUP) -------------------------------*/

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

    INDEX idx_audit_log_table_record (table_name, record_id),
    INDEX idx_audit_log_changed_by (changed_by),
    INDEX idx_audit_log_changed_at (changed_at)
);
