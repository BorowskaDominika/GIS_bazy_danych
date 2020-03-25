-- 1. Dodaje schemat o nazwie sklep
CREATE SCHEMA sklep;

--2. Tworze tabele producenci, produkty oraz zamowienia 

-- Table: sklep.producenci
CREATE TABLE producenci (
    id_producenta int  NOT NULL,
    nazwa_producenta varchar(50)  NOT NULL,
    mail text  NOT NULL,
    telefon text  NOT NULL,
    CONSTRAINT producenci_pk PRIMARY KEY (id_producenta)
);

-- Table: sklep.produkty
CREATE TABLE produkty (
    id_produktu int  NOT NULL,
    nazwa_produktu text  NOT NULL,
    cena money  NOT NULL,
    producenci_id_producenta int  NOT NULL,
    CONSTRAINT produkty_pk PRIMARY KEY (id_produktu)
);

-- Table: sklep.zamowienia
CREATE TABLE zamowienia (
    id_zamowienia int  NOT NULL,
    miejsce_dostawy text  NOT NULL,
    data_zlozenia_zamowienia date  NOT NULL,
    czy_przyjeto_zamowienie boolean  NOT NULL,
    produkty_id_produktu int  NOT NULL,
    CONSTRAINT zamowienia_pk PRIMARY KEY (id_zamowienia)
);

--klucze obce
-- Reference: sklep.produkty_sklep.producenci (table: sklep.produkty)
ALTER TABLE produkty ADD CONSTRAINT produkty_producenci
    FOREIGN KEY (producenci_id_producenta)
    REFERENCES producenci (id_producenta)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: sklep.zamowienia_sklep.produkty (table: sklep.zamowienia)
ALTER TABLE zamowienia ADD CONSTRAINT zamowienia_produkty
    FOREIGN KEY (produkty_id_produktu)
    REFERENCES produkty (id_produktu)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

INSERT INTO producenci VALUES ('1', 'Honda', 'honda_automotive@gmail.com', '689987567'), ('2', 'Nissan', 'nissan@gmail.com', '789674567'), 
('3', 'Suzuki', 'suzuki_dev@gmail.com', '455785478'), ('4', 'Subaru', 'subaru@o2.com', '908278345'),
('5', 'CJ E&M', 'cj_ent@naver.com', '455677899'), ('6', 'LG Group', 'lg_group@naver.com', '897679116'), 
('7', 'Samsung', 'samsung_korea@naver.com', '344689122'), ('8', 'Daewoo', 'daewoo_automotive@naver.com', '908675345'),
('9', 'Kakao', 'kakao_group_korea@naver.kr', '589374889'), ('10', 'Alibaba', 'alibaba_group@weibo.com', '233455890');

INSERT INTO produkty VALUES ('1', 'Honda Asimo', '50000', '1'), ('2', 'Nissan Eporo', '40000', '2'),
('3', 'Suzuki Akira', '20000', '3'), ('4', 'Subaru Echo', '24000', '4'), ('5', 'RJ', '250', '5'),
('6', 'Shooky', '250', '5'), ('7', 'LG Swift', '2400', '6'), ('8', 'Smart Lamp', '600', '7'),
('9', 'Electro Car', '5000', '8'), ('10', 'Kakao Emoji Pillow', '300', '9'),
('11', 'Kakao Carpet', '400', '9'), ('12', 'Mask', '20', '10');

