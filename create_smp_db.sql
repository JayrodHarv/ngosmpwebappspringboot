/*
	FILE: 	create_smp_db.sql
    DATE:	2024-02-22
    AUTHOR:	Jared Harvey
    DESCRIPTION:
		Builds a database made for the Java III final project
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

DROP TABLE IF EXISTS Role;
CREATE TABLE Role (
    # Use bootstrap accordion for these
    RoleID VARCHAR(255) NOT NULL,
    # Builds
    CanAddBuilds BIT NOT NULL DEFAULT 0,
    CanEditAllBuilds BIT NOT NULL DEFAULT 0,
    CanDeleteAllBuilds BIT NOT NULL DEFAULT 0,
    # BuildTypes
    CanViewBuildTypes BIT NOT NULL DEFAULT 0,
    CanAddBuildTypes BIT NOT NULL DEFAULT 0,
    CanEditBuildTypes BIT NOT NULL DEFAULT 0,
    CanDeleteBuildTypes BIT NOT NULL DEFAULT 0,
    # Worlds
    CanViewWorlds BIT NOT NULL DEFAULT 0,
    CanAddWorlds BIT NOT NULL DEFAULT 0,
    CanEditWorlds BIT NOT NULL DEFAULT 0,
    CanDeleteWorlds BIT NOT NULL DEFAULT 0,
    # Votes
    CanViewAllVotes BIT NOT NULL DEFAULT 0,
    CanAddVotes BIT NOT NULL DEFAULT 0,
    CanEditAllVotes BIT NOT NULL DEFAULT 0,
    CanDeleteAllVotes BIT NOT NULL DEFAULT 0,
    # Roles
    CanViewRoles BIT NOT NULL DEFAULT 0,
    CanAddRoles BIT NOT NULL DEFAULT 0,
    CanEditRoles BIT NOT NULL DEFAULT 0,
    CanDeleteRoles BIT NOT NULL DEFAULT 0,
    # Users
    CanViewUsers BIT NOT NULL DEFAULT 0,
    CanAddUsers BIT NOT NULL DEFAULT 0,
    CanEditUsers BIT NOT NULL DEFAULT 0,
    CanBanUsers BIT NOT NULL DEFAULT 0,

    Description VARCHAR(255) NOT NULL,
    CONSTRAINT PRIMARY KEY(RoleID)
);

DROP TABLE IF EXISTS Image;
CREATE TABLE Image (
    ImageID INT PRIMARY KEY AUTO_INCREMENT,
    FileName VARCHAR(255) NOT NULL,
    MimeType VARCHAR(100) NOT NULL,
    FileSize BIGINT NOT NULL,
    FilePath VARCHAR(500) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FileHash CHAR(64) NOT NULL UNIQUE
);

DROP TABLE IF EXISTS User;
CREATE TABLE User (
	UserID VARCHAR(255) NOT NULL COMMENT 'Primary key of user is their email',
	DisplayName VARCHAR(255) NOT NULL UNIQUE,
	Password VARCHAR(255) NOT NULL,
	Language VARCHAR(255) NOT NULL DEFAULT 'en-US',
	Status ENUM('active', 'inactive', 'locked') NOT NULL DEFAULT 'active',
    RoleID VARCHAR(255) NULL DEFAULT 'User',
	CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	LastLoggedIn DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
	UpdatedAt DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PfpImageID INT NULL,
    CONSTRAINT fk_User_Role FOREIGN KEY(RoleID)
        REFERENCES Role(RoleID)
            ON UPDATE CASCADE
            ON DELETE SET NULL,
    CONSTRAINT fk_User_PfpImage FOREIGN KEY(PfpImageID)
        REFERENCES Image(ImageID)
            ON UPDATE CASCADE
            ON DELETE SET NULL,
    CONSTRAINT pk_User PRIMARY KEY(UserID)
);

-- CREATE TABLE 2fa_code (
-- 	CodeID INT AUTO_INCREMENT PRIMARY KEY,
-- 	UserID VARCHAR(255) NOT NULL,
-- 	Code VARCHAR(6) NOT NULL,
-- 	Method ENUM ('email', 'sms', 'phone') NOT NULL,
-- 	CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
-- 	CONSTRAINT fk_2fa_code_UserID FOREIGN KEY (UserID)
-- 	    REFERENCES User(UserID)
-- 	        ON UPDATE CASCADE
-- 	        ON DELETE CASCADE
-- );

-- CREATE TABLE PasswordReset (
--     ResetID    INT AUTO_INCREMENT PRIMARY KEY,
--     UserID     VARCHAR(255)                       NOT NULL,
--     Token      VARCHAR(255)                       NOT NULL,
--     CreatedAt  DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
--     CONSTRAINT fk_PasswordReset_UserID FOREIGN KEY (UserID)
--         REFERENCES User (UserID)
--             ON UPDATE CASCADE
--             ON DELETE CASCADE
-- );

-- CREATE INDEX UserID ON PasswordReset (UserID);

DROP TABLE IF EXISTS World;
CREATE TABLE World (
    WorldID VARCHAR(255) NOT NULL COMMENT 'Name of world is primary key',
    DateStarted DATE NOT NULL,
    Description TEXT NOT NULL,
    CONSTRAINT pk_World PRIMARY KEY(WorldID)
);

DROP TABLE IF EXISTS BuildType;
CREATE TABLE BuildType (
    BuildTypeID VARCHAR(255) NOT NULL,
    #TODO: Add color field. Use input type="color" for color picker. Could do with world too.
    # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/color
    Description TEXT NOT NULL,
    CONSTRAINT pk_BuildType PRIMARY KEY(BuildTypeID)
);

DROP TABLE IF EXISTS Build;
CREATE TABLE Build (
	BuildID VARCHAR(100) NOT NULL COMMENT 'Primary key is the name of build',
	UserID VARCHAR(255) NULL,
	WorldID VARCHAR(255) NULL,
	BuildTypeID VARCHAR(255) NULL,
	DateBuilt DATE NULL,
	XCoord INT NULL,
    YCoord INT NULL,
    ZCoord INT NULL,
	CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	Description TEXT NOT NULL,
	CONSTRAINT fk_Build_UserID FOREIGN KEY(UserID)
	    REFERENCES User(UserID)
	        ON UPDATE CASCADE
            ON DELETE SET NULL,
    CONSTRAINT fk_Build_WorldID FOREIGN KEY(WorldID)
        REFERENCES World(WorldID)
            ON UPDATE CASCADE
            ON DELETE SET NULL,
    CONSTRAINT fk_Build_BuildType FOREIGN KEY(BuildTypeID)
        REFERENCES BuildType(BuildTypeID)
            ON UPDATE CASCADE
            ON DELETE SET NULL,
	CONSTRAINT pk_Build PRIMARY KEY(BuildID)
);

CREATE TABLE BuildImage (
    BuildID VARCHAR(100) NOT NULL,
    ImageID INT NOT NULL,
    IsPrimary BIT DEFAULT 0,
    SortOrder INT DEFAULT 0,

    CONSTRAINT fk_BuildImage_Build FOREIGN KEY(BuildID)
        REFERENCES Build(BuildID)
            ON DELETE CASCADE,
    CONSTRAINT fk_BuildImage_Image FOREIGN KEY(ImageID)
        REFERENCES Image(ImageID)
            ON DELETE CASCADE,
    CONSTRAINT pk_BuildImage PRIMARY KEY(BuildID, ImageID)
);

-- DROP TABLE IF EXISTS DiscussionForm;
-- CREATE TABLE DiscussionForm (
-- 	DiscussionID VARCHAR(100),
-- 	CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
-- 	Active BIT DEFAULT 1,
-- 	CONSTRAINT pk_Discussion PRIMARY KEY(DiscussionID)
-- );

-- DROP TABLE IF EXISTS Message;
-- CREATE TABLE Message (
-- 	MessageID INT NOT NULL,
-- 	UserID VARCHAR(255) NULL,
-- 	DiscussionID VARCHAR(100) NOT NULL,
-- 	Text TEXT NOT NULL,
-- 	SentAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
-- 	CONSTRAINT fk_Message_UserID FOREIGN KEY(UserID)
-- 	    REFERENCES User(UserID)
--             ON UPDATE CASCADE
--             ON DELETE SET NULL,
-- 	CONSTRAINT fk_Message_DiscussionID FOREIGN KEY(DiscussionID)
-- 		 REFERENCES DiscussionForm(DiscussionID)
--             ON UPDATE CASCADE
--             ON DELETE CASCADE,
-- 	CONSTRAINT pk_Message PRIMARY KEY(MessageID)
-- );

DROP TABLE IF EXISTS Vote;
CREATE TABLE Vote (
	VoteID VARCHAR(255) NOT NULL,
	UserID VARCHAR(255) NULL,
	Description TEXT NOT NULL,
	StartTime DATETIME NULL,
	EndTime DATETIME NULL,
    CONSTRAINT fk_Vote_UserID FOREIGN KEY(UserID)
        REFERENCES User(UserID)
            ON UPDATE CASCADE
            ON DELETE SET NULL,
    CONSTRAINT pk_Vote PRIMARY KEY(VoteID)
);

DROP TABLE IF EXISTS VoteOption;
CREATE TABLE VoteOption (
    OptionID INT AUTO_INCREMENT,
    VoteID VARCHAR(255) NOT NULL,
    Title VARCHAR(255) NOT NULL,
    Description TEXT NOT NULL,
    ImageID INT NULL,
    CONSTRAINT fk_VoteOption_VoteID FOREIGN KEY(VoteID)
        REFERENCES Vote(VoteID)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT fk_VoteOption_Image FOREIGN KEY(ImageID)
        REFERENCES Image(ImageID)
            ON UPDATE CASCADE
            ON DELETE SET NULL,
    CONSTRAINT ak_VoteOption UNIQUE (VoteID, Title),
    CONSTRAINT pk_VoteOption PRIMARY KEY(OptionID)
);

DROP TABLE IF EXISTS UserVote;
CREATE TABLE UserVote (
	UserID VARCHAR(255) NULL,
	VoteID VARCHAR(255) NOT NULL,
	OptionID INT NOT NULL,
	VoteTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT fk_UserVote_UserID FOREIGN KEY(UserID)
	    REFERENCES User(UserID)
            ON UPDATE CASCADE
            ON DELETE SET NULL,
	CONSTRAINT fk_UserVote_VoteID FOREIGN KEY(VoteID)
	    REFERENCES Vote(VoteID)
          ON UPDATE CASCADE
          ON DELETE CASCADE,
	CONSTRAINT pk_UserVote UNIQUE (UserID, VoteID)
);

/*****************************************************************************
					STORED PROCEDURES / CRUD FUNCTIONS
*****************************************************************************/
/*-----------------------------------ROLE------------------------------------*/

