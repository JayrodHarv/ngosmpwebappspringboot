DROP PROCEDURE IF EXISTS sp_file_create;
DELIMITER $$
CREATE PROCEDURE sp_file_create (
    IN p_file_name  VARCHAR(255),
    IN p_hash       CHAR(64),
    IN p_mime_type  VARCHAR(100),
    IN p_size       BIGINT,

)
