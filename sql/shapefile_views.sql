/* us-judicial-geography/sql/shapefile_views.sql
 */

CREATE VIEW us_judicial_geography.judicial_circuit_shapefile_view AS
SELECT ALL
    boundary AS geom,
    judicial_circuit_id AS jcircid,
    judicial_circuit_name AS jcircname,
    judicial_circuit_abbreviation AS jcircabbr,
    color_id AS color
FROM
    us_judicial_geography.judicial_circuit;

CREATE VIEW us_judicial_geography.judicial_district_shapefile_view AS
SELECT ALL
    boundary AS geom,
    judicial_district_id AS jdistid,
    judicial_district_name AS jdistname,
    judicial_district_abbreviation AS jdistabbr,
    judicial_circuit_id AS jcircid,
    state_alpha_code AS stusps,
    color_id AS color
FROM
    us_judicial_geography.judicial_district;

CREATE VIEW us_judicial_geography.statutory_judicial_division_shapefile_view AS
SELECT ALL
    boundary AS geom,
    statutory_judicial_division AS jdivname,
    judicial_district_id AS jdistid,
    color_id AS color
FROM
    us_judicial_geography.statutory_judicial_division;

CREATE VIEW us_judicial_geography.judicial_district_county_shapefile_view AS
SELECT ALL
    boundary AS geom,
    judicial_district_county_id AS jdcntyid,
    county_ansi_code AS countyfp,
    is_entire_county AS entirecnty,
    judicial_district_county_name AS jdcntyname,
    judicial_district_id AS jdistid,
    statutory_judicial_division AS jdivname
FROM
    us_judicial_geography.judicial_district_county;