/* GET ALL ROLES */
DROP PROCEDURE IF EXISTS sp_get_all_roles;
CREATE PROCEDURE sp_get_all_roles()
BEGIN
    SELECT RoleID,
           # Builds
           CanAddBuilds,
           CanEditAllBuilds,
           CanDeleteAllBuilds,
           # BuildTypes
           CanViewBuildTypes,
           CanAddBuildTypes,
           CanEditBuildTypes,
           CanDeleteBuildTypes,
           # Worlds
           CanViewWorlds,
           CanAddWorlds,
           CanEditWorlds,
           CanDeleteWorlds,
           # Votes
           CanViewAllVotes,
           CanAddVotes,
           CanEditAllVotes,
           CanDeleteAllVotes,
           # Roles
           CanViewRoles,
           CanAddRoles,
           CanEditRoles,
           CanDeleteRoles,
           # Users
           CanViewUsers,
           CanAddUsers,
           CanEditUsers,
           CanBanUsers,
           Description
    FROM Role
    ;
END;

/* INSERT ROLE */
DROP PROCEDURE IF EXISTS sp_insert_role;
CREATE PROCEDURE sp_insert_role(
    IN p_RoleID VARCHAR(255),
    # Builds
    IN p_CanAddBuilds BIT,
    IN p_CanEditAllBuilds BIT,
    IN p_CanDeleteAllBuilds BIT,
    # BuildTypes
    IN p_CanViewBuildTypes BIT,
    IN p_CanAddBuildTypes BIT,
    IN p_CanEditBuildTypes BIT,
    IN p_CanDeleteBuildTypes BIT,
    # Worlds
    IN p_CanViewWorlds BIT,
    IN p_CanAddWorlds BIT,
    IN p_CanEditWorlds BIT,
    IN p_CanDeleteWorlds BIT,
    # Votes
    IN p_CanViewAllVotes BIT,
    IN p_CanAddVotes BIT,
    IN p_CanEditAllVotes BIT,
    IN p_CanDeleteAllVotes BIT,
    # Roles
    IN p_CanViewRoles BIT,
    IN p_CanAddRoles BIT,
    IN p_CanEditRoles BIT,
    IN p_CanDeleteRoles BIT,
    # Users
    IN p_CanViewUsers BIT,
    IN p_CanAddUsers BIT,
    IN p_CanEditUsers BIT,
    IN p_CanBanUsers BIT,
    IN p_Description VARCHAR(255)
)
BEGIN
    INSERT INTO Role (
        RoleID,
        # Builds
        CanAddBuilds,
        CanEditAllBuilds,
        CanDeleteAllBuilds,
        # BuildTypes
        CanViewBuildTypes,
        CanAddBuildTypes,
        CanEditBuildTypes,
        CanDeleteBuildTypes,
        # Worlds
        CanViewWorlds,
        CanAddWorlds,
        CanEditWorlds,
        CanDeleteWorlds,
        # Votes
        CanViewAllVotes,
        CanAddVotes,
        CanEditAllVotes,
        CanDeleteAllVotes,
        # Roles
        CanViewRoles,
        CanAddRoles,
        CanEditRoles,
        CanDeleteRoles,
        # Users
        CanViewUsers,
        CanAddUsers,
        CanEditUsers,
        CanBanUsers,

        Description
    )
    VALUES (
       p_RoleID,
       # Builds
       p_CanAddBuilds,
       p_CanEditAllBuilds,
       p_CanDeleteAllBuilds,
       # BuildTypes
       p_CanViewBuildTypes,
       p_CanAddBuildTypes,
       p_CanEditBuildTypes,
       p_CanDeleteBuildTypes,
       # Worlds
       p_CanViewWorlds,
       p_CanAddWorlds,
       p_CanEditWorlds,
       p_CanDeleteWorlds,
       # Votes
       p_CanViewAllVotes,
       p_CanAddVotes,
       p_CanEditAllVotes,
       p_CanDeleteAllVotes,
       # Roles
       p_CanViewRoles,
       p_CanAddRoles,
       p_CanEditRoles,
       p_CanDeleteRoles,
       # Users
       p_CanViewUsers,
       p_CanAddUsers,
       p_CanEditUsers,
       p_CanBanUsers,

       p_Description
    )
    ;
