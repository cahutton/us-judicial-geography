/* us-judicial-geography/sql/judicial_circuit.sql
 */

START TRANSACTION;

CREATE TABLE us_judicial_geography.judicial_circuit (
    boundary geography(MultiPolygon, 96867) NOT NULL,
    judicial_circuit_id TEXT NOT NULL
        CONSTRAINT judicial_circuit_pkey
            PRIMARY KEY
                WITH (fillfactor = '100')
            NOT DEFERRABLE,
    judicial_circuit_name TEXT,
    judicial_circuit_abbreviation TEXT,
    color_id SMALLINT NOT NULL
)
    WITH (fillfactor = '100');

INSERT INTO us_judicial_geography.judicial_circuit
SELECT ALL
    j.boundary,
    judicial_circuit_id,
    d.judicial_circuit_name,
    d.judicial_circuit_abbreviation,
    d.color_id
FROM
    us_judicial_geography.judicial_circuit_data AS d
    INNER JOIN (
        SELECT ALL
            ST_Multi(ST_Union(boundary::geometry(MultiPolygon, 96867))) AS boundary,
            judicial_circuit_id
        FROM
            us_judicial_geography.judicial_district
        GROUP BY
            judicial_circuit_id
    ) AS j
        USING (judicial_circuit_id);

CLUSTER us_judicial_geography.judicial_circuit
    USING judicial_circuit_pkey;

COMMIT WORK;

VACUUM us_judicial_geography.judicial_circuit;

CREATE INDEX judicial_circuit_boundary_idx
    ON us_judicial_geography.judicial_circuit USING gist (boundary)
    WITH (fillfactor = '100');

ANALYZE us_judicial_geography.judicial_circuit;
