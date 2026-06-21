DROP PROCEDURE IF EXISTS sp_tag_get;
DELIMITER $$
CREATE PROCEDURE sp_tag_get (
    IN p_tag_id INT
)
BEGIN
    SELECT  t.tag_id, t.name, t.description,
            tt.tag_type_id, tt.name AS type_name, tt.color_hex
    FROM    tag t
    JOIN    tag_type tt ON tt.tag_type_id = t.tag_type_id
    WHERE   t.tag_id = p_tag_id;
END$$
DELIMITER ;