END;

/* UPDATE ROLE */
DROP PROCEDURE IF EXISTS sp_update_role;
CREATE PROCEDURE sp_update_role(
    IN p_RoleID VARCHAR(255),
    # Builds
    IN p_CanAddBuilds BIT,
    IN p_CanEditAllBuilds BIT,
    IN p_CanDeleteAllBuilds BIT,
    # BuildTypes
    IN p_CanViewBuildTypes BIT,
    IN p_CanAddBuildTypes BIT,
    IN p_CanEditBuildTypes BIT,
    IN p_CanDeleteBuildTypes BIT,
    # Worlds
    IN p_CanViewWorlds BIT,
    IN p_CanAddWorlds BIT,
    IN p_CanEditWorlds BIT,
    IN p_CanDeleteWorlds BIT,
    # Votes
    IN p_CanViewAllVotes BIT,
    IN p_CanAddVotes BIT,
    IN p_CanEditAllVotes BIT,
    IN p_CanDeleteAllVotes BIT,
    # Roles
    IN p_CanViewRoles BIT,
    IN p_CanAddRoles BIT,
    IN p_CanEditRoles BIT,
    IN p_CanDeleteRoles BIT,
    # Users
    IN p_CanViewUsers BIT,
    IN p_CanAddUsers BIT,
    IN p_CanEditUsers BIT,
    IN p_CanBanUsers BIT,
    IN p_Description VARCHAR(255),
    IN p_OldRoleID VARCHAR(255)
)
BEGIN
    UPDATE Role
    SET RoleID = p_RoleID,
        # Builds
        CanAddBuilds = p_CanAddBuilds,
        CanEditAllBuilds = p_CanEditAllBuilds,
        CanDeleteAllBuilds = p_CanDeleteAllBuilds,
        # BuildTypes
        CanViewBuildTypes = p_CanViewBuildTypes,
        CanAddBuildTypes = p_CanAddBuildTypes,
        CanEditBuildTypes = p_CanEditBuildTypes,
        CanDeleteBuildTypes = p_CanDeleteBuildTypes,
        # Worlds
        CanViewWorlds = p_CanViewWorlds,
        CanAddWorlds = p_CanAddWorlds,
        CanEditWorlds = p_CanEditWorlds,
        CanDeleteWorlds = p_CanDeleteWorlds,
        # Votes
        CanViewAllVotes = p_CanViewAllVotes,
        CanAddVotes = p_CanAddVotes,
        CanEditAllVotes = p_CanEditAllVotes,
        CanDeleteAllVotes = p_CanDeleteAllVotes,
        # Roles
        CanViewRoles = p_CanViewRoles,
        CanAddRoles = p_CanAddRoles,
        CanEditRoles = p_CanEditRoles,
        CanDeleteRoles = p_CanDeleteRoles,
        # Users
        CanViewUsers = p_CanViewUsers,
        CanAddUsers = p_CanAddUsers,
        CanEditUsers = p_CanEditUsers,
        CanBanUsers = p_CanBanUsers,

        Description = p_Description
    WHERE RoleID = p_OldRoleID
    ;
END;

/* GET ROLE */
DROP PROCEDURE IF EXISTS sp_get_role;
CREATE PROCEDURE sp_get_role(
    IN p_RoleID VARCHAR(255)
)
BEGIN
    SELECT  RoleID,
            # Builds
            CanAddBuilds,
            CanEditAllBuilds,
            CanDeleteAllBuilds,
            # BuildTypes
            CanViewBuildTypes,
            CanAddBuildTypes,
            CanEditBuildTypes,
            CanDeleteBuildTypes,
            # Worlds
            CanViewWorlds,
            CanAddWorlds,
            CanEditWorlds,
            CanDeleteWorlds,
            # Votes
            CanViewAllVotes,
            CanAddVotes,
            CanEditAllVotes,
            CanDeleteAllVotes,
            # Roles
            CanViewRoles,
            CanAddRoles,
            CanEditRoles,
            CanDeleteRoles,
            # Users
            CanViewUsers,
            CanAddUsers,
            CanEditUsers,
            CanBanUsers,

            Description
    FROM Role
    WHERE RoleID = p_RoleID
    ;
END;

/*-----------------------------------Image------------------------------------*/

/* INSERT IMAGE */
DROP PROCEDURE IF EXISTS sp_insert_image;
CREATE PROCEDURE sp_insert_image(
    IN p_FileName VARCHAR(255),
    IN p_MimeType VARCHAR(100),
    IN p_FileSize BIGINT,
    IN p_FilePath VARCHAR(500),
    IN p_FileHash CHAR(64)
)
BEGIN
    DECLARE existing_id INT;

    SELECT ImageID INTO existing_id
    FROM Image
    WHERE FileHash = p_FileHash
    LIMIT 1;

    IF existing_id IS NOT NULL THEN
        SELECT existing_id AS ImageID;
    ELSE
        INSERT INTO Image (
            FileName,
            MimeType,
            FileSize,
            FilePath,
            FileHash
        )
        VALUES (
            p_FileName,
            p_MimeType,
            p_FileSize,
            p_FilePath,
            p_FileHash
        );

        SELECT LAST_INSERT_ID() AS ImageID;
    END IF;
END;

/* GET IMAGE */
DROP PROCEDURE IF EXISTS sp_get_image;
CREATE PROCEDURE sp_get_image(
    IN p_ImageID INT
)
BEGIN
    SELECT
        ImageID,
        FileName,
        MimeType,
        FileSize,
        FilePath,
        CreatedAt
    FROM Image
    WHERE ImageID = p_ImageID;
END;

/*GET IMAGE BY HASH*/
DROP PROCEDURE IF EXISTS sp_get_image_by_hash;
CREATE PROCEDURE sp_get_image_by_hash(
    IN p_hash CHAR(64)
)
BEGIN
    SELECT ImageID
    FROM Image
    WHERE FileHash = p_hash
    LIMIT 1;
END;

/* DELETE IMAGE */
DROP PROCEDURE IF EXISTS sp_delete_image;
CREATE PROCEDURE sp_delete_image(
    IN p_ImageID INT
)
BEGIN
    DELETE FROM Image
    WHERE ImageID = p_ImageID;
END;

/*-----------------------------------BuildImage------------------------------------*/
/* Insert Build Image */
DROP PROCEDURE IF EXISTS sp_insert_build_image;
CREATE PROCEDURE sp_insert_build_image(
    IN p_BuildID VARCHAR(100),
    IN p_ImageID INT,
    IN p_IsPrimary BOOLEAN,
    IN p_SortOrder INT
)
BEGIN
    INSERT INTO BuildImage (BuildID, ImageID, IsPrimary, SortOrder)
    VALUES (p_BuildID, p_ImageID, p_IsPrimary, p_SortOrder);
END;

