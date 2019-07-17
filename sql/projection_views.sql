/* us-judicial-geography/sql/projection_views.sql
 */

\set PROJECTION '+proj=laea +lat_0=27 +lon_0=-145'

CREATE VIEW us_judicial_geography.judicial_circuit_projected_view AS
SELECT ALL
    ST_Transform(boundary::geometry(MultiPolygon, 96867), :'PROJECTION') AS boundary,
    judicial_circuit_id,
    judicial_circuit_name,
    judicial_circuit_abbreviation,
    color_id
FROM
    us_judicial_geography.judicial_circuit;

CREATE VIEW us_judicial_geography.judicial_district_projected_view AS
SELECT ALL
    ST_Transform(boundary::geometry(MultiPolygon, 96867), :'PROJECTION') AS boundary,
    judicial_district_id,
    judicial_district_name,
    judicial_district_abbreviation,
    judicial_circuit_id,
    state_alpha_code,
    color_id
FROM
    us_judicial_geography.judicial_district;

CREATE VIEW us_judicial_geography.statutory_judicial_division_projected_view AS
SELECT ALL
    ST_Transform(boundary::geometry(MultiPolygon, 96867), :'PROJECTION') AS boundary,
    statutory_judicial_division,
    judicial_district_id,
    color_id
FROM
    us_judicial_geography.statutory_judicial_division;

CREATE VIEW us_judicial_geography.judicial_district_county_projected_view AS
SELECT ALL
    ST_Transform(boundary::geometry(MultiPolygon, 96867), :'PROJECTION') AS boundary,
    judicial_district_county_id,
    county_ansi_code,
    is_entire_county,
    judicial_district_county_name,
    judicial_district_id,
    statutory_judicial_division
FROM
    us_judicial_geography.judicial_district_county;
