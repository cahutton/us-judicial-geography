/* us-judicial-geography/sql/foreign_keys.sql
 */

ALTER TABLE us_judicial_geography.judicial_district
    ADD CONSTRAINT judicial_district_judicial_circuit_id_fkey
        FOREIGN KEY (judicial_circuit_id)
            REFERENCES us_judicial_geography.judicial_circuit (judicial_circuit_id)
            MATCH SIMPLE
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
        DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE us_judicial_geography.statutory_judicial_division
    ADD CONSTRAINT statutory_judicial_division_judicial_district_id_fkey
        FOREIGN KEY (judicial_district_id)
            REFERENCES us_judicial_geography.judicial_district (judicial_district_id)
            MATCH SIMPLE
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
        DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE us_judicial_geography.judicial_district_county
    ADD CONSTRAINT judicial_district_county_judicial_district_id_fkey
        FOREIGN KEY (judicial_district_id)
            REFERENCES us_judicial_geography.judicial_district (judicial_district_id)
            MATCH SIMPLE
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
        DEFERRABLE INITIALLY IMMEDIATE,
    ADD CONSTRAINT judicial_district_county_statutory_judicial_division_fkey
        FOREIGN KEY (judicial_district_id, statutory_judicial_division)
            REFERENCES us_judicial_geography.statutory_judicial_division (judicial_district_id, statutory_judicial_division)
            MATCH SIMPLE
            ON UPDATE RESTRICT
            ON DELETE RESTRICT
        DEFERRABLE INITIALLY IMMEDIATE;
