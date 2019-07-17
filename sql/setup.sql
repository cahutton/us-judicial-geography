/* us-judicial-geography/sql/setup.sql
 */

\set DATA_PATH :BASE_PATH /data
\set DOWNLOAD_PATH :BASE_PATH /download

\set JUDICIAL_CIRCUIT_DATA :DATA_PATH /judicial_circuit.csv
\set JUDICIAL_DISTRICT_DATA :DATA_PATH /judicial_district.csv
\set JUDICIAL_DISTRICT_COUNTY_DATA :DATA_PATH /judicial_district_county.csv

\set AREA_LANDMARK_IDAHO :DOWNLOAD_PATH /tl_2018_16_arealm.shp
\set AREA_LANDMARK_MONTANA :DOWNLOAD_PATH /tl_2018_30_arealm.shp
\set AREA_LANDMARK_NORTH_CAROLINA :DOWNLOAD_PATH /tl_2018_37_arealm.shp
\set COUNTY :DOWNLOAD_PATH /tl_2018_us_county.shp

\set GET_MAP_COLORS :SQL_PATH /get_map_colors.sql

CREATE DATABASE us_judicial_geography
    WITH
        ENCODING 'UTF-8'
        ALLOW_CONNECTIONS TRUE
        CONNECTION_LIMIT -1
        IS_TEMPLATE FALSE;
COMMENT ON DATABASE us_judicial_geography
    IS 'Database for U.S. judicial geography';

\connect us_judicial_geography

START TRANSACTION;

CREATE EXTENSION file_fdw;
CREATE EXTENSION ogr_fdw;
CREATE EXTENSION postgis;

-- Based on https://spatialreference.org/ref/sr-org/6867/postgis/
-- This WKT is the same as from the TIGER shapefile .prj files
INSERT INTO spatial_ref_sys (
    srid,
    auth_name,
    auth_srid,
    proj4text,
    srtext
)
VALUES
    (96867, 'sr-org', 6867, '+proj=longlat +ellps=GRS80 +no_defs ', 'GEOGCS["GCS_North_American_1983",DATUM["D_North_American_1983",SPHEROID["GRS_1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]]')
ON CONFLICT DO NOTHING;

CREATE SERVER area_landmark_idaho_shapefile
    FOREIGN DATA WRAPPER ogr_fdw
    OPTIONS (datasource :'AREA_LANDMARK_IDAHO', format 'ESRI Shapefile');
CREATE SERVER area_landmark_montana_shapefile
    FOREIGN DATA WRAPPER ogr_fdw
    OPTIONS (datasource :'AREA_LANDMARK_MONTANA', format 'ESRI Shapefile');
CREATE SERVER area_landmark_north_carolina_shapefile
    FOREIGN DATA WRAPPER ogr_fdw
    OPTIONS (datasource :'AREA_LANDMARK_NORTH_CAROLINA', format 'ESRI Shapefile');
CREATE SERVER county_shapefile
    FOREIGN DATA WRAPPER ogr_fdw
    OPTIONS (datasource :'COUNTY', format 'ESRI Shapefile');
CREATE SERVER us_judicial_geography_file_fdw
    FOREIGN DATA WRAPPER file_fdw;

CREATE SCHEMA us_judicial_geography
    AUTHORIZATION :USER;

\include :GET_MAP_COLORS

CREATE FOREIGN TABLE us_judicial_geography.area_landmark_idaho (
    fid INTEGER
        OPTIONS (column_name 'fid'),
    geom geometry(MultiPolygon, 96867)
        OPTIONS (column_name 'geom'),
    statefp TEXT
        OPTIONS (column_name 'statefp'),
    ansicode TEXT
        OPTIONS (column_name 'ansicode'),
    areaid TEXT
        OPTIONS (column_name 'areaid'),
    fullname TEXT
        OPTIONS (column_name 'fullname'),
    mtfcc TEXT
        OPTIONS (column_name 'mtfcc'),
    aland NUMERIC
        OPTIONS (column_name 'aland'),
    awater NUMERIC
        OPTIONS (column_name 'awater'),
    intptlat TEXT
        OPTIONS (column_name 'intptlat'),
    intptlon TEXT
        OPTIONS (column_name 'intptlon'),
    partflg TEXT
        OPTIONS (column_name 'partflg')
)
    SERVER area_landmark_idaho_shapefile
    OPTIONS (layer 'tl_2018_16_arealm');
