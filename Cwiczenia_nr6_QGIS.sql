--1
--Wczytuję trees -> styl -> unikalny -> dla VEGDESC -> kolory -> zastosuj
--różne kolory dla drzew 
--pierwsza opcja, jeśli AREA_KM2 to pole danego drzewa
SELECT SUM(trees.AREA_KM2) AS Pole_mieszanych_drzew FROM trees WHERE VEGDESC='Mixed Trees';

--2
--wektor -> narzędzie zarządzania danymi -> podziel warstwę wektorową -> VEGDESC jako pole
--z unikalnym ID -> zapisz w katalogu

--aby zignorować nieprawidłową geometrię niektórych obiektów ->
--ustawienia -> opcje ogólne -> preprocessing -> filtrowanie nieprawidłowych obiektów -> ignoruj

--3
SELECT SUM(ST_Length(railroads.Geometry)) AS Dlugosc_kolei FROM regions, railroads WHERE regions.NAME_2='Matanuska-Susitna';

--4
SELECT AVG(ELEV) AS Srednia_wysokosc FROM airports WHERE USE='Military';
--ile obiektów powyżej 1400m - 8 lotnisk
SELECT airports.ID as Obiekt FROM airports WHERE USE='Military';
--sprawdzenie ile lotnisk jest powyżej 1400m 
SELECT COUNT(*) as Ilosc_obiektow FROM airports WHERE USE='Military'
AND ELEV > 1400; -- 1 lotnisko
--usuniecie
DELETE FROM airports WHERE USE='Military' AND ELEV>1400;

--5
--stworzenie budynkow na nowej warstwie
SELECT * FROM popp, regions WHERE regions.NAME_2='Bristol Bay' AND popp.F_CODEDESC='Building' AND Contains(regions.geometry, popp.geometry);
--liczba budynkow
SELECT COUNT(*) AS il_budynkow FROM popp, regions WHERE regions.NAME_2='Bristol Bay' AND popp.F_CODEDESC='Building' AND Contains(regions.geometry, popp.geometry);
--liczba budynkow - 5 
SELECT COUNT(*) AS il_budynkow2 FROM popp, regions, rivers WHERE popp.F_CODEDESC='Building' AND regions.NAME_2='Bristol Bay' AND ST_Contains(ST_Buffer(rivers.Geometry,100000), popp.Geometry) AND ST_Contains(regions.geometry, popp.geometry);


--6
SELECT COUNT(*) FROM majrivers, railroads WHERE ST_Intersects(majrivers.Geometry, railroads.Geometry);

--7
--wektor -> narzędzia geometrii -> wydobądź wierzchołki
--662 wierzchołki

--8
SELECT re.NAME_2 FROM regions re, airports air, railroads ra 
WHERE ST_Distance(air.Geometry, re.Geometry) < 100000 
AND ST_Distance(ra.Geometry, re.Geometry) >= 50000 
LIMIT 1;

--9
SELECT SUM(AREAKM2) from swamp; --wynosi 24719,761
--wydobądź wierzchołki: 7469

--wektor -> narzędzia geometrii -> uprość geometrię -> tolerancja 100
--po uproszczeniu: pole powierzchni nie zmieniło się, wierzchołki: 6661