/* Get Build Images */
DROP PROCEDURE IF EXISTS sp_get_build_images;
CREATE PROCEDURE sp_get_build_images(
    IN p_BuildID VARCHAR(100)
)
BEGIN
    SELECT 
        i.ImageID,
        i.FileName,
        i.FileSize,
        i.MimeType,
        i.FilePath,
        bi.IsPrimary,
        bi.SortOrder
    FROM BuildImage bi
    INNER JOIN Image i ON i.ImageID = bi.ImageID
    WHERE bi.BuildID = p_BuildID
    ORDER BY bi.SortOrder ASC;
END;

/* Delete Build Image */
DROP PROCEDURE IF EXISTS sp_delete_build_image;
CREATE PROCEDURE sp_delete_build_image(
    IN p_BuildID VARCHAR(100),
    IN p_ImageID INT
)
BEGIN
    DELETE FROM BuildImage
    WHERE BuildID = p_BuildID
    AND ImageID = p_ImageID;
END;

/*-----------------------------------USER------------------------------------*/

/* GET ALL USERS */
DROP PROCEDURE IF EXISTS sp_get_all_users;
CREATE PROCEDURE sp_get_all_users()
BEGIN
    SELECT  u.UserID,
            u.DisplayName,
            u.Password,
            u.Language,
            u.Status,
            u.RoleID,
            u.CreatedAt,
            u.LastLoggedIn,
            u.UpdatedAt,
            
            # Pfp
            i.ImageID,
            i.FileName,
            i.MimeType,
            i.FilePath
    FROM User u
    LEFT JOIN Image i ON u.PfpImageID = i.ImageID
    ;
END;

/* GET USER */
DROP PROCEDURE IF EXISTS sp_get_userVM;
CREATE PROCEDURE sp_get_userVM(
    IN p_UserID VARCHAR(255)
)
BEGIN
    SELECT 	u.UserID, u.DisplayName, u.Language, u.Status,
            u.RoleID, u.CreatedAt, u.LastLoggedIn, u.UpdatedAt,
            # Builds
            r.CanAddBuilds,
            r.CanEditAllBuilds,
            r.CanDeleteAllBuilds,
            # BuildTypes
            r.CanViewBuildTypes,
            r.CanAddBuildTypes,
            r.CanEditBuildTypes,
            r.CanDeleteBuildTypes,
            # Worlds
            r.CanViewWorlds,
            r.CanAddWorlds,
            r.CanEditWorlds,
            r.CanDeleteWorlds,
            # Votes
            r.CanViewAllVotes,
            r.CanAddVotes,
            r.CanEditAllVotes,
            r.CanDeleteAllVotes,
            # Roles
            r.CanViewRoles,
            r.CanAddRoles,
            r.CanEditRoles,
            r.CanDeleteRoles,
            # Users
            r.CanViewUsers,
            r.CanAddUsers,
            r.CanEditUsers,
            r.CanBanUsers,

            r.Description,

            # Pfp
            i.ImageID,
            i.FileName,
            i.MimeType,
            i.FilePath
    FROM User AS u
    INNER JOIN Role AS r ON u.RoleID = r.RoleID
    LEFT JOIN Image i ON u.PfpImageID = i.ImageID
    WHERE UserID = p_UserID
    ;
END;

/* GET USER */
DROP PROCEDURE IF EXISTS sp_get_user;
CREATE PROCEDURE sp_get_user(
    IN p_UserID VARCHAR(255)
)
BEGIN
    SELECT 	UserID,
            DisplayName,
            Password,
            Language,
            Status,
            RoleID,
            CreatedAt,
            LastLoggedIn,
            UpdatedAt,
            PfpImageID
    FROM User
    WHERE UserID = p_UserID
    ;
END;

/* INSERT USER */
DROP PROCEDURE IF EXISTS sp_insert_user;
CREATE PROCEDURE sp_insert_user(
    IN p_UserID VARCHAR(255),
    IN p_Password VARCHAR(255),
    IN p_DisplayName VARCHAR(100)
)
BEGIN
    INSERT INTO User
        (UserID, Password, DisplayName)
    VALUES
        (p_UserID, p_Password, p_DisplayName)
    ;
    -- Generate a random 6 digit code
    -- SET @code=LPAD(FLOOR(RAND() * 999999.99), 6, '0');
    -- Create new 2 Factor Authentication Code
    -- INSERT INTO 2fa_code (UserID, Code, Method) VALUES (p_UserID, @code, 'email');
END;

/* UPDATE USER */
DROP PROCEDURE IF EXISTS sp_update_user;
CREATE PROCEDURE sp_update_user(
    IN p_UserID VARCHAR(255),
    IN p_DisplayName VARCHAR(100),
    IN p_PfpImageID INT,
    IN p_Language VARCHAR(255),
    IN p_Status VARCHAR(255),
    IN p_RoleID VARCHAR(255),
    IN p_LastLoggedIn DATETIME
)
BEGIN
    UPDATE User
    SET DisplayName =  p_DisplayName,
        PfpImageID = p_PfpImageID,
        Language =  p_Language,
        Status = p_Status,
        RoleID = p_RoleID,
        LastLoggedIn = p_LastLoggedIn
    WHERE UserID = p_UserID
    ;
END;

/* UPDATE USER ROLE */
DROP PROCEDURE IF EXISTS sp_update_user_role;
CREATE PROCEDURE sp_update_user_role(
    IN p_UserID VARCHAR(255),
    IN p_RoleID VARCHAR(255)
)
BEGIN
    UPDATE User
    SET RoleID = p_RoleID
    WHERE UserID = p_UserID
    ;
END;

/* UPDATE USER PASSWORD */
DROP PROCEDURE IF EXISTS sp_update_user_password;
CREATE PROCEDURE sp_update_user_password(
    IN p_UserID VARCHAR(255),
    IN p_Password VARCHAR(255)
)
BEGIN
    UPDATE User
    SET Password = p_Password
    WHERE UserID = p_UserID
    ;
END;

/* DELETE USER */
DROP PROCEDURE IF EXISTS sp_delete_user;
CREATE PROCEDURE sp_delete_user(
    IN p_UserID VARCHAR(255)
)
BEGIN
    DELETE FROM User
    WHERE UserID = p_UserID
    ;
END;

/*-----------------------------------PASSWORDRESET------------------------------------*/
-- DROP PROCEDURE IF EXISTS sp_get_password_reset;
-- CREATE PROCEDURE sp_get_password_reset(
--     IN p_token VARCHAR(255)
-- )
-- BEGIN
--     SELECT ResetID, UserID, CreatedAt
--     FROM PasswordReset
--     WHERE token = p_token
--     ;
-- END;

-- DROP PROCEDURE IF EXISTS sp_add_password_reset;
-- CREATE PROCEDURE sp_add_password_reset(
--     IN p_email VARCHAR(255), IN p_token VARCHAR(255)
-- )
-- BEGIN
--     -- Delete any previous password_reset
--     DELETE FROM PasswordReset WHERE UserID = p_email;
--     -- Create a new password_reset
--     INSERT INTO PasswordReset (UserID, Token) VALUES (p_email, p_token)
--     ;
-- END;

-- DROP PROCEDURE IF EXISTS sp_delete_password_reset;
-- CREATE PROCEDURE sp_delete_password_reset(
--     IN p_email VARCHAR(255)
-- )
-- BEGIN
--     DELETE FROM PasswordReset WHERE UserID = p_email
--     ;
-- END;


/*-----------------------------------2FACODE------------------------------------*/

