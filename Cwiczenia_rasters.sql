CREATE EXTENSION postgis_raster;

--PRZYKŁAD 1 ST_INTERSECTS
CREATE TABLE "schema_Borowska".intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

alter table "schema_Borowska".intersects
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_intersects_rast_gist ON "schema_Borowska".intersects
USING gist (ST_ConvexHull(rast));

-- schema::name table_name::name raster_column::name
SELECT AddRasterConstraints('schema_Borowska'::name,
'intersects'::name,'rast'::name);

--PRZYKŁAD 2 - ST_Clip
--Obcinanie rastra na podstawie wektora.
CREATE TABLE "schema_Borowska".clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

--PRZYKŁAD 3 - ST_Union
--Połączenie wielu kafelków w jeden raster.
CREATE TABLE "schema_Borowska".union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b 
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

--Rastrowanie wektoru
--PRZYKŁAD 1 - ST_AsRaster
CREATE TABLE "schema_Borowska".porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--PRZYKŁAD 2 - ST_Union
DROP TABLE "schema_Borowska".porto_parishes; --> drop table porto_parishes first
CREATE TABLE "schema_Borowska".porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--PRZYKŁAD 3 - ST_Tile
DROP TABLE "schema_Borowska".porto_parishes; --> drop table porto_parishes first
CREATE TABLE "schema_Borowska".porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1 )
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-
32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--wektoryzowanie
--PRZYKŁAD 1 - ST_Intersection
create table "schema_Borowska".intersection as
SELECT
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)
).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);
--Query returned successfully in 6 secs 148 msec.

--PRZYKŁAD 2 - ST_DumpAsPolygons
CREATE TABLE "schema_Borowska".dumppolygons AS
SELECT
a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,
(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--analiza rastrow
--PRZYKŁAD 1 - ST_Band
CREATE TABLE "schema_Borowska".landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

--PRZYKŁAD 2 - ST_Clip
CREATE TABLE "schema_Borowska".paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--PRZYKŁAD 3 - ST_Slope
CREATE TABLE "schema_Borowska".paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM "schema_Borowska".paranhos_dem AS a;

--PRZYKŁAD 4 - ST_Reclass
CREATE TABLE "schema_Borowska".paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3',
'32BF',0)
FROM "schema_Borowska".paranhos_slope AS a;

--PRZYKŁAD 5 - ST_SummaryStats
SELECT st_summarystats(a.rast) AS stats
FROM "schema_Borowska".paranhos_dem AS a;

--PRZYKŁAD 6 - ST_SummaryStats i Union
SELECT st_summarystats(ST_Union(a.rast))
FROM "schema_Borowska".paranhos_dem AS a;

--PRZYKŁAD 7 - ST_SummaryStats
WITH t AS (
SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM "schema_Borowska".paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

--PRZYKŁAD 8 z GROUP_BY
WITH t AS (
SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast,
b.geom,true))) AS stats
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

--PRZYKŁAD 9 - ST_Value
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

--PRZYKŁAD 10 - ST_TPI
create table "schema_Borowska".tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;
--Query returned successfully in 44 secs 675 msec.

CREATE INDEX idx_tpi30_rast_gist ON "schema_Borowska".tpi30
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('schema_Borowska'::name,
'tpi30'::name,'rast'::name);

--zadanie do wykonania
create table "schema_Borowska".TPI_Porto as
SELECT ST_TPI(a.rast,1) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto'
--Query returned successfully in 1 secs 653 msec. (ponad 40 razy mniej)

CREATE INDEX idx_tpi_porto_rast_gist ON "schema_Borowska".TPI_Porto
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('schema_Borowska'::name,
'TPI_Porto'::name,'rast'::name);

--algebra map
--PRZYKŁAD 1 - Wyrażenie Algebry Map
CREATE TABLE "schema_Borowska".porto_ndvi AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, 1,
r.rast, 4,
'([rast2.val] - [rast1.val]) / ([rast2.val] +
[rast1.val])::float','32BF'
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON "schema_Borowska".porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('schema_Borowska'::name,
'porto_ndvi'::name,'rast'::name);

--PRZYKŁAD 2 - funkcja zwrotna
create or replace function "schema_Borowska".ndvi(
value double precision [] [] [],
pos integer [][],
VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value
[1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE "schema_Borowska".porto_ndvi2 AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, ARRAY[1,4],
'"schema_Borowska".ndvi(double precision[],
integer[],text[])'::regprocedure, --> This is the function!
'32BF'::text
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON "schema_Borowska".porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('schema_Borowska'::name,
'porto_ndvi2'::name,'rast'::name);

--PRZYKŁAD 3 - funkcje TPI

--eksport danych
--PRZYKŁAD 1 - ST_AsTiff
SELECT ST_AsTiff(ST_Union(rast))
FROM "schema_Borowska".porto_ndvi;

--PRZYKŁAD 2 - ST_AsGDALRaster
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
FROM "schema_Borowska".porto_ndvi;

--Przykład 3 - Zapisywanie danych na dysku za pomocą dużego obiektu (large object, lo)
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
 ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
 ) AS loid
FROM "schema_Borowska".porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'D:\Pliki') --> Save the file in a place
 FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
 FROM tmp_out; --> Delete the large object.

--PRZYKŁAD 4 - użycie GDAL

--publikowanie danych
--za pomocą Mapfile
MAP
	NAME 'map'
	SIZE 800 650
	STATUS ON
	EXTENT -58968 145487 30916 206234
	UNITS METERS
	WEB
		METADATA
				'wms_title' 'Terrain wms'
				'wms_srs' 'EPSG:3763 EPSG:4326 EPSG:3857'
				'wms_enable_request' '*'
				'wms_onlineresource'
				'http://54.37.13.53/mapservices/srtm'
		END
	END
	PROJECTION
		'init=epsg:3763'
	END
	LAYER
		NAME srtm
		TYPE raster
		STATUS OFF
		DATA "PG:host=localhost port=5432 dbname='postgis_raster'
		user='sasig' password='postgis' schema='rasters' table='dem' mode='2'"
		PROCESSING "SCALE=AUTO"
		PROCESSING "NODATA=-32767"
		OFFSITE 0 0 0
		METADATA
			'wms_title' 'srtm'
		END
	END
END