CREATE FOREIGN TABLE us_judicial_geography.area_landmark_montana (
    fid INTEGER
        OPTIONS (column_name 'fid'),
    geom geometry(MultiPolygon, 96867)
        OPTIONS (column_name 'geom'),
    statefp TEXT
        OPTIONS (column_name 'statefp'),
    ansicode TEXT
        OPTIONS (column_name 'ansicode'),
    areaid TEXT
        OPTIONS (column_name 'areaid'),
    fullname TEXT
        OPTIONS (column_name 'fullname'),
    mtfcc TEXT
        OPTIONS (column_name 'mtfcc'),
    aland NUMERIC
        OPTIONS (column_name 'aland'),
    awater NUMERIC
        OPTIONS (column_name 'awater'),
    intptlat TEXT
        OPTIONS (column_name 'intptlat'),
    intptlon TEXT
        OPTIONS (column_name 'intptlon'),
    partflg TEXT
        OPTIONS (column_name 'partflg')
)
    SERVER area_landmark_montana_shapefile
    OPTIONS (layer 'tl_2018_30_arealm');
CREATE FOREIGN TABLE us_judicial_geography.area_landmark_north_carolina (
    fid INTEGER
        OPTIONS (column_name 'fid'),
    geom geometry(MultiPolygon, 96867)
        OPTIONS (column_name 'geom'),
    statefp TEXT
        OPTIONS (column_name 'statefp'),
    ansicode TEXT
        OPTIONS (column_name 'ansicode'),
    areaid TEXT
        OPTIONS (column_name 'areaid'),
    fullname TEXT
        OPTIONS (column_name 'fullname'),
    mtfcc TEXT
        OPTIONS (column_name 'mtfcc'),
    aland NUMERIC
        OPTIONS (column_name 'aland'),
    awater NUMERIC
        OPTIONS (column_name 'awater'),
    intptlat TEXT
        OPTIONS (column_name 'intptlat'),
    intptlon TEXT
        OPTIONS (column_name 'intptlon'),
    partflg TEXT
        OPTIONS (column_name 'partflg')
)
    SERVER area_landmark_north_carolina_shapefile
    OPTIONS (layer 'tl_2018_37_arealm');

CREATE FOREIGN TABLE us_judicial_geography.county (
    fid INTEGER
        OPTIONS (column_name 'fid'),
    geom geometry(MultiPolygon, 96867)
        OPTIONS (column_name 'geom'),
    statefp TEXT
        OPTIONS (column_name 'statefp'),
    countyfp TEXT
        OPTIONS (column_name 'countyfp'),
    countyns TEXT
        OPTIONS (column_name 'countyns'),
    geoid TEXT
        OPTIONS (column_name 'geoid'),
    name TEXT
        OPTIONS (column_name 'name'),
    namelsad TEXT
        OPTIONS (column_name 'namelsad'),
    lsad TEXT
        OPTIONS (column_name 'lsad'),
    classfp TEXT
        OPTIONS (column_name 'classfp'),
    mtfcc TEXT
        OPTIONS (column_name 'mtfcc'),
    csafp TEXT
        OPTIONS (column_name 'csafp'),
    cbsafp TEXT
        OPTIONS (column_name 'cbsafp'),
    metdivfp TEXT
        OPTIONS (column_name 'metdivfp'),
    funcstat TEXT
        OPTIONS (column_name 'funcstat'),
    aland NUMERIC
        OPTIONS (column_name 'aland'),
    awater NUMERIC
        OPTIONS (column_name 'awater'),
    intptlat TEXT
        OPTIONS (column_name 'intptlat'),
    intptlon TEXT
        OPTIONS (column_name 'intptlon')
)
    SERVER county_shapefile
    OPTIONS (layer 'tl_2018_us_county');

CREATE FOREIGN TABLE us_judicial_geography.judicial_circuit_data (
    judicial_circuit_id TEXT,
    judicial_circuit_name TEXT,
    judicial_circuit_abbreviation TEXT,
    color_id SMALLINT
)
    SERVER us_judicial_geography_file_fdw
    OPTIONS (filename :'JUDICIAL_CIRCUIT_DATA', format 'csv', header 'TRUE', delimiter ',', quote '"', escape '"', null '', encoding 'UTF-8');

CREATE FOREIGN TABLE us_judicial_geography.judicial_district_data (
    judicial_district_id TEXT,
    judicial_district_name TEXT,
    judicial_district_abbreviation TEXT,
    judicial_circuit_id TEXT,
    state_alpha_code TEXT
)
    SERVER us_judicial_geography_file_fdw
    OPTIONS (filename :'JUDICIAL_DISTRICT_DATA', format 'csv', header 'TRUE', delimiter ',', quote '"', escape '"', null '', encoding 'UTF-8');

CREATE FOREIGN TABLE us_judicial_geography.judicial_district_county_data (
    judicial_district_county_id TEXT,
    county_ansi_code TEXT,
    is_entire_county BOOLEAN,
    judicial_district_county_name TEXT,
    judicial_district_id TEXT,
    statutory_judicial_division TEXT
)
    SERVER us_judicial_geography_file_fdw
    OPTIONS (filename :'JUDICIAL_DISTRICT_COUNTY_DATA', format 'csv', header 'TRUE', delimiter ',', quote '"', escape '"', null '', encoding 'UTF-8');

COMMIT WORK;
