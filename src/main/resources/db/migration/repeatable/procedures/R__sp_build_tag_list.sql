DROP PROCEDURE IF EXISTS sp_build_tag_list;
DELIMITER $$
CREATE PROCEDURE sp_build_tag_list (
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
END$$
DELIMITER ;