/* ADD 2FA CODE */
-- DROP PROCEDURE IF EXISTS sp_add_2fa_code;
-- CREATE PROCEDURE sp_add_2fa_code(
--     IN p_UserID VARCHAR(255),
--     IN p_Code VARCHAR(6),
--     IN p_Method ENUM('email', 'sms', 'phone')
-- )
-- BEGIN
--     -- Delete any previous 2fa_code
--     DELETE FROM 2fa_code WHERE UserID = p_UserID;
--     -- Create a new 2FA code
--     INSERT INTO 2fa_code (UserID, Code, Method) VALUES (p_UserID, p_Code, p_Method)
--     ;
-- END;

-- /* GET 2FA CODE */
-- DROP PROCEDURE IF EXISTS sp_get_2fa_code;
-- CREATE PROCEDURE sp_get_2fa_code(
-- 	IN p_UserID VARCHAR(255)
-- )
-- BEGIN
--     SELECT t.Code, t.Method, t.CreatedAt
--     FROM User AS u
--     INNER JOIN 2fa_code AS t
--     ON u.UserID = t.UserID
--     WHERE t.UserID = p_UserID
--     ;
-- END;

/*-----------------------------------BUILD------------------------------------*/

/* INSERT Build */
DROP PROCEDURE IF EXISTS sp_insert_build;
CREATE PROCEDURE sp_insert_build(
    IN p_BuildID VARCHAR(100),
    IN p_UserID VARCHAR(255),
    IN p_WorldID VARCHAR(255),
    IN p_BuildType VARCHAR(255),
    IN p_DateBuilt DATE,
    IN p_XCoord INT,
    IN p_YCoord INT,
    IN p_ZCoord INT,
    IN p_Description TEXT
)
BEGIN
    INSERT INTO Build (
        BuildID,
        UserID,
        WorldID,
        BuildTypeID,
        DateBuilt,
        XCoord,
        YCoord,
        ZCoord,
        Description
    )
    VALUES (
        p_BuildID,
        p_UserID,
        p_WorldID,
        p_BuildType,
        p_DateBuilt,
        p_XCoord,
        p_YCoord,
        p_ZCoord,
        p_Description
    );
END;

/* UPDATE Build */
DROP PROCEDURE IF EXISTS sp_update_build;
CREATE PROCEDURE sp_update_build(
    IN p_BuildID VARCHAR(100),
    IN p_WorldID VARCHAR(255),
    IN p_BuildType VARCHAR(255),
    IN p_DateBuilt DATE,
    IN p_XCoord INT,
    IN p_YCoord INT,
    IN p_ZCoord INT,
    IN p_Description TEXT
)
BEGIN
    UPDATE Build
    SET WorldID = p_WorldID,
        BuildTypeID = p_BuildType,
        DateBuilt = p_DateBuilt,
        XCoord = p_XCoord,
        YCoord = p_YCoord,
        ZCoord = p_ZCoord,
        Description = p_Description
    WHERE BuildID = p_BuildID
    ;
END;

/* DELETE Build */
DROP PROCEDURE IF EXISTS sp_delete_build;
CREATE PROCEDURE sp_delete_build(
    IN p_BuildID VARCHAR(100)
)
BEGIN
    DELETE FROM Build
    WHERE BuildID = p_BuildID
    ;
END;

/* GET Builds */
DROP PROCEDURE IF EXISTS sp_get_builds;
CREATE PROCEDURE sp_get_builds(
    IN p_limit INT,
    IN p_offset INT,
    IN p_WorldID VARCHAR(255),
    IN p_BuildType VARCHAR(255),
    -- TODO: Add ability to search by dateBuilt
    IN p_UserDisplayName VARCHAR(255)
)
BEGIN
    SELECT  b.BuildID,
            b.UserID,
            b.DateBuilt,
            b.XCoord,
            b.YCoord,
            b.ZCoord,
            b.CreatedAt,
            b.Description AS 'build_desc',
            
            w.WorldID,
            w.DateStarted,
            w.Description AS 'world_desc',

            bt.BuildTypeID,
            bt.Description AS 'buildtype_desc',

            u.DisplayName AS 'UserDisplayName',

            i.ImageID,
            i.FileName,
            i.MimeType,
            i.FilePath

	FROM Build b
	INNER JOIN User u ON u.UserID = b.UserID
	LEFT JOIN World w ON b.WorldID = w.WorldID
	LEFT JOIN BuildType bt ON b.BuildTypeID = bt.BuildTypeID
    LEFT JOIN BuildImage bi
        ON bi.BuildID = b.BuildID
        AND bi.IsPrimary = 1
    LEFT JOIN Image i ON i.ImageID = bi.ImageID
    WHERE (
        IF(p_WorldID <> '', p_WorldID LIKE CONCAT('%', b.WorldID, '%'), TRUE)
    )
    AND (
        IF(p_BuildType <> '', p_BuildType LIKE CONCAT('%', b.BuildTypeID, '%'), TRUE)
    )
    AND (
        IF(p_UserDisplayName <> '', p_UserDisplayName LIKE CONCAT('%', u.DisplayName, '%'), TRUE)
    )
    LIMIT p_limit OFFSET p_offset
    ;
END;

/* GET Number of builds */
DROP PROCEDURE IF EXISTS sp_get_number_of_builds;
CREATE PROCEDURE sp_get_number_of_builds(
    IN p_WorldID VARCHAR(255),
    IN p_BuildType VARCHAR(255),
    # TODO: Add ability to search by dateBuilt
    IN p_UserDisplayName VARCHAR(255)
)
BEGIN
    SELECT COUNT(*) as number_of_builds
    FROM Build AS b
     INNER JOIN User AS u ON u.UserID = b.UserID
     LEFT JOIN World AS w ON b.WorldID = w.WorldID
     LEFT JOIN BuildType AS bt ON b.BuildTypeID = bt.BuildTypeID
    WHERE (
        IF(p_WorldID <> '', p_WorldID LIKE CONCAT('%', b.WorldID, '%'), TRUE)
    )
      AND (
        IF(p_BuildType <> '', p_BuildType LIKE CONCAT('%', b.BuildTypeID, '%'), TRUE)
    )
      AND (
        IF(p_UserDisplayName <> '', p_UserDisplayName LIKE CONCAT('%', u.DisplayName, '%'), TRUE)
    )
    ;
END;

/* GET Build */
DROP PROCEDURE IF EXISTS sp_get_build;
CREATE PROCEDURE sp_get_build(
	IN p_BuildID VARCHAR(100)
)
BEGIN
    SELECT  b.BuildID,
            b.UserID,
            b.DateBuilt,
            b.XCoord,
            b.YCoord,
            b.ZCoord,
            b.CreatedAt,
            b.Description AS 'build_desc',

            u.DisplayName AS 'UserDisplayName',

            w.WorldID,
            w.DateStarted,
            w.Description AS 'world_desc',

            bt.BuildTypeID,
            bt.Description AS 'buildtype_desc',

            i.ImageID,
            i.FileName,
            i.MimeType,
            i.FilePath

    FROM Build b
    LEFT JOIN User u ON b.UserID = u.UserID
    LEFT JOIN World w ON b.WorldID = w.WorldID
    LEFT JOIN BuildType bt ON b.BuildTypeID = bt.BuildTypeID
    LEFT JOIN BuildImage bi
        ON bi.BuildID = b.BuildID
        AND bi.IsPrimary = 1
    LEFT JOIN Image i ON i.ImageID = bi.ImageID
    WHERE b.BuildID = p_BuildID
    ;
