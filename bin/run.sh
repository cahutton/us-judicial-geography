#!/usr/bin/env bash

set -ETbeu -o pipefail

DBNAME="us_judicial_geography"

# Download Census Bureau shapefiles
curl -L --compressed --stderr - --styled-output \
    -o download/tl_2018_16_arealm.zip --url https://www2.census.gov/geo/tiger/TIGER2018/AREALM/tl_2018_16_arealm.zip \
    -o download/tl_2018_30_arealm.zip --url https://www2.census.gov/geo/tiger/TIGER2018/AREALM/tl_2018_30_arealm.zip \
    -o download/tl_2018_37_arealm.zip --url https://www2.census.gov/geo/tiger/TIGER2018/AREALM/tl_2018_37_arealm.zip \
    -o download/tl_2018_us_county.zip --url https://www2.census.gov/geo/tiger/TIGER2018/COUNTY/tl_2018_us_county.zip

# Extract shapefile files
for archive in download/*.zip; do
    unzip -o -u "$archive" -d download
done

# Run PostgreSQL script
psql -f sql/run.sql --set BASE_PATH=`pwd` --set DATABASE_NAME="$DBNAME" -d postgres

# Generate and zip shapefiles
ogr2ogr -f 'ESRI Shapefile' -lco ENCODING='UTF-8' shp/judicial_circuit/judicial_circuit.shp \
    "PG:dbname=$DBNAME tables=us_judicial_geography.judicial_circuit_shapefile_view"
cp -f download/tl_2018_us_county.prj shp/judicial_circuit/judicial_circuit.prj
zip -9 shp/judicial_circuit/judicial_circuit.zip shp/judicial_circuit/judicial_circuit.*

ogr2ogr -f 'ESRI Shapefile' -lco ENCODING='UTF-8' shp/judicial_district/judicial_district.shp \
    "PG:dbname=$DBNAME tables=us_judicial_geography.judicial_district_shapefile_view"
cp -f download/tl_2018_us_county.prj shp/judicial_district/judicial_district.prj
zip -9 shp/judicial_district/judicial_district.zip shp/judicial_district/judicial_district.*

ogr2ogr -f 'ESRI Shapefile' -lco ENCODING='UTF-8' shp/statutory_judicial_division/statutory_judicial_division.shp \
    "PG:dbname=$DBNAME tables=us_judicial_geography.statutory_judicial_division_shapefile_view"
cp -f download/tl_2018_us_county.prj shp/statutory_judicial_division/statutory_judicial_division.prj
zip -9 shp/statutory_judicial_division/statutory_judicial_division.zip shp/statutory_judicial_division/statutory_judicial_division.*

ogr2ogr -f 'ESRI Shapefile' -lco ENCODING='UTF-8' shp/judicial_district_county/judicial_district_county.shp \
    "PG:dbname=$DBNAME tables=us_judicial_geography.judicial_district_county_shapefile_view"
cp -f download/tl_2018_us_county.prj shp/judicial_district_county/judicial_district_county.prj
zip -9 shp/judicial_district_county/judicial_district_county.zip shp/judicial_district_county/judicial_district_county.*

# Generate GeoJSON files, using the projected view
ogr2ogr -f GeoJSON json/judicial-circuit.geojson \
    "PG:dbname=$DBNAME tables=us_judicial_geography.judicial_circuit_projected_view"
ogr2ogr -f GeoJSON json/judicial-district.geojson \
    "PG:dbname=$DBNAME tables=us_judicial_geography.judicial_district_projected_view"
ogr2ogr -f GeoJSON json/statutory-judicial-division.geojson \
    "PG:dbname=$DBNAME tables=us_judicial_geography.statutory_judicial_division_projected_view"
ogr2ogr -f GeoJSON json/judicial-district-county.geojson \
    "PG:dbname=$DBNAME tables=us_judicial_geography.judicial_district_county_projected_view"

# Generate TopoJSON files (via GeoJSON files)
node --max-old-space-size=4096 `which geo2topo` -o - -q 1e5 \
    judicial_circuit=json/judicial-circuit.geojson \
    | toposimplify -f -p 1e-7 \
    > json/judicial-circuit.topojson
node --max-old-space-size=4096 `which geo2topo` -o - -q 1e5 \
    judicial_district=json/judicial-district.geojson \
    | toposimplify -f -p 1e-7 \
    > json/judicial-district.topojson
node --max-old-space-size=4096 `which geo2topo` -o - -q 1e5 \
    statutory_judicial_division=json/statutory-judicial-division.geojson \
    | toposimplify -f -p 1e-7 \
    > json/statutory-judicial-division.topojson
node --max-old-space-size=4096 `which geo2topo` -o - -q 1e5 \
    judicial_district_county=json/judicial-district-county.geojson \
    | toposimplify -f -p 1e-7 \
    > json/judicial-district-county.topojson
