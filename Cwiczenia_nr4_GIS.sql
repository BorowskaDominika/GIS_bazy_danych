--1 Pobrano sqLite oraz spatiaLite-GUI

--2 Pobrano przykładowe dane dotyczące Alaski

--3 Korzystając z spatiaLite GUI utworzono nową bazę danych
-- o nazwie Cwiczenia_nr4 oraz zaimportowano do niej
--potrzebne pliki shapefile. Każdy plik zaimportował się jako osobna tabela.

--4 Liczba budynków położona w mniejszej odległości niż 100000m
-- od głównych rzek(zapisane w tabeli tableB)
create table tableB as 
	select f_codedesc as liczba_budynkow from popp p, majrivers m 
	where Contains(Buffer(m.Geometry, 100000), p.Geometry);

select * from tableB;

--5 
create table airportsNew as
	select NAME, Geometry, ELEV from airports;
--5a
--najbardziej na zachód
select * from airportsNew 
order by MbrMinY(Geometry) asc limit 1;
--najbardziej na wschód
select * from airportsNew 
order by MbrMaxY(Geometry) desc limit 1;
--5b
--aby wybrać średnią wysokość
select avg(ELEV) from airportsNew
where NAME="NIKOLSKI AS" or NAME="NOATAK";
--aby wybrać położenie pośrodku
select 0.5*Distance 
((SELECT Geometry FROM airportsNew 
WHERE NAME='NOATAK'),(SELECT Geometry FROM airportsNew 
WHERE NAME='NIKOLSKI AS') 
)
as "odleglosc";

--połączone
insert into airportsNew(NAME, Geometry, ELEV) 
	values ('airportB', (0.5*Distance 
((SELECT Geometry FROM airportsNew 
WHERE NAME='NOATAK'),(SELECT Geometry FROM airportsNew 
WHERE NAME='NIKOLSKI AS') 
)), (select avg(ELEV) from airportsNew
where NAME="NIKOLSKI AS" or NAME="NOATAK"));

--aby wyszukać czy się stworzyło 
select * from airportsNew where NAME="airportB";

--6
--funkcja ShortestLine zamiast Distance nie działa w sqlite
select Area(Buffer((Distance(lakes.Geometry, airports.Geometry)),1000)) 
from lakes, airports where lakes.NAMES='Iliamma Lake' 
and airports.NAME='AMBLER';

--7
select SUM(Area(Intersection(tundra.Geometry, trees.Geometry))) as "tundra",
	SUM(Area(Intersection(swamp.Geometry, trees.Geometry))) as "bagna", VEGDESC
from swamp, trees, tundra
group by VEGDESC;





