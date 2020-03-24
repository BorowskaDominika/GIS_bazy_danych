-- 1. Tworze baze danych o nazwie sNumerIndeksu 
CREATE DATABASE s299611;

-- 2. Dodaje schemat o nazwie firma
CREATE SCHEMA firma;

-- 3. Tworze role o nazwie ksiegowosc
CREATE ROLE ksiegowosc;
-- nadaje jej uprawnienia tylko do odczytu: komenda GRANT SELECT
GRANT SELECT ON ALL TABLES IN schema firma TO ksiegowosc;

-- 4. Dodaje 4 tabele

-- Table: firma.pracownicy
-- wszystkie pola musza byc NOT NULL
CREATE TABLE pracownicy 
(
    id_pracownika int  NOT NULL,
    imie char(30)  NOT NULL,
    nazwisko char(50)  NOT NULL,
    adres char(50)  NOT NULL,
    telefon text  NOT NULL,
    CONSTRAINT pracownicy_pk PRIMARY KEY (id_pracownika)
);
-- using btree, hash itd, automatycznie btree
CREATE INDEX nazwisko_pracownika ON pracownicy (nazwisko ASC);

--dodaje komentarz za pomoca komendy COMMENT
COMMENT ON TABLE pracownicy IS 'Aktualni pracownicy naszej firmy';

-- Table: firma.pensja_stanowisko
CREATE TABLE pensja_stanowisko
(
    id_pensji int  NOT NULL,
    stanowisko text  NOT NULL,
    kwota money  NOT NULL,
    CONSTRAINT pensja_stanowisko_pk PRIMARY KEY (id_pensji)
);

--dodaje komentarz za pomoca komendy COMMENT
COMMENT ON TABLE pensja_stanowisko IS 'Stanowisko danego pracownika';

-- Table: firma.premia
CREATE TABLE premia 
(
    id_premii int  NOT NULL,
    rodzaj text  NOT NULL,
    kwota money,
    CONSTRAINT premia_pk PRIMARY KEY (id_premii)
);

--dodaje komentarz za pomoca komendy COMMENT
COMMENT ON TABLE premia IS 'Premie dla pracownikow';

CREATE TABLE godziny 
(
    id_godziny int  NOT NULL,
    data date NOT NULL,
    liczba_godzin int  NOT NULL,
    pracownicy_id_pracownika int  NOT NULL,
    CONSTRAINT  godziny_pk PRIMARY KEY (id_godziny)
);

--dodaje komentarz za pomoca komendy COMMENT
COMMENT ON TABLE godziny IS 'Godziny pracy';

-- Table: wynagrodzenie

CREATE TABLE wynagrodzenie 
(
    id_wynagrodzenia int  NOT NULL,
    data date  NOT NULL,
    premia_id_premii int  NOT NULL,
    pensja_stanowisko_id_pensji int  NOT NULL,
    godziny_id_godziny int  NOT NULL,
    pracownicy_id_pracownika int  NOT NULL,
    CONSTRAINT wynagrodzenie_pk PRIMARY KEY (id_wynagrodzenia)
);

--dodaje komentarz za pomoca komendy COMMENT
COMMENT ON TABLE wynagrodzenie IS 'Wynagrodzenie pracownikow';

-- foreign keys
-- Reference: firma.godziny_firma.pracownicy (table: firma.godziny)
ALTER TABLE godziny ADD CONSTRAINT godziny_pracownicy
    FOREIGN KEY (pracownicy_id_pracownika)
    REFERENCES pracownicy (id_pracownika)  
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: firma.wynagrodzenie_firma.godziny (table: firma.wynagrodzenie)
ALTER TABLE wynagrodzenie ADD CONSTRAINT wynagrodzenie_godziny
    FOREIGN KEY (godziny_id_godziny)
    REFERENCES godziny (id_godziny)  
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: firma.wynagrodzenie_firma.pensja_stanowisko (table: firma.wynagrodzenie)
ALTER TABLE wynagrodzenie ADD CONSTRAINT wynagrodzenie_pensja_stanowisko
    FOREIGN KEY (pensja_stanowisko_id_pensji)
    REFERENCES pensja_stanowisko (id_pensji)  
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: firma.wynagrodzenie_firma.pracownicy (table: firma.wynagrodzenie)
ALTER TABLE wynagrodzenie ADD CONSTRAINT wynagrodzenie_pracownicy
    FOREIGN KEY (pracownicy_id_pracownika)
    REFERENCES pracownicy (id_pracownika)  
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: firma.wynagrodzenie_firma.premia (table: firma.wynagrodzenie)
ALTER TABLE wynagrodzenie ADD CONSTRAINT wynagrodzenie_premia
    FOREIGN KEY (premia_id_premii)
    REFERENCES premia (id_premii)  
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

