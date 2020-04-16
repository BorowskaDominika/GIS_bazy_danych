--cwiczenia nr 3 POST_GIS
create database gis_cw3;
-- Enable PostGIS (includes raster)
CREATE EXTENSION postgis;

--tworzenie tabeli 
--tabela budynki
create table budynki
(
	budynek_id INTEGER,
	budynek_nazwa VARCHAR(50),
	budynek_wysokosc FLOAT,
	geom_budynki GEOMETRY
);
--tabela drogi
create table drogi
(
	droga_id INTEGER,
	droga_nazwa VARCHAR(50),
	geom_droga GEOMETRY
);
--tabela pktinfo
create table pktinfo 
(
	pktinfo_id INTEGER,
	pktinfo_nazwa VARCHAR(50),
	pktinfo_liczprac INTEGER,
	geom_pktinfo GEOMETRY
);
--układ współrzędnych ma być niezdefiniowany
--czyli SDRID= -1
insert into pktinfo(pktinfo_id, pktinfo_nazwa, pktinfo_liczprac, geom_pktinfo) values 
(1, 'G', '5', ST_GeomFromText('Point(1 3.5)', -1)), (2, 'I', '4', ST_GeomFromText('Point(9.5 6)', -1)),
(3, 'J', '3', ST_GeomFromText('Point(6.5 6)', -1)), (4, 'K', '8', ST_GeomFromText('Point(6 9.5)', -1)), 
(5, 'H', '5', ST_GeomFromText('Point(5.5 1.5)', -1));

insert into drogi values (1, 'RoadX', ST_GeomFromText('Linestring(0 4.5, 12 4.5)', -1)), 
(2, 'RoadY', ST_GeomFromText('Linestring(7.5 10.5, 7.5 0)', -1));

insert into budynki values (1, 'BuildingA', '40.5', ST_GeomFromText('Polygon((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', -1)),
(2, 'BuildingB', '42.5', ST_GeomFromText('Polygon((4 7, 6 7, 6 5, 4 5, 4 7))', -1)),
(3, 'BuildingC', '21.3', ST_GeomFromText('Polygon((3 8 , 5 8, 5 6, 3 6, 3 8))', -1)),
(4, 'BuildingD', '60.2', ST_GeomFromText('Polygon((9 9 , 10 9, 10 8, 9 8, 9 9))', -1)),
(5, 'BuildingF', '32.5', ST_GeomFromText('Polygon((1 2, 2 2, 2 1, 1 1, 1 2))', -1));

--1
select sum(ST_Length(geom_droga)) as "Calkowita dlugosc drog" from drogi;
--2
select geom_budynki as "Geometria", ST_Area(geom_budynki) as "Pole", ST_Perimeter(geom_budynki) as "Obwod"
from budynki 
where budynki.budynek_nazwa='BuildingA';

--3
select budynek_nazwa as "Nazwa budynku", ST_Area(geom_budynki) as "Powierzchnia budynku"
from budynki
order by budynek_nazwa ASC;

--4
--dla obwodu
select budynek_nazwa as "Nazwa budynku", ST_Perimeter(geom_budynki) as "Obwod budynku"
from budynki
order by ST_Perimeter(geom_budynki) desc 
limit 2;
--dla pola
select budynek_nazwa as "Nazwa budynku", ST_Area(geom_budynki) as "Pole budynku"
from budynki
order by ST_Area(geom_budynki) desc 
limit 2;

--5
SELECT ST_Length(ST_ShortestLine(geom_budynki, geom_pktinfo)) 
AS "Najkrotsza Odległosc" FROM budynki, pktinfo WHERE budynki.budynek_nazwa='BuildingC' AND pktinfo.pktinfo_nazwa='G';

--6
SELECT ST_Area(ST_Difference(u1.geom_budynki, ST_Intersection(u1.geom_budynki, ST_Buffer(u2.geom_budynki, 0.5, 'join=mitre')))) 
FROM budynki u1, budynki u2 
WHERE u1.budynek_nazwa ='BuildingB' 
AND u2.budynek_nazwa ='BuildingC';


--7
select budynki.* 
from budynki, drogi
where drogi.droga_nazwa='RoadX'
and ST_Centroid(geom_budynki) |>> geom_droga;
-- |>> oznacza że centroid musi być nad droga X

--8 
SELECT ST_Area(ST_SymDifference(geom_budynki, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))',-1))) 
FROM budynki WHERE budynki.budynek_nazwa ='BuildingC';

