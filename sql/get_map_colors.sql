/* us-judicial-geography/sql/get_map_colors.sql
 */

CREATE FUNCTION us_judicial_geography.get_map_colors(
    IN table_name TEXT,
    IN key_column TEXT,
    IN geometry_column TEXT,
    IN schema_name TEXT DEFAULT 'public'
) RETURNS TABLE(key_value TEXT, color_id INTEGER)
    LANGUAGE plpgsql
    VOLATILE
    SECURITY INVOKER
    PARALLEL UNSAFE
    COST 1000
    AS $get_map_colors$
DECLARE
    current_color INTEGER := 1;
    current_count INTEGER;
    item RECORD;
    sentinel INTEGER;
BEGIN
    DROP TABLE IF EXISTS adjacency_list;

    EXECUTE format('CREATE TEMPORARY TABLE adjacency_list AS
SELECT DISTINCT
    a.%I AS key,
    array_agg(b.%I) OVER (PARTITION BY a.%I) AS adjacent,
    0 AS color
FROM
    %I.%I AS a
    CROSS JOIN %I.%I AS b
WHERE
    ST_Intersects(a.%I, b.%I)
    AND a.%I <> b.%I
ORDER BY
    key ASC;', key_column, key_column, key_column, schema_name, table_name, schema_name, table_name, geometry_column, geometry_column, key_column, key_column);

    SELECT ALL
        COUNT(*)
    FROM
        adjacency_list
    WHERE
        color = 0
    INTO sentinel;

    <<sentinel_loop>>
    WHILE sentinel > 0
    LOOP
        UPDATE adjacency_list
        SET
            color = current_color
        WHERE
            key = (
                SELECT ALL
                    key
                FROM
                    adjacency_list
                WHERE
                    color = 0
                ORDER BY
                    key ASC
                LIMIT 1
            );

        <<for_loop>>
        FOR item IN
        SELECT ALL
            *
        FROM
            adjacency_list
        WHERE
            color = 0
        LOOP
            SELECT ALL
                COUNT(*)
            FROM
                adjacency_list
            WHERE
                color = current_color
                AND item.key = ANY(adjacent)
            INTO current_count;

            IF current_count = 0 THEN
                UPDATE adjacency_list
                SET
                    color = current_color
                WHERE
                    key = item.key;
            END IF;
        END LOOP for_loop;

        current_color := current_color + 1;

        SELECT ALL
            COUNT(*)
        FROM
            adjacency_list
        WHERE
            color = 0
        INTO sentinel;
    END LOOP sentinel_loop;

    RETURN QUERY
    SELECT ALL
        key,
        color
    FROM
        adjacency_list;
END;
$get_map_colors$;
