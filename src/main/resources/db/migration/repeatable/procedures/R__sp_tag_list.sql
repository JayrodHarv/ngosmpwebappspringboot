DROP PROCEDURE IF EXISTS sp_tag_list;
DELIMITER $$
CREATE PROCEDURE sp_tag_list (
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
END$$
DELIMITER ;