--dodaje do tabeli godziny pole na miesiac i na tydzien
ALTER TABLE godziny
ADD miesiac int NOT NULL;

ALTER TABLE godziny
ADD tydzien int NOT NULL;

INSERT INTO pracownicy VALUES ('1', 'Jan', 'Kowalski', 'Wieliczka ul. Krakowska 5/1', '578989090'),
('2', 'Stanisław', 'Łacina', 'Oświęcim ul. Zaborska 1', '789678123'), ('3', 'Alicja', 'Zapolska', 'Chrzanów ul. Więźniów 9a', '676889012'),
('4', 'Kacper', 'Leszczyński', 'Kraków ul. Mickiewicza 58', '517908784'), ('5', 'Izabela', 'Nowak', 'Rajsko ul. Słowackiego 19', '789098999'),
('6', 'Minsu', 'Kim', 'Kraków ul. Szewska 89a', '572345785'), ('7', 'Wan', 'Li', 'Kraków ul. Jasnogórska 90/2', '675178345'),
('8', 'Adam', 'Jankowski', 'Warszawa ul. Jana Pawła II 122/1', '666989096'), ('9', 'Lisa', 'Kim', 'Kraków ul. Rostafińskiego 8 1409A', '574893475'),
('10', 'Julia', 'Dudkowska', 'Oświęcim ul. Nojego 10', '563890677');

INSERT INTO pensja_stanowisko VALUES ('1', 'Kierownik ds. Rozwoju', '15000'), ('2', 'Sekretarka', '2000'), ('3', 'HR Department', '6000'),
('4', 'RnD Department', '6400'), ('5', 'Księgowość', '3580'), ('6', 'IT Support', '8900'), ('7', 'Kierownik ds. Sprzedaży', '12000'),
('8', 'Kierownik ds. Administracji', '11000'), ('9', 'Kierownik ds. Marketingu', '12000'), ('10', 'Dział Kadr', '4500'), 
('11', 'Dział Obsługi Klienta', '4100');

INSERT INTO premia VALUES ('1', 'premia miesięczna', '300'), ('2', 'premia kwartalna', '500'), ('3', 'premia roczna', '1100'),
('4', 'premia za polecenie', '500'), ('5', 'premia świąteczna', '500'), ('6', 'brak', '0'), ('7', 'premia chorobowa', '300'), 
('8', 'premia motywacyjna', '200'), ('9', 'premia za patent', '5000'), ('10', 'premia 13-stka', '2000');

--zamieniam pole data na typ text w tabeli wynagrodzenie
ALTER TABLE wynagrodzenie ALTER COLUMN data TYPE text;

INSERT INTO godziny VALUES ('1', '01-01-2020', '160', '1', '1', '4'), 
('2', '01-01-2020', '160', '2', '1', '4'), ('3','01-01-2020', '160', '3', '1', '4'), 
('4', '01-02-2020', '160', '4', '2', '4'), ('5', '01-02-2020', '165', '5', '2', '4'), 
('6', '01-03-2020', '170', '6', '3', '4'), ('7', '02-01-2020', '140', '7', '1', '3'),
('8', '10-02-2020', '160', '8', '2', '4'), ('9', '01-02-2020', '160', '9', '2', '4'), 
('10', '01-01-2020', '160', '10', '1', '4');

INSERT INTO wynagrodzenie VALUES ('1', '10-02-2020', '1', '1', '1', '1'), 
('2', '10-02-2020', '6', '2', '2', '2'), ('3', '10-02-2020', '6', '3', '3', '3'),
('4', '10-03-2020', '5', '4', '4', '4'), ('5', '10-03-2020', '2', '5', '5', '5'),
('6', '10-04-2020', '9', '6', '6', '6'), ('7', '10-02-2020', '7', '7', '7', '7'),
('8', '10-03-2020', '8', '8', '8', '8'), ('9', '10-03-2020', '6', '9', '9', '9'),
('10', '10-00-2020', '6', '10', '10', '10');