END;

/*-----------------------------------WORLD------------------------------------*/

/* INSERT World */
DROP PROCEDURE IF EXISTS sp_insert_world;
CREATE PROCEDURE sp_insert_world(
    IN p_WorldID VARCHAR(255),
    IN p_DateStarted DATE,
    IN p_Description TEXT
)
BEGIN
    INSERT INTO World
        (WorldID, DateStarted, Description)
    VALUES
        (p_WorldID, p_DateStarted, p_Description)
    ;
END;

/* UPDATE World */
DROP PROCEDURE IF EXISTS sp_update_world;
CREATE PROCEDURE sp_update_world(
    IN p_WorldID VARCHAR(255),
    IN p_DateStarted DATE,
    IN p_Description TEXT,
    IN p_oldWorldID VARCHAR(255)
)
BEGIN
    UPDATE World
    SET WorldID = p_WorldID,
        DateStarted = p_DateStarted,
        Description = p_Description
    WHERE WorldID = p_oldWorldID
    ;
END;

/* DELETE World */
DROP PROCEDURE IF EXISTS sp_delete_world;
CREATE PROCEDURE sp_delete_world(
    IN p_WorldID VARCHAR(255)
)
BEGIN
    DELETE FROM World
    WHERE WorldID = p_WorldID
    ;
END;

/* GET Worlds */
DROP PROCEDURE IF EXISTS sp_get_all_worlds;
CREATE PROCEDURE sp_get_all_worlds()
BEGIN
    SELECT WorldID, DateStarted, Description
    FROM World
    ORDER BY DateStarted DESC
    ;
END;

/* GET World */
DROP PROCEDURE IF EXISTS sp_get_world;
CREATE PROCEDURE sp_get_world(
    IN p_WorldID VARCHAR(255)
)
BEGIN
    SELECT WorldID, DateStarted, Description
    FROM World
    WHERE WorldID = p_WorldID
    ;
END;

/*-----------------------------------BUILDTYPE------------------------------------*/

/* INSERT BuildType */
DROP PROCEDURE IF EXISTS sp_insert_buildtype;
CREATE PROCEDURE sp_insert_buildtype(
    IN p_BuildTypeID VARCHAR(255),
    IN p_Description TEXT
)
BEGIN
    INSERT INTO BuildType
        (BuildTypeID, Description)
    VALUES
        (p_BuildTypeID, p_Description)
    ;
END;

/* UPDATE BuildType */
DROP PROCEDURE IF EXISTS sp_update_buildtype;
CREATE PROCEDURE sp_update_buildtype(
    IN p_BuildTypeID VARCHAR(255),
    IN p_Description TEXT,
    IN p_OldBuildTypeID VARCHAR(255)
)
BEGIN
    UPDATE BuildType
    SET BuildTypeID = p_BuildTypeID,
        Description = p_Description
    WHERE BuildTypeID = p_OldBuildTypeID
    ;
END;

/* DELETE BuildType */
DROP PROCEDURE IF EXISTS sp_delete_buildtype;
CREATE PROCEDURE sp_delete_buildtype(
    IN p_BuildTypeID VARCHAR(255)
)
BEGIN
    DELETE FROM BuildType
    WHERE BuildTypeID = p_BuildTypeID
    ;
END;

/* GET BuildTypes */
DROP PROCEDURE IF EXISTS sp_get_all_buildtypes;
CREATE PROCEDURE sp_get_all_buildtypes()
BEGIN
    SELECT BuildTypeID, Description
    FROM BuildType
    ;
END;

/* GET BuildType */
DROP PROCEDURE IF EXISTS sp_get_buildtype;
CREATE PROCEDURE sp_get_buildtype(
    IN p_BuildTypeID VARCHAR(255)
)
BEGIN
    SELECT BuildTypeID, Description
    FROM BuildType
    WHERE BuildTypeID = p_BuildTypeID
    ;
END;

/*-----------------------------------VOTE------------------------------------*/

/* INSERT Vote */
DROP PROCEDURE IF EXISTS sp_insert_vote;
CREATE PROCEDURE sp_insert_vote(
    IN p_VoteID VARCHAR(255),
    IN p_UserID VARCHAR(255),
    IN p_Description TEXT,
    IN p_StartTime DATETIME,
    IN p_EndTime DATETIME
)
BEGIN
    INSERT INTO Vote
        (VoteID, UserID, Description, StartTime, EndTime)
    VALUES
        (p_VoteID, p_UserID, p_Description, p_StartTime, p_EndTime)
    ;
END;

/* UPDATE Vote */
DROP PROCEDURE IF EXISTS sp_update_vote;
CREATE PROCEDURE sp_update_vote(
    IN p_VoteID VARCHAR(255),
    IN p_Description TEXT,
    IN p_StartTime DATETIME,
    IN p_EndTime DATETIME,
    IN p_OldVoteID VARCHAR(255)
)
BEGIN
    UPDATE Vote
    SET VoteID = p_VoteID,
        Description = p_Description,
        StartTime = p_StartTime,
        EndTime = p_EndTime
    WHERE VoteID = p_OldVoteID
    ;
END;

-- Publish/Start a vote
DROP PROCEDURE IF EXISTS sp_publish_vote;
CREATE PROCEDURE sp_publish_vote(
    IN p_VoteID VARCHAR(255),
    IN p_StartTime DATETIME,
    IN p_EndTime DATETIME
)
BEGIN
    UPDATE Vote
    SET StartTime = p_StartTime,
        EndTime = p_EndTime
    WHERE VoteID = p_VoteID;
END;

/* DELETE Vote */
DROP PROCEDURE IF EXISTS sp_delete_vote;
CREATE PROCEDURE sp_delete_vote(
    IN p_VoteID VARCHAR(255)
)
BEGIN
    DELETE FROM Vote
    WHERE VoteID = p_VoteID
    ;
END;

/* GET Votes by UserID */
DROP PROCEDURE IF EXISTS sp_get_votes_by_user;
CREATE PROCEDURE sp_get_votes_by_user(
    IN p_UserID VARCHAR(255)
)
BEGIN
    SELECT v.VoteID, v.UserID, Description, StartTime, EndTime, COUNT(uv.UserID) AS 'num_of_votes'
    FROM Vote AS v
    LEFT JOIN UserVote AS uv ON v.VoteID = uv.VoteID
    WHERE v.UserID = p_UserID
    GROUP BY v.VoteID, v.UserID, Description, StartTime, EndTime
    ;
END;

/* GET Active Votes */
-- DROP PROCEDURE IF EXISTS sp_get_active_votes;
-- CREATE PROCEDURE sp_get_active_votes()
-- BEGIN
--     SELECT v.VoteID, v.UserID, Description, StartTime, EndTime, COUNT(uv.UserID) AS 'num_of_votes', u.DisplayName
--     FROM Vote AS v
--     LEFT JOIN UserVote AS uv ON v.VoteID = uv.VoteID
--     INNER JOIN User AS u ON v.UserID = u.UserID
--     WHERE StartTime IS NOT NULL AND EndTime IS NOT NULL
--     AND StartTime <= CURRENT_TIMESTAMP AND EndTime > CURRENT_TIMESTAMP
--     GROUP BY v.VoteID, v.UserID, Description, StartTime, EndTime, u.DisplayName
--     ORDER BY EndTime DESC
--     ;
-- END;

