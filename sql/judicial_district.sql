/* us-judicial-geography/sql/judicial_district.sql
 */

START TRANSACTION;

CREATE TABLE us_judicial_geography.judicial_district (
    boundary geography(MultiPolygon, 96867) NOT NULL,
    judicial_district_id TEXT NOT NULL
        CONSTRAINT judicial_district_pkey
            PRIMARY KEY
                WITH (fillfactor = '100')
            NOT DEFERRABLE,
    judicial_district_name TEXT,
    judicial_district_abbreviation TEXT,
    judicial_circuit_id TEXT,
    state_alpha_code TEXT,
    color_id SMALLINT NOT NULL
)
    WITH (fillfactor = '100');

INSERT INTO us_judicial_geography.judicial_district
SELECT ALL
    j.boundary,
    judicial_district_id,
    d.judicial_district_name,
    d.judicial_district_abbreviation,
    d.judicial_circuit_id,
    d.state_alpha_code,
    0
FROM
    us_judicial_geography.judicial_district_data AS d
    INNER JOIN (
        SELECT ALL
            ST_Multi(ST_Union(boundary::geometry(MultiPolygon, 96867))) AS boundary,
            judicial_district_id
        FROM
            us_judicial_geography.judicial_district_county
        GROUP BY
            judicial_district_id
    ) AS j
        USING (judicial_district_id);

UPDATE us_judicial_geography.judicial_district AS j
SET
    color_id = c.color_id
FROM
    us_judicial_geography.get_map_colors('judicial_district', 'judicial_district_id', 'boundary', 'us_judicial_geography') AS c
WHERE
    j.judicial_district_id = c.key_value;

CREATE INDEX judicial_district_judicial_circuit_id_idx
    ON us_judicial_geography.judicial_district USING btree (judicial_circuit_id)
    WITH (fillfactor = '100');
CLUSTER us_judicial_geography.judicial_district
    USING judicial_district_judicial_circuit_id_idx;

COMMIT WORK;

VACUUM us_judicial_geography.judicial_district;

CREATE INDEX judicial_district_boundary_idx
    ON us_judicial_geography.judicial_district USING gist (boundary)
    WITH (fillfactor = '100');

ANALYZE us_judicial_geography.judicial_district;
