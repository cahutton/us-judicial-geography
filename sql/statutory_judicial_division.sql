/* us-judicial-geography/sql/statutory_judicial_division.sql
 */

START TRANSACTION;

CREATE TABLE us_judicial_geography.statutory_judicial_division (
    boundary geography(MultiPolygon, 96867) NOT NULL,
    judicial_district_id TEXT NOT NULL,
    statutory_judicial_division TEXT NOT NULL,
    color_id SMALLINT NOT NULL,
    CONSTRAINT statutory_judicial_division_pkey
        PRIMARY KEY (judicial_district_id, statutory_judicial_division)
            WITH (fillfactor = '100')
        NOT DEFERRABLE
)
    WITH (fillfactor = '100');

INSERT INTO us_judicial_geography.statutory_judicial_division
SELECT ALL
    ST_Multi(ST_Union(jdc.boundary::geometry(MultiPolygon, 96867))),
    judicial_district_id,
    COALESCE(jdc.statutory_judicial_division, jd.judicial_district_name),
    0
FROM
    us_judicial_geography.judicial_district_county AS jdc
    INNER JOIN us_judicial_geography.judicial_district AS jd
        USING (judicial_district_id)
WHERE
    judicial_district_id IS NOT NULL
GROUP BY
    jdc.statutory_judicial_division,
    judicial_district_id,
    jd.judicial_district_name;

UPDATE us_judicial_geography.statutory_judicial_division AS d
SET
    color_id = c.color_id
FROM
    us_judicial_geography.get_map_colors('statutory_judicial_division', 'statutory_judicial_division', 'boundary', 'us_judicial_geography') AS c
WHERE
    d.statutory_judicial_division = c.key_value;

CLUSTER us_judicial_geography.statutory_judicial_division
    USING statutory_judicial_division_pkey;

COMMIT WORK;

VACUUM us_judicial_geography.statutory_judicial_division;

CREATE INDEX statutory_judicial_division_boundary_idx
    ON us_judicial_geography.statutory_judicial_division USING gist (boundary)
    WITH (fillfactor = '100');
CREATE INDEX statutory_judicial_division_judicial_district_id_idx
    ON us_judicial_geography.statutory_judicial_division USING btree (judicial_district_id)
    WITH (fillfactor = '100');

ANALYZE us_judicial_geography.statutory_judicial_division;
