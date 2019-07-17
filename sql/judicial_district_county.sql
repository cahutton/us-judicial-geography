/* us-judicial-geography/sql/judicial_district_county.sql
 */

START TRANSACTION;

CREATE TABLE us_judicial_geography.judicial_district_county (
    boundary geography(MultiPolygon, 96867) NOT NULL,
    judicial_district_county_id TEXT NOT NULL
        CONSTRAINT judicial_district_county_pkey
            PRIMARY KEY
                WITH (fillfactor = '100')
            NOT DEFERRABLE,
    county_ansi_code TEXT NOT NULL,
    is_entire_county BOOLEAN NOT NULL,
    judicial_district_county_name TEXT NOT NULL,
    judicial_district_id TEXT,
    statutory_judicial_division TEXT,
    CONSTRAINT judicial_district_county_id_check
        CHECK (judicial_district_county_id LIKE county_ansi_code || '-_')
)
    WITH (fillfactor = '100');

INSERT INTO us_judicial_geography.judicial_district_county
SELECT ALL
    CASE SUBSTRING(d.judicial_district_county_id FROM CHAR_LENGTH(d.judicial_district_county_id) FOR 1)
        WHEN '0' THEN ST_Multi(c.geom)
        WHEN '1' THEN ST_Multi(ST_Difference(c.geom, COALESCE(yi.geom, ym.geom, b.geom)))
        WHEN '2' THEN ST_Multi(ST_Intersection(c.geom, COALESCE(yi.geom, ym.geom, b.geom)))
    END,
    d.judicial_district_county_id,
    d.county_ansi_code,
    d.is_entire_county,
    d.judicial_district_county_name,
    d.judicial_district_id,
    d.statutory_judicial_division
FROM
    us_judicial_geography.judicial_district_county_data AS d
    INNER JOIN us_judicial_geography.county AS c
        ON d.county_ansi_code = c.geoid
    LEFT OUTER JOIN (
        SELECT ALL
            geom
        FROM
            us_judicial_geography.area_landmark_idaho
        WHERE
            areaid = '1102215199136'  -- Yellowstone National Park
    ) AS yi
        ON d.county_ansi_code = '16043'  -- Fremont County, Idaho
    LEFT OUTER JOIN (
        SELECT ALL
            geom
        FROM
            us_judicial_geography.area_landmark_montana
        WHERE
            areaid = '1102215199136'  -- Yellowstone National Park
    ) AS ym
        ON d.county_ansi_code IN ('30031',  -- Gallatin County, Montana
                                  '30067')  -- Park County, Montana
    LEFT OUTER JOIN (
        SELECT ALL
            geom
        FROM
            us_judicial_geography.area_landmark_north_carolina
        WHERE
            areaid = '1104691778386'  -- Federal Correctional Institution, Butner
    ) AS b
        ON d.county_ansi_code = '37063';  -- Durham County, North Carolina

CREATE INDEX judicial_district_county_statutory_judicial_division_idx
    ON us_judicial_geography.judicial_district_county USING btree (judicial_district_id, statutory_judicial_division)
    WITH (fillfactor = '100');
CLUSTER us_judicial_geography.judicial_district_county
    USING judicial_district_county_statutory_judicial_division_idx;

COMMIT WORK;

VACUUM us_judicial_geography.judicial_district_county;

CREATE INDEX judicial_district_county_boundary_idx
    ON us_judicial_geography.judicial_district_county USING gist (boundary)
    WITH (fillfactor = '100');

ANALYZE us_judicial_geography.judicial_district_county;