INSERT INTO zamowienia VALUES ('1', 'Krakow', '2020-01-02', '1', '1'), ('2', 'Warszawa', '2019-09-12', '1', '1'), ('3', 'Paryz', '2019-12-11', '1', '2'),
('4', 'Krakow', '2019-07-23', '1', '2'), ('5', 'Krakow', '2019-12-30', '1', '10'), ('6', 'Wroclaw', '2020-02-10', '1', '11'), 
('7', 'Poznan', '2020-04-01', '1', '3'), ('8', 'Krakow', '2020-01-17', '1', '4'), ('9', 'Warszawa', '2019-06-16', '1', '12'), 
('10', 'Londyn', '2019-09-19', '1', '10'), ('11', 'Krakow', '2019-08-21', '1', '9'), 
('12', 'Londyn', '2020-02-13', '1', '8'), ('13', 'Poznan', '2020-01-25', '1', '8'), ('14', 'Warszawa', '2020-02-04', '1', '7'), 
('15', 'Warszawa', '2020-03-20', '1', '6'), ('16', 'Oswiecim', '2019-05-25', '1', '5'),
('17', 'Krakow', '2019-04-15', '1', '4'), ('18', 'Krakow', '2019-03-17', '1', '3'), ('19', 'Berlin', '2020-03-16', '1', '4'), 
('20', 'Wroclaw', '2020-03-23', '1', '8');

--11a
select producenci.nazwa_producenta as "Producent", Count(zamowienia.id_zamowienia) 
as "Liczba zamówień", SUM(produkty.cena) as "Wartość zamówień" from producenci, zamowienia, produkty 
where produkty.id_produktu=zamowienia.produkty_id_produktu 
and producenci.id_producenta=produkty.producenci_id_producenta group by producenci.nazwa_producenta; 

--11b
select produkty.nazwa_produktu as "Produkt", Count(zamowienia.id_zamowienia) as "Liczba zamówień produktu" 
from produkty, zamowienia 
where produkty.id_produktu=zamowienia.produkty_id_produktu group by produkty.nazwa_produktu; 

--11c
alter table zamowienia 
rename column produkty_id_produktu to id_produktu;

select * from produkty
natural join zamowienia;

--11e
select * from zamowienia
where extract(month from data_zlozenia_zamowienia) = 01;

--11f
select extract(DOW from zamowienia.data_zlozenia_zamowienia) as "Nr dnia tygodnia", Count(zamowienia.id_zamowienia) 
as "Ilość zamówień" from zamowienia group by extract(DOW from zamowienia.data_zlozenia_zamowienia) order by count(zamowienia.id_zamowienia) desc ;

--11g
select produkty.nazwa_produktu, Count(zamowienia.id_zamowienia) as "Ilość zamówień" 
from produkty, zamowienia where produkty.id_produktu=zamowienia.id_produktu  
group by produkty.nazwa_produktu order by count(zamowienia.id_zamowienia) desc;


--12a
SELECT 'Produkt '::text || UPPER(produkty.nazwa_produktu) || ' ktorego producentem jest '::text || lower(producenci.nazwa_producenta) || ' zamowiono '::text || Count(zamowienia.id_zamowienia)::text
|| ' razy '::text
as "opis"
FROM produkty, producenci, zamowienia 
where produkty.id_produktu=zamowienia.id_produktu 
and producenci.id_producenta=produkty.producenci_id_producenta
group by produkty.nazwa_produktu, producenci.nazwa_producenta
order by count(zamowienia.id_zamowienia) desc;

--12b
select zamowienia.*, produkty.cena
from zamowienia
natural join produkty
order by produkty.cena desc limit (20-3);

--12c
--tworze tabele klienci
CREATE TABLE klienci (
    id_klienta int  NOT NULL,
    e_mail text  NOT NULL,
    telefon text  NOT NULL,
    CONSTRAINT klienci_pk PRIMARY KEY (id_klienta)
);

insert into klienci values ('1', 'kowalski@gmail.com', '666787890'), ('2', 'janowski@gmail.com', '567354682'), 
('3', 'anna_dudkowska@wp.pl', '502458978'), ('4', 'jan_nowak_75@onet.pl', '786546123'), ('5', 'ewa_ewa@gmail.com', '785673234'),
('6', 'lee_song@naver.com', '234586776');


alter table zamowienia
add column klienci_id_klienta int;

--dodaje relacje
-- Reference: zamowienia_klienci (table: zamowienia)
ALTER TABLE zamowienia ADD CONSTRAINT zamowienia_klienci
    FOREIGN KEY (klienci_id_klienta)
    REFERENCES klienci (id_klienta)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

