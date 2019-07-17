# us-judicial-geography

Code for generating geospatial data for [the United States federal judiciary](https://www.uscourts.gov/about-federal-courts/court-role-and-structure) from [the U.S. Census Bureau’s TIGER/Line shapefiles](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html)

## Dependencies

The SQL scripts were developed using [PostgreSQL](https://www.postgresql.org/) 11 and [PostGIS](http://postgis.net/) 2.5, but should work for all recent versions.

You must have superuser privileges to create the necessary extensions and foreign data objects.

[GDAL](https://gdal.org/index.html), [pgsql-ogr-fdw](https://github.com/pramsey/pgsql-ogr-fdw), [Node.js](https://nodejs.org), and the Node packages [topojson-server](https://github.com/topojson/topojson-server) and [topojson-simplify](https://github.com/topojson/topojson-simplify) are all required in order to run everything as-is.

## Usage

To use, execute the shell script `bin/run.sh`:

    $ ./bin/run.sh

This will download the necessary TIGER/Line shapefiles and decompress them; create (or recreate) a database; import and calculate the shapefile data; and output the shapefile, GeoJSON, and TopoJSON files.

### Output Files

#### json/\*

Two series of JSON files will be generated: one in GeoJSON format; the other as TopoJSON.

For both, the geometry is projected in [the Lambert azimuthal equal-area projection](https://en.wikipedia.org/wiki/Lambert_azimuthal_equal-area_projection), centered on (27° N, 145° W).

For the TopoJSON files only, the geometry is quantized and simplified.

#### shp/\*/

A directory will be generated for each layer, along with the various files that comprise the shapefile format, plus a .ZIP archive containing them all.

These are intended to be identical in format to the original Census Bureau shapefiles, up to XML metadata, and with the exception that these are UTF-8-encoded.

## Layers

All layers are derived from the 2018 edition of the U.S. Census Bureau’s TIGER/Line shapefiles. Note that the U.S. Minor Outlying Islands aren’t included in these.

### judicial_circuit

Judicial circuits are the largest units of U.S. federal judicial geography (other than the nation as a whole), and each is home to a corresponding United States Court of Appeals. Circuits are composed of judicial districts, as defined in [28 U.S.C. § 41](https://uscode.house.gov/browse/prelim@title28/part1/chapter3/section41).

![Judicial Circuits](https://raw.githubusercontent.com/cahutton/us-judicial-geography/master/images/judicial-circuit.png)

The only boundary between circuits that doesn’t follow state boundaries is the one between the Ninth and Tenth Circuits. Due to the definition of the District of Wyoming, the parts of Idaho and Montana within Yellowstone National Park belong to a different circuit than the bulk of those states.

Territories that are not part of a judicial district are not included.

Geometry for the Federal Circuit is not included, despite it being composed of all judicial districts. The union of all features in the layer would be equivalent.

### judicial_district

Judicial districts are the primary units of U.S. federal judicial geography; each corresponds to a United States District Court. No distinction is made here between districts of courts established under Article III of the Constitution (those for the 50 states, the District of Columbia, and Puerto Rico) and those established under Article IV (the territorial courts of Guam, the Northern Mariana Islands, and the Virgin Islands). Districts are defined in [28 U.S.C. §§ 81–131](https://uscode.house.gov/browse/prelim@title28/part1/chapter5) (as to the states, D.C., and Puerto Rico), [48 U.S.C. § 1424 & seqq.](https://uscode.house.gov/browse/prelim@title48/chapter8A/subchapter4) (as to Guam), [48 U.S.C. § 1611 & seqq.](https://uscode.house.gov/browse/prelim@title48/chapter12/subchapter5) (as to the Virgin Islands), and [48 U.S.C. § 1821 & seqq.](https://uscode.house.gov/browse/prelim@title48/chapter17/subchapter2) (as to the Northern Mariana Islands).

![Judicial Districts](https://raw.githubusercontent.com/cahutton/us-judicial-geography/master/images/judicial-district.png)

American Samoa and Navassa Island are not included in any district.

With two exceptions, all districts comprise whole, single states (or equivalents) or are contained within a single state.

* The District of Hawaii includes the State of Hawaii plus all of the Pacific minor outlying islands.
* The District of Wyoming includes the State of Wyoming plus the portions of Idaho and Montana that lie within Yellowstone National Park.

With two exceptions, all districts are composed of entire counties (or equivalents).

* The District of Wyoming includes all of Yellowstone National Park, dividing a portion of Fremont County from the rest of Idaho, and portions of Gallatin and Park Counties from the rest of Montana.
* The Eastern District of North Carolina contains the entirety of the Federal Correctional Institute, Butner, North Carolina, including a small part of Durham County.

### judicial_district_county

![Judicial District Counties](https://raw.githubusercontent.com/cahutton/us-judicial-geography/master/images/judicial-district-county.png)

These are the elements from which the other layers are constructed. With the exceptions noted above about partitioned counties, this layer is almost identical to the original county data.

Unlike all the other layers, this one includes all the territories in the source files—in other words, American Samoa is only included in this layer.

### statutory_judicial_division

![Statutory Judicial Divisions](https://raw.githubusercontent.com/cahutton/us-judicial-geography/master/images/judicial-division.png)

Many judicial districts are split into "divisions" for administrative purposes. The ones included here are those defined in the current U.S. Code.

Territories that are not part of a judicial district are not included.

## License

Licensed under the MIT License (see [LICENSE.md](LICENSE.md)).
