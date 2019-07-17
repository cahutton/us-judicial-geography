/* us-judicial-geography/sql/run.sql
 */

\set ON_ERROR_STOP on

\set SQL_PATH :BASE_PATH /sql

\set FOREIGN_KEYS :SQL_PATH /foreign_keys.sql
\set JUDICIAL_CIRCUIT :SQL_PATH /judicial_circuit.sql
\set JUDICIAL_DISTRICT :SQL_PATH /judicial_district.sql
\set JUDICIAL_DISTRICT_COUNTY :SQL_PATH /judicial_district_county.sql
\set PROJECTION_VIEWS :SQL_PATH /projection_views.sql
\set SETUP :SQL_PATH /setup.sql
\set SHAPEFILE_VIEWS :SQL_PATH /shapefile_views.sql
\set STATUTORY_JUDICIAL_DIVISION :SQL_PATH /statutory_judicial_division.sql
\set TEARDOWN :SQL_PATH /teardown.sql

SET SESSION maintenance_work_mem TO '1960MB';

\include :TEARDOWN
\include :SETUP

\include :JUDICIAL_DISTRICT_COUNTY
\include :JUDICIAL_DISTRICT
\include :JUDICIAL_CIRCUIT
\include :STATUTORY_JUDICIAL_DIVISION

\include :FOREIGN_KEYS

\include :PROJECTION_VIEWS
\include :SHAPEFILE_VIEWS
