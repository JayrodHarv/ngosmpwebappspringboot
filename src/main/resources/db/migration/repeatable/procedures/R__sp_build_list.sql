DROP PROCEDURE IF EXISTS sp_build_list;
DELIMITER $$
CREATE PROCEDURE sp_build_list (
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
            i.image_id,
            i.file_path AS primary_image_path,

            b.created_by,
            u.display_name AS creator_display_name,

            COUNT(*) OVER() AS total_count

    FROM build b
    JOIN user u
        ON u.user_id = b.created_by
    LEFT JOIN build_image bi
        ON bi.build_id = b.build_id
        AND bi.sort_order = 0
    LEFT JOIN image i
        ON i.image_id = bi.image_id
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
END$$
DELIMITER ;
