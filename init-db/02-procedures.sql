USE smpdb;

/*****************************************************************************
                    STORED PROCEDURES / CRUD FUNCTIONS
*****************************************************************************/

/*----------------------------------- IMAGE ------------------------------------*/

/*----------- INSERT IMAGE ------------*/
DROP PROCEDURE IF EXISTS sp_insert_image;
CREATE PROCEDURE sp_insert_image (
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
END proc;

/*----------- UPDATE IMAGE ------------*/
DROP PROCEDURE IF EXISTS sp_update_image;
CREATE PROCEDURE sp_update_image (
    IN p_acting_user_id    INT,
    IN p_image_id          INT,
    IN p_file_name         VARCHAR(255),
    IN p_mime_type         VARCHAR(100),
    IN p_file_size         BIGINT,
    IN p_file_path         VARCHAR(500),
    IN p_file_hash         CHAR(64)
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    -- Perform operation
    UPDATE image
    SET     file_name = p_file_name,
            mime_type = p_mime_type,
            file_size = p_file_size,
            file_path = p_file_path,
            file_hash = p_file_hash
    WHERE image_id = p_image_id;
END;

/*----------- DELETE IMAGE ------------*/
DROP PROCEDURE IF EXISTS sp_delete_image;
CREATE PROCEDURE sp_delete_image (
    IN p_acting_user_id     INT,
    IN p_image_id           INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    -- Perform operation
    DELETE FROM image
    WHERE image_id = p_image_id;
END;

/*----------- GET IMAGE ------------*/
DROP PROCEDURE IF EXISTS sp_get_image;
CREATE PROCEDURE sp_get_image (
    IN      p_image_id      INT
)
BEGIN
    SELECT  i.image_id,
            i.file_name,
            i.mime_type,
            i.file_size,
            i.file_path,
            i.created_by,
            u.display_name AS 'created_by_name'
    FROM image i
    LEFT JOIN user u
        ON u.user_id = i.created_by
    WHERE image_id = p_image_id;
END;

/*----------- GET IMAGES ------------*/
DROP PROCEDURE IF EXISTS sp_get_images;
CREATE PROCEDURE sp_get_images (
    IN p_limit  INT,
    IN p_offset INT
)
BEGIN
    SELECT  i.image_id,
            i.file_name,
            i.mime_type,
            i.file_size,
            i.file_path,
            i.created_at,
            i.created_by,
            u.display_name AS 'created_by_name'
    FROM image i
    LEFT JOIN user u
        ON u.user_id = i.created_by
    WHERE image_id = p_image_id
    ORDER BY i.created_at DESC
    LIMIT p_limit OFFSET p_offset;
END;

/*----------------------------------- USER ------------------------------------*/

/*----------- REGISTER USER ------------*/
DROP PROCEDURE IF EXISTS sp_register_user;
CREATE PROCEDURE sp_register_user (
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
END;

/*----------- LOGIN USER ------------*/
DROP PROCEDURE IF EXISTS sp_login_user;
CREATE PROCEDURE sp_login_user (
    IN  p_email         VARCHAR(255)
)
BEGIN
    SELECT  user_id,
            display_name,
            password_hash,
            status
    FROM user
    WHERE email = p_email;
END;

/*----------- UPDATE USER ------------*/
DROP PROCEDURE IF EXISTS sp_update_user;
CREATE PROCEDURE sp_update_user (
    IN  p_acting_user_id    INT,
    IN  p_user_id           INT,
    IN  p_display_name      VARCHAR(50),
    IN  p_pfp_image_id      INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    -- Check if display_name already taken
    IF EXISTS (SELECT 1 FROM users WHERE display_name = p_display_name) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Display name already in use';
    END IF;

    -- Check that pfp image has been uploaded already
    IF NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_pfp_image_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Image not found.';
    END IF;

    -- Perform operation
    UPDATE  user
    SET     display_name    = p_display_name,
            pfp_image_id    = p_pfp_image_id,
            updated_by = p_acting_user_id
    WHERE   user_id = p_user_id;
END;

/* ----------- UPDATE USER STATUS (lock / unlock / deactivate) ------------ */
DROP PROCEDURE IF EXISTS sp_update_user_status;
CREATE PROCEDURE sp_update_user_status (
    IN p_acting_user_id INT,
    IN p_user_id        INT,
    IN p_status         ENUM('ACTIVE','INACTIVE','LOCKED')
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    UPDATE user
    SET    status          = p_status,
           updated_by = p_acting_user_id
    WHERE  user_id = p_user_id;
END;

/*----------- UPDATE USER PASSWORD ------------*/
DROP PROCEDURE IF EXISTS sp_update_user_password;
CREATE PROCEDURE sp_update_user_password (
    IN  p_acting_user_id        INT,
    IN  p_user_id               INT,
    IN  p_new_password_hash     VARCHAR(255)
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    -- Update password
    UPDATE  user
    SET     password_hash   = p_password_hash,
            updated_by = p_acting_user_id
    WHERE   user_id = p_user_id;
END;

/*----------- DELETE USER ------------*/
DROP PROCEDURE IF EXISTS sp_delete_user;
CREATE PROCEDURE sp_delete_user (
    IN p_acting_user_id     INT,
    IN p_user_id            INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    -- Set user status to 'INACTIVE'
    UPDATE  user
    SET     status          = 'INACTIVE',
            updated_by = p_acting_user_id
    WHERE   user_id = p_user_id;
END;

/* ----------- GET USER ------------ */
DROP PROCEDURE IF EXISTS sp_get_user;
CREATE PROCEDURE sp_get_user (
    IN p_acting_user_id INT,
    IN p_user_id        INT
)
BEGIN
    SELECT  u.user_id,
            u.display_name,
            u.status,
            u.last_seen,
            u.created_at,
            i.file_path AS pfp_path
    FROM    user u
    LEFT JOIN image i
        ON i.image_id = u.pfp_image_id
    WHERE   u.user_id = p_user_id;
END;

/* ----------- GET USER ACCOUNT (includes email) ------------ */
DROP PROCEDURE IF EXISTS sp_get_user_account;
CREATE PROCEDURE sp_get_user_account (
    IN p_acting_user_id INT,
    IN p_user_id        INT
)
BEGIN
    SELECT  u.user_id,
            u.email,
            u.display_name,
            u.status,
            u.last_seen,
            u.created_at,
            u.last_updated_at,
            i.file_path AS pfp_path
    FROM    user  u
    LEFT JOIN image i 
        ON i.image_id = u.pfp_image_id
    WHERE   u.user_id = p_user_id;
END;

/* ----------- GET USERS (paged) ------------ */
DROP PROCEDURE IF EXISTS sp_get_users;
CREATE PROCEDURE sp_get_users (
    IN p_acting_user_id INT,
    IN p_search         VARCHAR(100),
    IN p_decending      BOOLEAN,
    IN p_limit          INT,
    IN p_offset         INT
)
BEGIN
    SELECT  u.user_id,
            u.display_name,
            u.status,
            u.last_seen,
            u.created_at,
            i.file_path AS pfp_path
    FROM    user u
    LEFT JOIN image i
        ON i.image_id = u.pfp_image_id
    WHERE
        (
            p_search IS NULL
            OR p_search = ''
            OR u.display_name LIKE CONCAT('%', p_search, '%')
        )
    ORDER BY
        CASE
            WHEN p_descending = TRUE THEN u.created_at
        END DESC,

        CASE
            WHEN p_descending = FALSE THEN u.created_at
        END ASC
    LIMIT p_limit OFFSET p_offset;
END;

/* ----------- COUNT USERS ------------ */
DROP PROCEDURE IF EXISTS sp_count_users;
CREATE PROCEDURE sp_count_users (
    IN p_acting_user_id INT,
    IN p_search         VARCHAR(255),
    IN p_status         VARCHAR(20)
)
BEGIN
    SELECT COUNT(*) AS total
    FROM user u
    WHERE
        (
            p_search IS NULL
            OR u.display_name LIKE CONCAT('%', p_search, '%')
        )
    AND
        (
            p_status IS NULL
            OR u.status = p_status
        );
END;

/* ----------- BAN USER ------------ */
DROP PROCEDURE IF EXISTS sp_ban_user;
CREATE PROCEDURE sp_ban_user (
	IN p_acting_user_id	INT,
	IN p_user_id		INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

	UPDATE user
	SET status = 'LOCKED',
		last_updated_by = p_acting_user_id
	WHERE user_id = p_user_id;
END;

/* ----------- UPDATE LAST SEEN ------------ */
DROP PROCEDURE IF EXISTS sp_update_user_last_seen;
CREATE PROCEDURE sp_update_user_last_seen (
    IN p_user_id INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    UPDATE user 
    SET last_seen = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;
END;

/* ----------- GET USER PERMISSIONS (effective — role + direct) ------------ */
DROP PROCEDURE IF EXISTS sp_get_user_permissions;
CREATE PROCEDURE sp_get_user_permissions (
    IN p_user_id        INT
)
BEGIN
    SELECT DISTINCT p.permission_id,
                    p.name, 
                    p.description
    FROM   permission p
    WHERE  p.permission_id IN (
        -- via roles
        SELECT rp.permission_id
        FROM   user_role ur
        JOIN   role_permission rp 
            ON rp.role_id = ur.role_id
        WHERE  ur.user_id = p_user_id
        UNION
        -- direct grants
        SELECT up.permission_id
        FROM   user_permission up
        WHERE  up.user_id = p_user_id
    )
    ORDER BY p.name;
END;

/*----------------------------------- ROLE ------------------------------------*/

/* ----------- INSERT ROLE ------------ */
DROP PROCEDURE IF EXISTS sp_insert_role;
CREATE PROCEDURE sp_insert_role (
    IN  p_acting_user_id INT,
    IN  p_name           VARCHAR(50),
    IN  p_description    VARCHAR(255),
    OUT p_role_id        INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

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
END;

/* ----------- UPDATE ROLE ------------ */
DROP PROCEDURE IF EXISTS sp_update_role;
CREATE PROCEDURE sp_update_role (
    IN p_acting_user_id INT,
    IN p_role_id        INT,
    IN p_name           VARCHAR(50),
    IN p_description    VARCHAR(255)
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM role WHERE role_id = p_role_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Role not found';
    END IF;

    UPDATE role
    SET    name        = p_name,
           description = p_description,
           updated_by  = p_acting_user_id
    WHERE  role_id = p_role_id;
END;

/* ----------- DELETE ROLE ------------ */
DROP PROCEDURE IF EXISTS sp_delete_role;
CREATE PROCEDURE sp_delete_role (
    IN p_acting_user_id INT,
    IN p_role_id        INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM role WHERE role_id = p_role_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Role not found';
    END IF;

    DELETE FROM role
    WHERE role_id = p_role_id;
END;

/* ----------- GET ROLE ------------ */
DROP PROCEDURE IF EXISTS sp_get_role;
CREATE PROCEDURE sp_get_role (
    IN p_acting_user_id INT,
    IN p_role_id        INT
)
BEGIN
    SELECT  role_id,
            name,
            description,
            created_at,
            updated_at
    FROM role
    WHERE role_id = p_role_id;
END;

/* ----------- GET ROLES ------------ */
DROP PROCEDURE IF EXISTS sp_get_roles;
CREATE PROCEDURE sp_get_roles (
    IN p_acting_user_id INT
)
BEGIN
    SELECT  role_id,
            name,
            description,
            created_at,
            updated_at
    FROM role
    ORDER BY name;
END;

/* ----------- ASSIGN ROLE TO USER ------------ */
DROP PROCEDURE IF EXISTS sp_assign_user_role;
CREATE PROCEDURE sp_assign_user_role (
    IN p_acting_user_id INT,
    IN p_user_id        INT,
    IN p_role_id        INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM user WHERE user_id = p_user_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM role WHERE role_id = p_role_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Role not found';
    END IF;

    INSERT INTO user_role (
        user_id,
        role_id,
        created_by
    )
    VALUES (
        p_user_id,
        p_role_id,
        p_acting_user_id
    );
END;

/* ----------- REVOKE ROLE FROM USER ------------ */
DROP PROCEDURE IF EXISTS sp_revoke_user_role;
CREATE PROCEDURE sp_revoke_user_role (
    IN p_acting_user_id INT,
    IN p_user_id        INT,
    IN p_role_id        INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    DELETE FROM user_role
    WHERE user_id = p_user_id 
        AND role_id = p_role_id;
END;

/* ----------- GET USER ROLES ------------ */
DROP PROCEDURE IF EXISTS sp_get_user_roles;
CREATE PROCEDURE sp_get_user_roles (
    IN p_user_id        INT
)
BEGIN
    SELECT  r.role_id,
            r.name,
            r.description
    FROM    user_role ur
    JOIN    role r
        ON r.role_id = ur.role_id
    WHERE   ur.user_id = p_user_id
    ORDER BY r.name;
END;

/*----------------------------------- PERMISSION ------------------------------------*/

/* ----------- GET ALL PERMISSIONS ------------ */
DROP PROCEDURE IF EXISTS sp_get_permissions;
CREATE PROCEDURE sp_get_permissions (
    IN p_acting_user_id INT
)
BEGIN
    SELECT  permission_id,
            name,
            description
    FROM    permission
    ORDER BY name;
END;

/* ----------- ASSIGN PERMISSION TO ROLE ------------ */
DROP PROCEDURE IF EXISTS sp_assign_role_permission;
CREATE PROCEDURE sp_assign_role_permission (
    IN p_acting_user_id INT,
    IN p_role_id        INT,
    IN p_permission_id  INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    INSERT INTO role_permission (
        role_id,
        permission_id
    )
    VALUES (
        p_role_id,
        p_permission_id
    );
END;

/* ----------- REVOKE PERMISSION FROM ROLE ------------ */
DROP PROCEDURE IF EXISTS sp_revoke_role_permission;
CREATE PROCEDURE sp_revoke_role_permission (
    IN p_acting_user_id INT,
    IN p_role_id        INT,
    IN p_permission_id  INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;
    
    DELETE FROM role_permission
    WHERE role_id = p_role_id
        AND permission_id = p_permission_id;
END;

/* ----------- GET ROLE PERMISSIONS ------------ */
DROP PROCEDURE IF EXISTS sp_get_role_permissions;
CREATE PROCEDURE sp_get_role_permissions (
    IN p_acting_user_id INT,
    IN p_role_id        INT
)
BEGIN
    SELECT  p.permission_id, p.name, p.description
    FROM    role_permission rp
    JOIN    permission p 
        ON p.permission_id = rp.permission_id
    WHERE   rp.role_id = p_role_id
    ORDER BY p.name;
END;

/* ----------- ASSIGN DIRECT PERMISSION TO USER ------------ */
DROP PROCEDURE IF EXISTS sp_assign_user_permission;
CREATE PROCEDURE sp_assign_user_permission (
    IN p_acting_user_id INT,
    IN p_user_id        INT,
    IN p_permission_id  INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    INSERT INTO user_permission (
        user_id,
        permission_id
    )
    VALUES (
        p_user_id,
        p_permission_id
    );
END;

/* ----------- REVOKE DIRECT PERMISSION FROM USER ------------ */
DROP PROCEDURE IF EXISTS sp_revoke_user_permission;
CREATE PROCEDURE sp_revoke_user_permission (
    IN p_acting_user_id INT,
    IN p_user_id        INT,
    IN p_permission_id  INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    DELETE FROM user_permission
    WHERE user_id = p_user_id 
        AND permission_id = p_permission_id;
END;

/*----------------------------------- TAG ------------------------------------*/

/* ----------- INSERT TAG ------------ */
DROP PROCEDURE IF EXISTS sp_insert_tag;
CREATE PROCEDURE sp_insert_tag (
    IN  p_acting_user_id INT,
    IN  p_tag_type_id    INT,
    IN  p_name           VARCHAR(50),
    IN  p_description    VARCHAR(255),
    OUT p_tag_id         INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

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
END;

/* ----------- UPDATE TAG ------------ */
DROP PROCEDURE IF EXISTS sp_update_tag;
CREATE PROCEDURE sp_update_tag (
    IN p_acting_user_id INT,
    IN p_tag_id         INT,
    IN p_name           VARCHAR(50),
    IN p_description    VARCHAR(255)
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM tag WHERE tag_id = p_tag_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tag not found';
    END IF;

    UPDATE tag
    SET    name            = p_name,
           description     = p_description,
           last_updated_by = p_acting_user_id,
           last_updated_at = CURRENT_TIMESTAMP
    WHERE  tag_id = p_tag_id;
END;

/* ----------- DELETE TAG ------------ */
DROP PROCEDURE IF EXISTS sp_delete_tag;
CREATE PROCEDURE sp_delete_tag (
    IN p_acting_user_id INT,
    IN p_tag_id         INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM tag WHERE tag_id = p_tag_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tag not found';
    END IF;

    DELETE FROM tag
    WHERE tag_id = p_tag_id;
END;

/* ----------- GET TAG ------------ */
DROP PROCEDURE IF EXISTS sp_get_tag;
CREATE PROCEDURE sp_get_tag (
    IN p_tag_id INT
)
BEGIN
    SELECT  t.tag_id, t.name, t.description,
            tt.tag_type_id, tt.name AS type_name, tt.color_hex
    FROM    tag t
    JOIN    tag_type tt ON tt.tag_type_id = t.tag_type_id
    WHERE   t.tag_id = p_tag_id;
END;

/* ----------- GET TAGS ------------ */
DROP PROCEDURE IF EXISTS sp_get_tags;
CREATE PROCEDURE sp_get_tags (
    IN p_tag_type_id INT  -- NULL = all types
)
BEGIN
    SELECT  t.tag_id,
            t.name,
            t.description,
            tt.tag_type_id,
            tt.name AS type_name,
            tt.color_hex
    FROM tag t
    JOIN tag_type tt
        ON tt.tag_type_id = t.tag_type_id
    WHERE p_tag_type_id IS NULL
        OR t.tag_type_id = p_tag_type_id
    ORDER BY tt.name, t.name;
END;

/*----------------------------------- BUILD ------------------------------------*/

/* ----------- INSERT BUILD ------------ */
DROP PROCEDURE IF EXISTS sp_insert_build;
CREATE PROCEDURE sp_insert_build (
    IN  p_acting_user_id INT,
    IN  p_name           VARCHAR(100),
    IN  p_description    TEXT,
    IN  p_date_built     DATE,
    IN  p_x_coord        INT,
    IN  p_y_coord        INT,
    IN  p_z_coord        INT,
    OUT p_build_id       INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF EXISTS (SELECT 1 FROM build WHERE name = p_name) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build name already in use';
    END IF;

    INSERT INTO build (
        user_id,
        name,
        description,
        date_built,
        x_coord,
        y_coord,
        z_coord
    )
    VALUES (
        p_acting_user_id,
        p_name,
        p_description,
        p_date_built,
        p_x_coord,
        p_y_coord,
        p_z_coord
    );

    SET p_build_id = LAST_INSERT_ID();
END;

/* ----------- UPDATE BUILD ------------ */
DROP PROCEDURE IF EXISTS sp_update_build;
CREATE PROCEDURE sp_update_build (
    IN p_acting_user_id  INT,
    IN p_build_id        INT,
    IN p_name            VARCHAR(100),
    IN p_description     TEXT,
    IN p_date_built      DATE,
    IN p_x_coord         INT,
    IN p_y_coord         INT,
    IN p_z_coord         INT,
    IN p_primary_image_id INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM build WHERE build_id = p_build_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build not found';
    END IF;

    IF p_primary_image_id IS NOT NULL 
        AND NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_primary_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Primary image not found';
    END IF;

    UPDATE build
    SET name             = p_name,
        description      = p_description,
        date_built       = p_date_built,
        x_coord          = p_x_coord,
        y_coord          = p_y_coord,
        z_coord          = p_z_coord,
        primary_image_id = p_primary_image_id
    WHERE build_id = p_build_id;
END;

/* ----------- DELETE BUILD ------------ */
DROP PROCEDURE IF EXISTS sp_delete_build;
CREATE PROCEDURE sp_delete_build (
    IN p_acting_user_id INT,
    IN p_build_id       INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM build WHERE build_id = p_build_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build not found';
    END IF;

    DELETE FROM build
    WHERE build_id = p_build_id;
END;

/* ----------- GET BUILD ------------ */
DROP PROCEDURE IF EXISTS sp_get_build;
CREATE PROCEDURE sp_get_build (
    IN p_build_id INT
)
BEGIN
    SELECT  b.build_id,
            b.name,
            b.description,
            b.date_built,
            b.x_coord,
            b.y_coord,
            b.z_coord,
            b.created_at,
            b.primary_image_id,
            pi.file_path  AS primary_image_path,
            u.user_id,
            u.display_name AS owner_name
    FROM build b
    JOIN user u
        ON u.user_id = b.user_id
    LEFT JOIN image pi
        ON pi.image_id = b.primary_image_id
    WHERE b.build_id = p_build_id;
END;

/* ----------- GET BUILDS (paged, searched, sorted) ------------ */
DROP PROCEDURE IF EXISTS sp_get_builds;
CREATE PROCEDURE sp_get_builds (
    IN p_search         VARCHAR(255),
    IN p_descending     BOOLEAN,
    IN p_limit          INT,
    IN p_offset         INT
)
BEGIN
    SELECT  b.build_id,
            b.name,
            b.description,
            b.date_built,
            b.x_coord,
            b.y_coord,
            b.z_coord,
            b.created_at,
            b.primary_image_id,
            i.file_path AS primary_image_path,

            b.created_by,
            u.display_name AS creator_display_name,

            COUNT(*) OVER() AS total_count

    FROM build b
    JOIN user u
        ON u.user_id = b.created_by
    LEFT JOIN image i
        ON i.image_id = b.primary_image_id
    WHERE
        (
            p_search IS NULL
            OR p_search = ''
            OR b.name LIKE CONCAT('%', p_search, '%')
            OR b.description LIKE CONCAT('%', p_search, '%')
            OR u.display_name LIKE CONCAT('%', p_search, '%')

            OR EXISTS (
                SELECT 1
                FROM build_tag bt
                JOIN tag t
                    ON t.tag_id = bt.tag_id
                WHERE bt.build_id = b.build_id
                    AND t.name LIKE CONCAT('%', p_search, '%')
            )
        )
    ORDER BY
        CASE
            WHEN p_descending = TRUE THEN b.created_at
        END DESC,

        CASE
            WHEN p_descending = FALSE THEN b.created_at
        END ASC,

        b.build_id DESC

    LIMIT p_limit OFFSET p_offset;
END;

/* ----------- ADD TAG TO BUILD ------------ */
DROP PROCEDURE IF EXISTS sp_add_build_tag;
CREATE PROCEDURE sp_add_build_tag (
    IN p_acting_user_id INT,
    IN p_build_id       INT,
    IN p_tag_id         INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM build WHERE build_id = p_build_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build not found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM tag WHERE tag_id = p_tag_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tag not found';
    END IF;

    INSERT INTO build_tag (
        build_id,
        tag_id
    )
    VALUES (
        p_build_id,
        p_tag_id
    );
END;

/* ----------- REMOVE TAG FROM BUILD ------------ */
DROP PROCEDURE IF EXISTS sp_remove_build_tag;
CREATE PROCEDURE sp_remove_build_tag (
    IN p_acting_user_id INT,
    IN p_build_id       INT,
    IN p_tag_id         INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM build WHERE build_id = p_build_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build not found';
    END IF;

    DELETE FROM build_tag
    WHERE build_id = p_build_id
        AND tag_id = p_tag_id;
END;

/* ----------- GET BUILD TAGS ------------ */
DROP PROCEDURE IF EXISTS sp_get_build_tags;
CREATE PROCEDURE sp_get_build_tags (
    IN p_build_ids TEXT
)
BEGIN
    SELECT  bt.build_id,
            t.tag_id,
            t.name AS tag_name,
            t.description AS tag_description,
            tt.tag_type_id,
            tt.name AS tag_type_name,
            tt.color_hex AS tag_type_color
    FROM build_tag bt
    JOIN tag t
        ON t.tag_id = bt.tag_id
    JOIN tag_type tt
        ON tt.tag_type_id = t.tag_type_id
    WHERE FIND_IN_SET(bt.build_id, p_build_ids) > 0;
END;

/* ----------- INSERT BUILD IMAGE ------------ */
DROP PROCEDURE IF EXISTS sp_insert_build_image;
CREATE PROCEDURE sp_insert_build_image (
    IN p_acting_user_id INT,
    IN p_build_id       INT,
    IN p_image_id       INT,
    IN p_sort_order     INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM build WHERE build_id = p_build_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build not found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Image not found';
    END IF;

    INSERT INTO build_image (
        build_id,
        image_id,
        sort_order
    )
    VALUES (
        p_build_id,
        p_image_id,
        p_sort_order
    );
END;

/* ----------- DELETE BUILD IMAGES ------------ */
DROP PROCEDURE IF EXISTS sp_delete_build_images;
CREATE PROCEDURE sp_delete_build_images (
    IN p_acting_user_id INT,
    IN p_build_id       INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM build WHERE build_id = p_build_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Build not found';
    END IF;

    DELETE FROM build_image
    WHERE build_id = p_build_id;
END;

/* ----------- GET BUILD IMAGES ------------ */
DROP PROCEDURE IF EXISTS sp_get_build_images;
CREATE PROCEDURE sp_get_build_images (
    IN p_build_id INT
)
BEGIN
    SELECT  bi.build_image_id,
            bi.sort_order,
            i.image_id,
            i.file_path,
            i.file_name,
            i.mime_type
    FROM build_image bi
    JOIN image i
        ON i.image_id = bi.image_id
    WHERE bi.build_id = p_build_id
    ORDER BY bi.sort_order;
END;

/*----------------------------------- POST TYPE ------------------------------------*/

/* ----------- GET POST TYPES (lookup, read-only) ------------ */
DROP PROCEDURE IF EXISTS sp_get_post_types;
CREATE PROCEDURE sp_get_post_types ()
BEGIN
    SELECT  post_type_id,
            name,
            description
    FROM post_type
    ORDER BY name;
END;

/*----------------------------------- POST ------------------------------------*/

/* ----------- INSERT POST ------------ */
DROP PROCEDURE IF EXISTS sp_insert_post;
CREATE PROCEDURE sp_insert_post (
    IN  p_acting_user_id    INT,
    IN  p_title             VARCHAR(255),
    IN  p_slug              VARCHAR(255),
    IN  p_content           TEXT,
    IN  p_post_type_id      INT,
    IN  p_is_pinned         BIT,
    IN  p_publish_at        DATETIME,
    IN  p_expires_at        DATETIME,
    IN  p_featured_image_id INT,
    OUT p_post_id           INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF EXISTS (SELECT 1 FROM post WHERE title = p_title) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post title already in use';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM post_type WHERE post_type_id = p_post_type_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post type not found';
    END IF;

    IF p_featured_image_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_featured_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Featured image not found';
    END IF;

    INSERT INTO post (
        title,
        slug,
        content,
        post_type_id,
        is_pinned,
        publish_at,
        expires_at,
        featured_image_id,
        created_by
    )
    VALUES (
        p_title,
        p_slug,
        p_content,
        p_post_type_id,
        p_is_pinned,
        p_publish_at,
        p_expires_at,
        p_featured_image_id,
        p_acting_user_id
    );

    SET p_post_id = LAST_INSERT_ID();
END;

/* ----------- UPDATE POST ------------ */
DROP PROCEDURE IF EXISTS sp_update_post;
CREATE PROCEDURE sp_update_post (
    IN p_acting_user_id    INT,
    IN p_post_id           INT,
    IN p_title             VARCHAR(255),
    IN p_slug              VARCHAR(255),
    IN p_content           TEXT,
    IN p_post_type_id      INT,
    IN p_is_pinned         BIT,
    IN p_publish_at        DATETIME,
    IN p_expires_at        DATETIME,
    IN p_featured_image_id INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM post WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post not found';
    END IF;

    IF p_featured_image_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_featured_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Featured image not found';
    END IF;

    UPDATE post
    SET title             = p_title,
        slug              = p_slug,
        content           = p_content,
        post_type_id      = p_post_type_id,
        is_pinned         = p_is_pinned,
        publish_at        = p_publish_at,
        expires_at        = p_expires_at,
        featured_image_id = p_featured_image_id,
        updated_by        = p_acting_user_id
    WHERE post_id = p_post_id;
END;

/* ----------- DELETE POST ------------ */
DROP PROCEDURE IF EXISTS sp_delete_post;
CREATE PROCEDURE sp_delete_post (
    IN p_acting_user_id INT,
    IN p_post_id        INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM post WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post not found';
    END IF;

    DELETE FROM post
    WHERE post_id = p_post_id;
END;

/* ----------- GET POST ------------ */
DROP PROCEDURE IF EXISTS sp_get_post;
CREATE PROCEDURE sp_get_post (
    IN p_post_id INT
)
BEGIN
    SELECT  p.post_id,
            p.title,
            p.slug,
            p.content,
            p.is_pinned,
            p.publish_at,
            p.expires_at,
            p.created_at,
            p.updated_at,
            pt.post_type_id,
            pt.name        AS post_type_name,
            u.user_id      AS created_by,
            u.display_name AS created_by_name,
            i.file_path    AS featured_image_path
    FROM post p
    JOIN post_type pt
        ON pt.post_type_id = p.post_type_id
    JOIN user u
        ON u.user_id = p.created_by
    LEFT JOIN image i
        ON i.image_id = p.featured_image_id
    WHERE p.post_id = p_post_id;
END;

/* ----------- GET POSTS (paged, optionally filtered by type) ------------ */
DROP PROCEDURE IF EXISTS sp_get_posts;
CREATE PROCEDURE sp_get_posts (
    IN p_post_type_id INT,  -- NULL = all types
    IN p_pinned_only  BIT,           -- 1 = pinned only
    IN p_limit        INT,
    IN p_offset       INT
)
BEGIN
    SELECT  p.post_id,
            p.title,
            p.slug,
            p.is_pinned,
            p.publish_at,
            p.expires_at,
            p.created_at,
            pt.post_type_id,
            pt.name AS 'post_type_name',
            u.user_id AS 'created_by',
            u.display_name AS 'created_by_name',
            i.file_path AS 'featured_image_path'
    FROM post p
    JOIN post_type pt ON pt.post_type_id = p.post_type_id
    JOIN user u
        ON u.user_id = p.created_by
    LEFT JOIN image i
        ON i.image_id = p.featured_image_id
    WHERE (p_post_type_id IS NULL OR p.post_type_id = p_post_type_id)
        AND (p_pinned_only = 0 OR p.is_pinned = 1)
        AND (p.publish_at IS NULL OR p.publish_at <= NOW())
        AND (p.expires_at IS NULL OR p.expires_at > NOW())
    ORDER BY p.is_pinned DESC,
             p.created_at DESC
    LIMIT p_limit OFFSET p_offset;
END;

/* ----------- ADD TAG TO POST ------------ */
DROP PROCEDURE IF EXISTS sp_add_post_tag;
CREATE PROCEDURE sp_add_post_tag (
    IN p_acting_user_id INT,
    IN p_post_id        INT,
    IN p_tag_id         INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM post WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post not found';
    END IF;

    INSERT INTO post_tag (
        post_id,
        tag_id
    ) 
    VALUES (
        p_post_id,
        p_tag_id
    );
END;

/* ----------- REMOVE TAG FROM POST ------------ */
DROP PROCEDURE IF EXISTS sp_remove_post_tag;
CREATE PROCEDURE sp_remove_post_tag (
    IN p_acting_user_id INT,
    IN p_post_id        INT,
    IN p_tag_id         INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM post WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post not found';
    END IF;

    DELETE FROM post_tag
    WHERE post_id = p_post_id
        AND tag_id = p_tag_id;
END;

/* ----------- ADD IMAGE TO POST ------------ */
DROP PROCEDURE IF EXISTS sp_add_post_image;
CREATE PROCEDURE sp_add_post_image (
    IN p_acting_user_id INT,
    IN p_post_id        INT,
    IN p_image_id       INT,
    IN p_sort_order     INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM post WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post not found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Image not found';
    END IF;

    INSERT INTO post_image (
        post_id,
        image_id,
        sort_order
    )
    VALUES (
        p_post_id,
        p_image_id,
        p_sort_order
    );
END;

/* ----------- REMOVE IMAGE FROM POST ------------ */
DROP PROCEDURE IF EXISTS sp_remove_post_image;
CREATE PROCEDURE sp_remove_post_image (
    IN p_acting_user_id INT,
    IN p_post_id        INT,
    IN p_image_id       INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM post WHERE post_id = p_post_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Post not found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Image not found';
    END IF;

    DELETE FROM post_image
    WHERE post_id = p_post_id
        AND image_id = p_image_id;
END;

/*----------------------------------- VOTE ------------------------------------*/

/* ----------- INSERT VOTE ------------ */
DROP PROCEDURE IF EXISTS sp_insert_vote;
CREATE PROCEDURE sp_insert_vote (
    IN  p_acting_user_id    INT,
    IN  p_title             VARCHAR(255),
    IN  p_description       TEXT,
    IN  p_max_selections    INT,
    OUT p_vote_id           INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF EXISTS (SELECT 1 FROM vote WHERE title = p_title) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote title already in use';
    END IF;

    INSERT INTO vote (
        user_id,
        title,
        description,
        max_selections,
        created_by
    )
    VALUES (
        p_acting_user_id,
        p_title,
        p_description,
        p_max_selections,
        p_acting_user_id
    );

    SET p_vote_id = LAST_INSERT_ID();
END;

/* ----------- UPDATE VOTE ------------ */
DROP PROCEDURE IF EXISTS sp_update_vote;
CREATE PROCEDURE sp_update_vote (
    IN p_acting_user_id INT,
    IN p_vote_id        INT,
    IN p_title          VARCHAR(255),
    IN p_description    TEXT,
    IN p_max_selections INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;
    
    IF NOT EXISTS (SELECT 1 FROM vote WHERE vote_id = p_vote_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    UPDATE vote
    SET title          = p_title,
        description    = p_description,
        max_selections = p_max_selections
    WHERE vote_id = p_vote_id;
END;

/* ----------- DELETE VOTE ------------ */
DROP PROCEDURE IF EXISTS sp_delete_vote;
CREATE PROCEDURE sp_delete_vote (
    IN p_acting_user_id INT,
    IN p_vote_id        INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM vote WHERE vote_id = p_vote_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    DELETE FROM vote
    WHERE vote_id = p_vote_id;
END;

/* ----------- GET VOTE ------------ */
DROP PROCEDURE IF EXISTS sp_get_vote;
CREATE PROCEDURE sp_get_vote (
    IN p_vote_id INT
)
BEGIN
    SELECT  v.vote_id,
            v.title,
            v.description,
            v.status,
            v.start_time,
            v.end_time,
            v.max_selections,
            v.created_at,
            u.user_id AS 'created_by',
            u.display_name AS 'created_by_name'
    FROM vote v
    JOIN user u
        ON u.user_id = v.user_id
    WHERE v.vote_id = p_vote_id;
END;

/* ----------- GET VOTES (paged) ------------ */
DROP PROCEDURE IF EXISTS sp_get_votes;
CREATE PROCEDURE sp_get_votes (
    IN p_status ENUM('DRAFT','ACTIVE','CLOSED'),  -- NULL = all
    IN p_limit  INT,
    IN p_offset INT
)
BEGIN
    SELECT  v.vote_id,
            v.title,
            v.description,
            v.status,
            v.start_time,
            v.end_time,
            v.max_selections,
            v.created_at,
            u.user_id AS 'created_by',
            u.display_name AS 'created_by_name'
    FROM vote v
    JOIN user u
        ON u.user_id = v.user_id
    WHERE p_status IS NULL
        OR v.status = p_status
    ORDER BY v.created_at DESC
    LIMIT p_limit OFFSET p_offset;
END;

/* ----------- PUBLISH VOTE ------------ */
DROP PROCEDURE IF EXISTS sp_publish_vote;
CREATE PROCEDURE sp_publish_vote (
    IN p_acting_user_id INT,
    IN p_vote_id        INT,
    IN p_start_time     DATETIME,
    IN p_end_time       DATETIME
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM vote WHERE vote_id = p_vote_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    UPDATE vote
    SET published_at    = CURRENT_TIMESTAMP,
        start_time      = p_start_time,
        end_time        = p_end_time,
        updated_by      = p_acting_user_id
    WHERE vote_id = p_vote_id
        AND published_at IS NULL;
END;

/* ----------- UN-PUBLISH VOTE ------------ */
DROP PROCEDURE IF EXISTS sp_publish_vote;
CREATE PROCEDURE sp_publish_vote (
    IN p_acting_user_id INT,
    IN p_vote_id        INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (
        SELECT 1 FROM vote
        WHERE vote_id = p_vote_id
            AND published_at IS NOT NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No published vote exists';
    END IF;

    START TRANSACTION;

    -- Un-publish this vote
    UPDATE vote
    SET published_at    = NULL,
        start_time      = NULL,
        end_time        = NULL,
        updated_by      = p_acting_user_id
    WHERE vote_id = p_vote_id
        AND published_at IS NOT NULL;
    
    -- Remove all user votes from this vote
    DELETE FROM user_vote
    WHERE vote_id = p_vote_id;

    COMMIT;
END;

/* ----------- CLOSE VOTE ------------ */
DROP PROCEDURE IF EXISTS sp_close_vote;
CREATE PROCEDURE sp_close_vote (
    IN p_acting_user_id INT,
    IN p_vote_id        INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;

    IF NOT EXISTS (SELECT 1 FROM vote WHERE vote_id = p_vote_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    UPDATE vote
    SET is_closed_early = TRUE,
        updated_by      = p_acting_user_id
    WHERE vote_id = p_vote_id;
END;

/* ----------- UPDATE VOTE END TIME ------------ */
DROP PROCEDURE IF EXISTS sp_update_vote;
CREATE PROCEDURE sp_update_vote (
    IN p_acting_user_id INT,
    IN p_vote_id        INT,
    IN p_title          VARCHAR(255),
    IN p_description    TEXT,
    IN p_max_selections INT
)
BEGIN
    -- Set session user
    SET @current_user_id = p_acting_user_id;
    
    IF NOT EXISTS (SELECT 1 FROM vote WHERE vote_id = p_vote_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    UPDATE vote
    SET title          = p_title,
        description    = p_description,
        max_selections = p_max_selections
    WHERE vote_id = p_vote_id;
END;

/*----------------------------------- VOTE OPTION ------------------------------------*/

/* ----------- INSERT VOTE OPTION ------------ */
DROP PROCEDURE IF EXISTS sp_insert_vote_option;
CREATE PROCEDURE sp_insert_vote_option (
    IN  p_acting_user_id INT,
    IN  p_vote_id        INT,
    IN  p_title          VARCHAR(255),
    IN  p_description    TEXT,
    IN  p_sort_order     INT,
    OUT p_option_id      INT
)
BEGIN
    DECLARE v_vote_id       INT;
    DECLARE v_published_at  DATETIME;

    -- Set session user
    SET @current_user_id = p_acting_user_id;

    SELECT  vote_id,
            published_at
    INTO    v_vote_id,
            v_published_at
    FROM vote
    WHERE vote_id = p_vote_id;

    IF v_vote_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    IF v_published_at IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Options can only be added to DRAFT votes';
    END IF;

    INSERT INTO vote_option (
        vote_id,
        title,
        description,
        sort_order
    )
    VALUES (
        p_vote_id,
        p_title,
        p_description,
        p_sort_order
    );

    SET p_option_id = LAST_INSERT_ID();
END;

/* ----------- UPDATE VOTE OPTION ------------ */
DROP PROCEDURE IF EXISTS sp_update_vote_option;
CREATE PROCEDURE sp_update_vote_option (
    IN p_acting_user_id INT,
    IN p_option_id      INT,
    IN p_title          VARCHAR(255),
    IN p_description    TEXT,
    IN p_sort_order     INT
)
BEGIN
    DECLARE v_vote_id  INT;
    DECLARE v_status   VARCHAR(10);

    -- Set session user
    SET @current_user_id = p_acting_user_id;

    SELECT  vo.vote_id,
            v.status
    INTO    v_vote_id,
            v_status
    FROM vote_option vo
    JOIN vote v
        ON v.vote_id = vo.vote_id
    WHERE vo.option_id = p_option_id;

    IF v_vote_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote option not found';
    END IF;

    IF v_status <> 'DRAFT' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Options can only be edited on DRAFT votes';
    END IF;

    UPDATE vote_option
    SET title       = p_title,
        description = p_description,
        sort_order  = p_sort_order
    WHERE option_id = p_option_id;
END;

/* ----------- DELETE VOTE OPTION ------------ */
DROP PROCEDURE IF EXISTS sp_delete_vote_option;
CREATE PROCEDURE sp_delete_vote_option (
    IN p_acting_user_id INT,
    IN p_option_id      INT
)
BEGIN
    DECLARE v_status VARCHAR(10);

    SELECT v.status
    INTO v_status
    FROM vote_option vo
    JOIN vote v
        ON v.vote_id = vo.vote_id
    WHERE vo.option_id = p_option_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote option not found';
    END IF;

    IF v_status <> 'DRAFT' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Options can only be deleted from DRAFT votes';
    END IF;

    DELETE FROM vote_option
    WHERE option_id = p_option_id;
END;

/* ----------- GET VOTE OPTIONS ------------ */
DROP PROCEDURE IF EXISTS sp_get_vote_options;
CREATE PROCEDURE sp_get_vote_options (
    IN p_vote_id INT
)
BEGIN
    SELECT  option_id,
            vote_id,
            title,
            description,
            sort_order
    FROM vote_option
    WHERE vote_id = p_vote_id
    ORDER BY sort_order;
END;

/* ----------- ADD IMAGE TO VOTE OPTION ------------ */
DROP PROCEDURE IF EXISTS sp_add_vote_option_image;
CREATE PROCEDURE sp_add_vote_option_image (
    IN p_acting_user_id INT,
    IN p_option_id      INT,
    IN p_image_id       INT,
    IN p_sort_order     INT
)
BEGIN
    DECLARE v_option_id INT;

    SELECT vo.option_id
    INTO v_option_id
    FROM vote_option vo
    JOIN vote v
        ON v.vote_id = vo.vote_id
    WHERE vo.option_id = p_option_id;

    IF v_option_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote option not found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM image WHERE image_id = p_image_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Image not found';
    END IF;

    INSERT INTO vote_option_image (
        option_id,
        image_id,
        sort_order
    )
    VALUES (
        p_option_id,
        p_image_id,
        p_sort_order
    );
END;

/* ----------- REMOVE IMAGE FROM VOTE OPTION ------------ */
DROP PROCEDURE IF EXISTS sp_remove_vote_option_image;
CREATE PROCEDURE sp_remove_vote_option_image (
    IN p_acting_user_id INT,
    IN p_option_id      INT,
    IN p_image_id       INT
)
BEGIN
    DECLARE v_option_id INT;

    SELECT vo.option_id
    INTO v_option_id
    FROM vote_option vo
    JOIN vote v
        ON v.vote_id = vo.vote_id
    WHERE vo.option_id = p_option_id;

    IF v_option_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote option not found';
    END IF;

    DELETE FROM vote_option_image
    WHERE option_id = p_option_id
        AND image_id = p_image_id;
END;

/*----------------------------------- USER VOTE ------------------------------------*/

/* ----------- CAST VOTE ------------ */
DROP PROCEDURE IF EXISTS sp_cast_vote;
CREATE PROCEDURE sp_cast_vote (
    IN p_acting_user_id INT,
    IN p_vote_id        INT,
    IN p_option_id      INT
)
BEGIN
    DECLARE v_status        VARCHAR(10);
    DECLARE v_max_sel       INT;
    DECLARE v_option_vote   INT;
    DECLARE v_current_sel   INT;

    -- Verify vote is active
    SELECT status, max_selections
    INTO v_status, v_max_sel
    FROM vote WHERE vote_id = p_vote_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    IF v_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote is not active';
    END IF;

    -- Verify option belongs to this vote
    SELECT COUNT(*) INTO v_option_vote
    FROM   vote_option
    WHERE  option_id = p_option_id AND vote_id = p_vote_id;

    IF v_option_vote = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Option does not belong to this vote';
    END IF;

    -- Enforce max_selections
    SELECT COUNT(*) INTO v_current_sel
    FROM   user_vote
    WHERE  user_id = p_acting_user_id AND vote_id = p_vote_id;

    IF v_current_sel >= v_max_sel THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Maximum selections reached for this vote';
    END IF;

    -- Prevent duplicate selection
    IF EXISTS (SELECT 1 FROM user_vote
               WHERE user_id = p_acting_user_id
                    AND vote_id = p_vote_id
                    AND option_id = p_option_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'You have already selected this option';
    END IF;

    INSERT INTO user_vote (
        user_id,
        vote_id,
        option_id
    )
    VALUES (
        p_acting_user_id,
        p_vote_id,
        p_option_id
    );
END;

/* ----------- RETRACT VOTE ------------ */
DROP PROCEDURE IF EXISTS sp_retract_vote;
CREATE PROCEDURE sp_retract_vote (
    IN p_acting_user_id INT,
    IN p_vote_id        INT,
    IN p_option_id      INT
)
BEGIN
    DECLARE v_status VARCHAR(10);

    SELECT status INTO v_status FROM vote WHERE vote_id = p_vote_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vote not found';
    END IF;

    IF v_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot retract from a non-active vote';
    END IF;

    DELETE FROM user_vote
    WHERE user_id = p_acting_user_id
        AND vote_id = p_vote_id
        AND option_id = p_option_id;
END;

/* ----------- GET VOTE RESULTS ------------ */
DROP PROCEDURE IF EXISTS sp_get_vote_results;
CREATE PROCEDURE sp_get_vote_results (
    IN p_vote_id INT
)
BEGIN
    SELECT  vo.option_id,
            vo.title,
            vo.sort_order,
            COUNT(uv.user_id) AS 'vote_count'
    FROM vote_option vo
    LEFT JOIN user_vote uv
        ON uv.option_id = vo.option_id 
            AND uv.vote_id = p_vote_id
    WHERE vo.vote_id = p_vote_id
    GROUP BY    vo.option_id,
                vo.title,
                vo.sort_order
    ORDER BY vo.sort_order;
END;

/* ----------- GET USER'S SELECTIONS FOR A VOTE ------------ */
DROP PROCEDURE IF EXISTS sp_get_user_vote_selections;
CREATE PROCEDURE sp_get_user_vote_selections (
    IN p_user_id INT,
    IN p_vote_id INT
)
BEGIN
    SELECT  uv.option_id,
            vo.title,
            uv.vote_time
    FROM user_vote uv
    JOIN vote_option vo
        ON vo.option_id = uv.option_id
    WHERE uv.user_id = p_user_id
        AND uv.vote_id = p_vote_id;
END;

/*----------------------------------- AUDIT LOG ------------------------------------*/

/* ----------- GET AUDIT LOG (paged, filterable) ------------ */
DROP PROCEDURE IF EXISTS sp_get_audit_log;
CREATE PROCEDURE sp_get_audit_log (
    IN p_acting_user_id INT,
    IN p_table_name     VARCHAR(100),   -- NULL = all tables
    IN p_changed_by     INT,   -- NULL = all users
    IN p_limit          INT,
    IN p_offset         INT
)
BEGIN
    CALL sp_require_permission(p_acting_user_id, 'AUDIT_VIEW');

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
END;