DROP PROCEDURE IF EXISTS sp_get_active_votes;
CREATE PROCEDURE sp_get_active_votes(
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SELECT 
        v.VoteID,
        v.UserID,
        v.Description,
        v.StartTime,
        v.EndTime,
        u.DisplayName,
        COUNT(DISTINCT vo.OptionID) AS total_options,
        COUNT(uv.UserID) AS total_votes
    FROM Vote v
    INNER JOIN User u ON v.UserID = u.UserID
    LEFT JOIN VoteOption vo ON v.VoteID = vo.VoteID
    LEFT JOIN UserVote uv ON v.VoteID = uv.VoteID
    WHERE v.StartTime IS NOT NULL
        AND v.EndTime IS NOT NULL
        AND v.StartTime <= CURRENT_TIMESTAMP
        AND v.EndTime > CURRENT_TIMESTAMP
    GROUP BY v.VoteID, v.UserID, v.Description, v.StartTime, v.EndTime, u.DisplayName
    ORDER BY v.EndTime ASC
    LIMIT p_limit OFFSET p_offset;
END;

-- Get Count of Active Votes
DROP PROCEDURE IF EXISTS sp_count_active_votes;
CREATE PROCEDURE sp_count_active_votes()
BEGIN
    SELECT COUNT(*) AS total
    FROM Vote v
    WHERE v.StartTime IS NOT NULL 
      AND v.EndTime IS NOT NULL
      AND v.StartTime <= CURRENT_TIMESTAMP 
      AND v.EndTime > CURRENT_TIMESTAMP;
END;

-- Get Pending Votes with Pagination (user's votes first)
DROP PROCEDURE IF EXISTS sp_get_pending_votes;
CREATE PROCEDURE sp_get_pending_votes(
    IN p_userId VARCHAR(255),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SELECT 
        v.VoteID,
        v.UserID,
        v.Description,
        v.StartTime,
        v.EndTime,
        u.DisplayName,
        COUNT(DISTINCT vo.OptionID) AS total_options,
        COUNT(uv.UserID) AS total_votes,
        -- Flag to indicate if current user created this vote
        CASE WHEN v.UserID = p_userId THEN 1 ELSE 0 END AS is_created_by_user
    FROM Vote v
    INNER JOIN User u ON v.UserID = u.UserID
    LEFT JOIN VoteOption vo ON v.VoteID = vo.VoteID
    LEFT JOIN UserVote uv ON v.VoteID = uv.VoteID
    WHERE (v.StartTime IS NULL OR v.StartTime > CURRENT_TIMESTAMP)
      AND (v.EndTime IS NULL OR v.EndTime > CURRENT_TIMESTAMP)
    GROUP BY v.VoteID, v.UserID, v.Description, v.StartTime, v.EndTime, u.DisplayName
    ORDER BY is_created_by_user DESC, v.StartTime ASC
    LIMIT p_limit OFFSET p_offset;
END;

-- Get Count of Pending Votes
DROP PROCEDURE IF EXISTS sp_count_pending_votes;
CREATE PROCEDURE sp_count_pending_votes()
BEGIN
    SELECT COUNT(*) AS total
    FROM Vote v
    WHERE (v.StartTime IS NULL OR v.StartTime > CURRENT_TIMESTAMP)
      AND (v.EndTime IS NULL OR v.EndTime > CURRENT_TIMESTAMP);
END;

-- Get Draft Votes (votes with no start time)
DROP PROCEDURE IF EXISTS sp_get_draft_votes;
CREATE PROCEDURE sp_get_draft_votes(
    IN p_UserID VARCHAR(255),
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SELECT 
        v.VoteID,
        v.UserID,
        v.Description,
        v.StartTime,
        v.EndTime,
        u.DisplayName,
        COUNT(DISTINCT vo.OptionID) AS total_options,
        COUNT(uv.UserID) AS total_votes,
        COUNT(DISTINCT uv.UserID) AS total_voters
    FROM Vote v
    INNER JOIN User u ON v.UserID = u.UserID
    LEFT JOIN VoteOption vo ON v.VoteID = vo.VoteID
    LEFT JOIN UserVote uv ON v.VoteID = uv.VoteID
    WHERE v.UserID = p_UserID
      AND v.StartTime IS NULL
      AND v.EndTime IS NULL
    GROUP BY v.VoteID, v.UserID, v.Description, v.StartTime, v.EndTime, u.DisplayName
    ORDER BY v.CreatedAt DESC
    LIMIT p_limit OFFSET p_offset;
END;

-- Get Draft Votes Count
DROP PROCEDURE IF EXISTS sp_count_draft_votes;
CREATE PROCEDURE sp_count_draft_votes(
    IN p_UserID VARCHAR(255)
)
BEGIN
    SELECT COUNT(*) AS total
    FROM Vote v
    WHERE v.UserID = p_UserID
      AND v.StartTime IS NULL
      AND v.EndTime IS NULL;
END;

-- Get Concluded Votes with Pagination
DROP PROCEDURE IF EXISTS sp_get_concluded_votes;
CREATE PROCEDURE sp_get_concluded_votes(
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SELECT 
        v.VoteID,
        v.UserID,
        v.Description,
        v.StartTime,
        v.EndTime,
        u.DisplayName,
        COUNT(DISTINCT vo.OptionID) AS total_options,
        COUNT(uv.UserID) AS total_votes
    FROM Vote v
    INNER JOIN User u ON v.UserID = u.UserID
    LEFT JOIN VoteOption vo ON v.VoteID = vo.VoteID
    LEFT JOIN UserVote uv ON v.VoteID = uv.VoteID
    WHERE v.StartTime IS NOT NULL 
      AND v.EndTime IS NOT NULL
      AND v.EndTime < CURRENT_TIMESTAMP
    GROUP BY v.VoteID, v.UserID, v.Description, v.StartTime, v.EndTime, u.DisplayName
    ORDER BY v.EndTime DESC
    LIMIT p_limit OFFSET p_offset;
END;

-- Get Count of Concluded Votes
DROP PROCEDURE IF EXISTS sp_count_concluded_votes;
CREATE PROCEDURE sp_count_concluded_votes()
BEGIN
    SELECT COUNT(*) AS total
    FROM Vote v
    WHERE v.StartTime IS NOT NULL 
      AND v.EndTime IS NOT NULL
      AND v.EndTime < CURRENT_TIMESTAMP;
END;

/* GET Vote */
DROP PROCEDURE IF EXISTS sp_get_vote;
CREATE PROCEDURE sp_get_vote(
    IN p_VoteID VARCHAR(255)
)
BEGIN
    SELECT  v.VoteID,
            v.UserID,
            v.Description,
            StartTime,
            EndTime,
            u.DisplayName,
            COUNT(DISTINCT vo.VoteID) AS 'total_options',
            COUNT(uv.UserID) AS 'total_votes'
    FROM Vote v
    INNER JOIN User AS u ON v.UserID = u.UserID
    LEFT JOIN VoteOption vo ON v.VoteID = vo.VoteID
    LEFT JOIN UserVote uv ON uv.UserID = v.UserID
    WHERE v.VoteID = p_VoteID
    ;
END;

/*-----------------------------------VOTEOPTION------------------------------------*/

/* INSERT VoteOption */
DROP PROCEDURE IF EXISTS sp_insert_voteoption;
CREATE PROCEDURE sp_insert_voteoption(
    IN p_VoteID VARCHAR(255),
    IN p_Title VARCHAR(255),
    IN p_Description TEXT,
    IN p_Image LONGBLOB
)
BEGIN
    INSERT INTO VoteOption
        (VoteID, Title, Description, Image)
    VALUES
        (p_VoteID, p_Title, p_Description, p_Image)
    ;
END;

/* UPDATE VoteOption */
DROP PROCEDURE IF EXISTS sp_update_voteoption;
CREATE PROCEDURE sp_update_voteoption(
    IN p_OptionID INT,
    IN p_Title VARCHAR(255),
    IN p_Description TEXT,
    IN p_ImageID
)
BEGIN
    UPDATE VoteOption
    SET Title = p_Title,
        Description = p_Description,
        ImageID = p_ImageID
    WHERE OptionID = p_OptionID
    ;
END;

/* DELETE VoteOption */
DROP PROCEDURE IF EXISTS sp_delete_voteoption;
CREATE PROCEDURE sp_delete_voteoption(
    IN p_OptionID INT
)
BEGIN
    DELETE FROM VoteOption
    WHERE OptionID = p_OptionID
    ;
END;

/* GET VoteOptions */
DROP PROCEDURE IF EXISTS sp_get_voteoptions;
CREATE PROCEDURE sp_get_voteoptions(
    IN p_VoteID VARCHAR(255)
)
BEGIN
    SELECT vo.OptionID, vo.VoteID, Title, Description, vo.ImageID, COUNT(uv.UserID) AS 'total_votes'
    FROM VoteOption vo
    LEFT JOIN UserVote uv ON vo.OptionID = uv.OptionID
    WHERE vo.VoteID = p_VoteID
    GROUP BY vo.OptionID, Title, Description, vo.ImageID
    ;
END;

/* GET VoteOption */
DROP PROCEDURE IF EXISTS sp_get_voteoption;
CREATE PROCEDURE sp_get_voteoption(
    IN p_OptionID INT
)
BEGIN
    SELECT OptionID, VoteID, Title, Description, ImageID
    FROM VoteOption
    WHERE OptionID = p_OptionID
    ;
END;

/*-----------------------------------USERVOTE------------------------------------*/

/* INSERT UserVote */
DROP PROCEDURE IF EXISTS sp_insert_uservote;
CREATE PROCEDURE sp_insert_uservote(
    IN p_UserID VARCHAR(255),
    IN p_VoteID VARCHAR(255),
    IN p_OptionID INT,
    IN p_VoteTime DATETIME
)
BEGIN
    INSERT INTO UserVote
        (UserID, VoteID, OptionID, VoteTime)
    VALUES
        (p_UserID, p_VoteID, p_OptionID, p_VoteTime)
    ;
END;

/* UPDATE VoteOption */
DROP PROCEDURE IF EXISTS sp_update_voteoption;
CREATE PROCEDURE sp_update_voteoption(
    IN p_OptionID INT,
    IN p_Title VARCHAR(255),
    IN p_Description TEXT,
    IN p_Image LONGBLOB
)
BEGIN
    UPDATE VoteOption
    SET Title = p_Title,
        Description = p_Description,
        Image = p_Image
    WHERE OptionID = p_OptionID
    ;
END;
/* DELETE VoteOption */
DROP PROCEDURE IF EXISTS sp_delete_voteoption;
CREATE PROCEDURE sp_delete_voteoption(
    IN p_OptionID INT
)
BEGIN
    DELETE FROM VoteOption
    WHERE OptionID = p_OptionID
    ;
END;
/* GET UserVotes */
DROP PROCEDURE IF EXISTS sp_get_uservotes;
CREATE PROCEDURE sp_get_uservotes(
    IN p_VoteID VARCHAR(255)
)
BEGIN
    SELECT UserID, VoteID, OptionID, VoteTime
    FROM UserVote
    WHERE VoteID = p_VoteID
    ;
END;
/* GET VoteOption */
DROP PROCEDURE IF EXISTS sp_get_voteoption;
CREATE PROCEDURE sp_get_voteoption(
    IN p_OptionID INT
)
BEGIN
    SELECT OptionID, Title, Description, Image
    FROM VoteOption
    WHERE OptionID = p_OptionID
    ;
END;

/*****************************************************************************
					            TEST RECORDS
*****************************************************************************/

INSERT INTO Role (
    RoleID,
    # Builds
    CanAddBuilds,
    CanEditAllBuilds,
    CanDeleteAllBuilds,
    # BuildTypes
    CanViewBuildTypes,
    CanAddBuildTypes,
    CanEditBuildTypes,
    CanDeleteBuildTypes,
    # Worlds
    CanViewWorlds,
    CanAddWorlds,
    CanEditWorlds,
    CanDeleteWorlds,
    # Votes
    CanViewAllVotes,
    CanAddVotes,
    CanEditAllVotes,
    CanDeleteAllVotes,
    # Roles
    CanViewRoles,
    CanAddRoles,
    CanEditRoles,
    CanDeleteRoles,
    # Users
    CanViewUsers,
    CanAddUsers,
    CanEditUsers,
    CanBanUsers,

    Description
)
VALUES (
    'User',
    1, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 0, 0,
    0, 0, 0, 0,
    'Normal default user privileges'
);

INSERT INTO Role (
    RoleID,
    # Builds
    CanAddBuilds,
    CanEditAllBuilds,
    CanDeleteAllBuilds,
    # BuildTypes
    CanViewBuildTypes,
    CanAddBuildTypes,
    CanEditBuildTypes,
    CanDeleteBuildTypes,
    # Worlds
    CanViewWorlds,
    CanAddWorlds,
    CanEditWorlds,
    CanDeleteWorlds,
    # Votes
    CanViewAllVotes,
    CanAddVotes,
    CanEditAllVotes,
    CanDeleteAllVotes,
    # Roles
    CanViewRoles,
    CanAddRoles,
    CanEditRoles,
    CanDeleteRoles,
    # Users
    CanViewUsers,
    CanAddUsers,
    CanEditUsers,
    CanBanUsers,

    Description
)
VALUES (
    'Admin',
    1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1,
    1, 1, 1, 1,
    'Super user that can do anything'
);

INSERT INTO BuildType (BuildTypeID, Description) VALUES ('Sky Scraper', 'Very tall Build.');
INSERT INTO BuildType (BuildTypeID, Description) VALUES ('Capitol', 'An elegant government Build where congressional hearings are sometimes held.');
INSERT INTO BuildType (BuildTypeID, Description) VALUES ('Cathedral', 'Religious Build of great stature');
INSERT INTO BuildType (BuildTypeID, Description) VALUES ('Mega-build', 'Huge Builds that take forever to build.');
INSERT INTO BuildType (BuildTypeID, Description) VALUES ('Shop', 'Place to buy and/or sell goods.');

INSERT INTO World (WorldID, DateStarted, Description) VALUES ('No Go Outside', '2020-5-11', 'Built in the No Go Outside world');
INSERT INTO World (WorldID, DateStarted, Description) VALUES ('SummerSMP2022', '2022-6-18', 'Built in the SummerSMP2022 world');