--dodaje klientow do zamowien

update zamowienia
set klienci_id_klienta='1'
where id_zamowienia=1;

update zamowienia
set klienci_id_klienta='3'
where id_zamowienia>18;

update zamowienia
set klienci_id_klienta='2'
where id_zamowienia>1 and id_zamowienia<4;

update zamowienia
set klienci_id_klienta='4'
where id_zamowienia>=4 and id_zamowienia<6;

update zamowienia
set klienci_id_klienta='5'
where id_zamowienia=8;

update zamowienia
set klienci_id_klienta='6'
where id_zamowienia>8 and id_zamowienia<11;

update zamowienia
set klienci_id_klienta='2'
where id_zamowienia>10 and id_zamowienia<15;

update zamowienia
set klienci_id_klienta='3'
where id_zamowienia>14 and id_zamowienia<19;

update zamowienia
set klienci_id_klienta='1'
where id_zamowienia=6;

update zamowienia
set klienci_id_klienta='6'
where id_zamowienia=7;

--12e
select klienci.id_klienta, produkty.nazwa_produktu, SUM(produkty.cena) 
as "wartość zamówienia" from zamowienia, produkty, klienci 
where produkty.id_produktu=zamowienia.id_produktu 
and klienci.id_klienta=zamowienia.klienci_id_klienta 
group by klienci.id_klienta, produkty.nazwa_produktu 
order by klienci.id_klienta;


--12f
select klienci.id_klienta 
as "Najczęściej zamawiający", klienci.e_mail, klienci.telefon, count(zamowienia.id_zamowienia), SUM(produkty.cena) 
as "wartość zamówienia" from klienci, zamowienia, produkty 
where klienci.id_klienta=zamowienia.klienci_id_klienta 
and produkty.id_produktu=zamowienia.id_produktu 
group by klienci.id_klienta 
order by count(zamowienia.id_zamowienia) 
desc limit 3; --12f NAJCZĘŚCIEJ

select klienci.id_klienta 
as "Najrzadziej zamawiający", klienci.e_mail, klienci.telefon, count(zamowienia.id_zamowienia),SUM(produkty.cena) 
as "wartość zamówienia" from klienci, zamowienia, produkty 
where klienci.id_klienta=zamowienia.klienci_id_klienta 
and produkty.id_produktu=zamowienia.id_produktu 
group by klienci.id_klienta 
order by count(zamowienia.id_zamowienia) asc limit 3; --12f NAJRZADZIEJ

--13
--a
CREATE TABLE numer (
    liczba bigint NOT null primary key
);

--b
CREATE SEQUENCE liczba_seq
AS BIGINT
START WITH 100
minvalue 0
maxvalue 125
INCREMENT BY 5
cycle;

--c


--d
alter sequence liczba_seq
increment by 6;

--e
--currval nextval

--f
DROP SEQUENCE IF EXISTS liczba_seq;

--14
--a
select * from user;
select * from pg_user; --pokazuje wszystkich userow
--b
create user Superuser299611;
create user guest299611;
GRANT ALL on all tables in schema sklep to Superuser299611;
GRANT SELECT on all tables in schema sklep to guest299611;
select * from pg_user;
--c
alter user Superuser299619 rename to student;
revoke ALL on all tables in schema sklep from student;
GRANT SELECT on all tables in schema sklep to student;
revoke ALL on all tables in schema sklep from guest299611;
drop user guest299611;
select * from pg_user;

--15 transakcje
--a
BEGIN transaction;
UPDATE produkty
SET cena = cena + '10'::money;
COMMIT transaction;
--b
begin transaction;
update produkty 
set cena = cena + (cena/100)*10
where id_produktu =3;
savepoint s1;
--jak zwiekszyc zamowienia o 25%?? dodac rekordy?
--jak usunac klienta?
commit transaction;
--c



