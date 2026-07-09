USE smpdb;

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

INSERT INTO permission (name, description)
VALUES
    /* Images */
    ('IMAGE_VIEW', 'View images'),
    ('IMAGE_CREATE', 'Upload or create new images'),
    ('IMAGE_EDIT_OWN', 'Edit images owned by the current user'),
    ('IMAGE_EDIT_ALL', 'Edit any image regardless of ownership'),
    ('IMAGE_DELETE_OWN', 'Delete images owned by the current user'),
    ('IMAGE_DELETE_ALL', 'Delete any image regardless of ownership'),

    /* Users */
    ('USER_LIST_VIEW', 'View a list of users'),
    ('USER_VIEW_PROFILE_OWN', 'View own user profile'),
    ('USER_VIEW_PROFILE_ALL', 'View any user profile'),
    ('USER_VIEW_ACCOUNT_OWN', 'View own account details'),
    ('USER_VIEW_ACCOUNT_ALL', 'View any user account details'),
    ('USER_LOCK', 'Lock or unlock user accounts'),
    ('USER_CHANGE_PASSWORD_OWN', 'Change own password'),
    ('USER_CHANGE_PASSWORD_ALL', 'Change any user password'),
    ('USER_EDIT_OWN', 'Edit own user profile information'),
    ('USER_EDIT_ALL', 'Edit any user profile information'),
    ('USER_DELETE_OWN', 'Delete own user account'),
    ('USER_DELETE_ALL', 'Delete any user account'),

    /* Roles */
    ('ROLE_VIEW', 'View roles and role details'),
    ('ROLE_ASSIGN', 'Assign roles to users'),
    ('ROLE_CREATE', 'Create new roles'),
    ('ROLE_EDIT', 'Edit existing roles'),
    ('ROLE_DELETE', 'Delete roles'),

    /* Permissions */
    ('PERMISSION_VIEW', 'View permissions and permission definitions'),
    ('PERMISSION_ASSIGN', 'Assign permissions to roles or users'),

    /* Builds */
    ('BUILD_VIEW', 'View builds'),
    ('BUILD_CREATE', 'Create new builds'),
    ('BUILD_EDIT_OWN', 'Edit builds owned by the current user'),
    ('BUILD_EDIT_ALL', 'Edit any build regardless of ownership'),
    ('BUILD_DELETE_OWN', 'Delete builds owned by the current user'),
    ('BUILD_DELETE_ALL', 'Delete any build regardless of ownership'),

    /* Tags */
    ('TAG_VIEW', 'View tags'),
    ('TAG_CREATE', 'Create new tags'),
    ('TAG_EDIT', 'Edit existing tags'),
    ('TAG_DELETE', 'Delete tags'),

    /* Votes */
    ('VOTE_VIEW', 'View votes'),
    ('VOTE_CREATE', 'Create or register a vote'),
    ('VOTE_EDIT_OWN', 'Edit own votes'),
    ('VOTE_EDIT_ALL', 'Edit any vote'),
    ('VOTE_DELETE_OWN', 'Delete own votes'),
    ('VOTE_DELETE_ALL', 'Delete any vote'),
    ('VOTE_CAST', 'Cast a vote on content'),

    /* Audit */
    ('AUDIT_VIEW', 'View system audit logs'),

    /* Posts */
    ('POST_CREATE', 'Create new posts'),
    ('POST_EDIT_OWN', 'Edit posts owned by the current user'),
    ('POST_EDIT_ALL', 'Edit any post regardless of ownership'),
    ('POST_DELETE_OWN', 'Delete posts owned by the current user'),
    ('POST_DELETE_ALL', 'Delete any post regardless of ownership'),
    ('POST_PUBLISH_NEWS', 'Publish posts as news content'),
    ('POST_PUBLISH_ANNOUNCEMENT', 'Publish posts as announcements');

-- Assign all permissions to ADMIN role (role_id = 1)
INSERT INTO role_permission (
    role_id,
    permission_id,
    created_by
)
SELECT  1,
        permission_id,
        1
FROM permission;

-- Assign permissions to USER role (role_id = 2)
INSERT INTO role_permission (
    role_id,
    permission_id,
    created_by
)
SELECT  2,
        permission_id,
        1
FROM permission
WHERE name IN (
    'IMAGE_CREATE',

    'USER_VIEW_PROFILE_OWN',
    'USER_VIEW_PROFILE_ALL',
    'USER_VIEW_ACCOUNT_OWN',
    'USER_CHANGE_PASSWORD_OWN',
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