--zapytania sql 
--6a
SELECT id_pracownika, nazwisko FROM pracownicy;
--6b
SELECT pracownicy.id_pracownika FROM pracownicy, wynagrodzenie, pensja_stanowisko 
WHERE pensja_stanowisko.kwota>1000::money AND pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika 
AND pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji; 
--6c
SELECT pracownicy.id_pracownika 
FROM pracownicy, wynagrodzenie, premia, pensja_stanowisko 
WHERE pensja_stanowisko.kwota > 2000::money AND premia.rodzaj='brak' 
AND pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika 
AND pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji 
AND premia.id_premii=wynagrodzenie.premia_id_premii;
--6d
SELECT * FROM pracownicy WHERE imie LIKE 'J%';
--6e 
SELECT * FROM pracownicy WHERE imie LIKE '%a' AND nazwisko LIKE '%n%';
--6f
SELECT pracownicy.imie, pracownicy.nazwisko, godziny.liczba_godzin-160 FROM pracownicy, godziny 
WHERE godziny.liczba_godzin>160 AND pracownicy.id_pracownika=godziny.pracownicy_id_pracownika;
--6g
SELECT pracownicy.imie, pracownicy.nazwisko 
FROM pracownicy, pensja_stanowisko, wynagrodzenie  WHERE pensja_stanowisko.kwota 
BETWEEN 1500::money AND 3000::money AND pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika 
AND pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji; 
--6h
SELECT pracownicy.imie, pracownicy.nazwisko 
FROM pracownicy, godziny, premia, wynagrodzenie 
WHERE godziny.liczba_godzin>160 AND premia.rodzaj='brak' 
AND pracownicy.id_pracownika=godziny.pracownicy_id_pracownika 
AND premia.id_premii=wynagrodzenie.premia_id_premii AND pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika;

--zadanie 7
--a - rosnaco
SELECT pracownicy.* FROM pracownicy, wynagrodzenie, pensja_stanowisko 
WHERE pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika 
AND pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji 
ORDER BY pensja_stanowisko.kwota ASC;

--b malejaco
SELECT pracownicy.* FROM pracownicy, wynagrodzenie, pensja_stanowisko 
WHERE pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika 
AND pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji 
ORDER BY pensja_stanowisko.kwota DESC;

--c
SELECT pensja_stanowisko.stanowisko, Count(*) as "liczba pracownikow" 
FROM pracownicy, pensja_stanowisko, wynagrodzenie 
WHERE pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji 
AND pracownicy.id_pracownika=wynagrodzenie.pracownicy_id_pracownika 
GROUP BY pensja_stanowisko.stanowisko;

--d srednia kierownikow
SELECT AVG(pensja_stanowisko.kwota::numeric)
AS "Srednia placa kierownika" FROM pensja_stanowisko 
WHERE pensja_stanowisko.stanowisko like '%Kierownik%';
--pensja minimalna
select MIN(pensja_stanowisko.kwota::numeric)
AS "Minimalna placa kierownika" FROM pensja_stanowisko 
WHERE pensja_stanowisko.stanowisko like '%Kierownik%';
--pensja maksymalna
select MAX(pensja_stanowisko.kwota::numeric)
AS "Max placa kierownika" FROM pensja_stanowisko 
WHERE pensja_stanowisko.stanowisko like '%Kierownik%';

--e
SELECT SUM(pensja_stanowisko.kwota) FROM pensja_stanowisko;

--f
SELECT SUM(pensja_stanowisko.kwota) 
as "Pensja dla stanowiska kierownik"
FROM pensja_stanowisko
where pensja_stanowisko.stanowisko like '%Kierownik%';

SELECT SUM(pensja_stanowisko.kwota) 
as "Pensja dla stanowiska dla dział"
FROM pensja_stanowisko
where pensja_stanowisko.stanowisko like '%Dział%';

--g
select Count(premia.id_premii) as "Liczba premii" 
from premia, pensja_stanowisko, wynagrodzenie 
where pensja_stanowisko.id_pensji=wynagrodzenie.pensja_stanowisko_id_pensji 
AND premia.id_premii=wynagrodzenie.premia_id_premii 
group by pensja_stanowisko.stanowisko;

--h

--zadanie 8
--a
UPDATE pracownicy 
SET telefon='(+48)'::text || telefon;

--c
SELECT UPPER(nazwisko)
FROM pracownicy
as "nazwisko klienta"
WHERE LENGTH(nazwisko) = 
              (SELECT  MAX(LENGTH(pracownicy.nazwisko))
              FROM pracownicy);

--zadanie 9



