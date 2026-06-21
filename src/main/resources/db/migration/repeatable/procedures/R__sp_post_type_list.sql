DROP PROCEDURE IF EXISTS sp_post_type_list;
DELIMITER $$
CREATE PROCEDURE sp_post_type_list ()
BEGIN
    SELECT  post_type_id,
            name,
            description
    FROM post_type
    ORDER BY name;
END$$
DELIMITER ;
