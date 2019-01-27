DROP FUNCTION IF EXISTS losowa_data_miedzy;
CREATE FUNCTION losowa_data_miedzy(fromDate date, toDate date)
RETURNS date
BEGIN
  DECLARE days_between INT;
  DECLARE days_rand INT;

  SET days_between = datediff(toDate, fromDate);
  SET days_rand = cast(RAND() * 10000 AS int) % days_between;
  RETURN date_add(fromDate, INTERVAL days_rand DAY );
END;

DROP PROCEDURE IF EXISTS generuj_oceny;
CREATE PROCEDURE generuj_oceny()
BLOCK1 : BEGIN
  DECLARE rok int;
  DECLARE semestr_ int DEFAULT 1;
  DECLARE kurs int;
  DECLARE sukces boolean DEFAULT TRUE;

  DECLARE psl char(11);
  DECLARE klasa char(4);
  DECLARE data_oceny date;
  DECLARE wartosc_oc varchar(2);
  DECLARE waga_oc int;

  DECLARE done int DEFAULT FALSE;
  DECLARE bad_data CONDITION FOR 30001;
  DECLARE index_uczen_klasa CURSOR FOR (SELECT id_ucznia,id_klasy FROM klasa_uczniowie);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  DECLARE CONTINUE HANDLER FOR bad_data SET sukces = FALSE;
  OPEN index_uczen_klasa;
  read_loop:
    LOOP
      FETCH index_uczen_klasa INTO psl,klasa;
      IF done THEN
        LEAVE read_loop;
      END IF;
      SET rok = cast(substring(klasa, 1, 2) AS int);
      IF rok < 17 THEN
        SET rok = 17;
      END IF;
      SET semestr_ = 1;
      WHILE rok < 19 DO

        BLOCK2 : BEGIN
          DECLARE liczba_ocen int;
          DECLARE k int;
          DECLARE done2 int DEFAULT FALSE;
          DECLARE index_kurs CURSOR FOR
            (SELECT DISTINCT id_kursu FROM zajecia JOIN klasa_uczniowie ON zajecia.id_klasy = klasa_uczniowie.id_klasy WHERE id_ucznia LIKE psl AND semestr LIKE concat(rok, '/', semestr_));
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = 1;
          OPEN index_kurs;
          loop_2:
            LOOP
              FETCH index_kurs INTO kurs;
              IF done2 THEN
                LEAVE loop_2;
              END IF;

              SET k = 0;
              SET liczba_ocen = floor(rand()*5) + 5;
              WHILE k < liczba_ocen DO
                SET sukces = FALSE;
                WHILE sukces = FALSE DO
                  SET sukces = TRUE;
                  SET wartosc_oc = elt(floor(rand()*14)+1, '1', '2-', '2', '2+', '3-', '3', '3+', '4-', '4', '4+', '5-', '5', '5+', '6');
                  SET waga_oc = elt(floor(rand()*5)+1, 1,2,3,4,5);
                  IF semestr_ = 1 THEN
                    SET data_oceny = losowa_data_miedzy(concat('20',rok, '-09-01'), concat('20', rok+1, '-01-30'));
                    ELSE
                    SET data_oceny = losowa_data_miedzy(concat('20',rok,'-02-01'), concat('20',rok,'-06-30'));
                  END IF;
                  INSERT INTO oceny (id_ucznia, id_kursu, data, semestr, typ, wartosc, waga, opis)
                  VALUES (psl, kurs, data_oceny, concat(rok, '/', semestr_), 'cząstkowa', wartosc_oc, waga_oc, elt(waga_oc, 'praca domowa', 'odpowiedź', 'kartkówka', 'test', 'sprawdzian'));
                  IF sukces = TRUE THEN
                    SET k = k + 1;
                  END IF;
                END WHILE ;
              END WHILE;

            END LOOP;
        END BLOCK2;
        IF semestr_ = 1 THEN
          SET semestr_ = 2;
          SET rok = rok + 1;
        ELSE
          SET semestr_ = 1;
        END IF;
      END WHILE;
    END LOOP;
  CLOSE index_uczen_klasa;
END BLOCK1;

CALL generuj_oceny();

DROP PROCEDURE IF EXISTS generuj_oceny_na_semestr;
CREATE PROCEDURE generuj_oceny_na_semestr(semestr_ char(4))
BLOCK1 : BEGIN
  DECLARE rok int;
  DECLARE kurs int;
  DECLARE sukces boolean DEFAULT TRUE;

  DECLARE psl char(11);
  DECLARE klasa char(4);
  DECLARE data_oceny date;
  DECLARE wartosc_oc varchar(2);
  DECLARE waga_oc int;

  DECLARE done int DEFAULT FALSE;
  DECLARE bad_data CONDITION FOR 30001;
  DECLARE index_uczen_klasa CURSOR FOR (SELECT id_ucznia,id_klasy FROM klasa_uczniowie);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  DECLARE CONTINUE HANDLER FOR bad_data SET sukces = FALSE;
  OPEN index_uczen_klasa;
  read_loop:
    LOOP
      FETCH index_uczen_klasa INTO psl,klasa;
      IF done THEN
        LEAVE read_loop;
      END IF;
      SET rok = cast(substring(semestr_, 1, 2) AS int);
      IF rok >= cast(substring(klasa, 1, 2) AS int) THEN
        BLOCK2 : BEGIN
          DECLARE liczba_ocen int;
          DECLARE k int;
          DECLARE done2 int DEFAULT FALSE;
          DECLARE index_kurs CURSOR FOR
            (SELECT DISTINCT id_kursu FROM zajecia JOIN klasa_uczniowie ON zajecia.id_klasy = klasa_uczniowie.id_klasy WHERE id_ucznia LIKE psl AND semestr LIKE semestr_);
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = 1;
          OPEN index_kurs;
          loop_2:
            LOOP
              FETCH index_kurs INTO kurs;
              IF done2 THEN
                LEAVE loop_2;
              END IF;

              SET k = 0;
              SET liczba_ocen = floor(rand()*5) + 5;
              WHILE k < liczba_ocen DO
                  SET wartosc_oc = elt(floor(rand()*14)+1, '1', '2-', '2', '2+', '3-', '3', '3+', '4-', '4', '4+', '5-', '5', '5+', '6');
                  SET waga_oc = elt(floor(rand()*5)+1, 1,2,3,4,5);
                  IF substring(semestr_,4,1) = '1' THEN
                    SET data_oceny = losowa_data_miedzy(concat('20',rok, '-09-01'), concat('20', rok+1, '-01-30'));
                  ELSE
                    SET data_oceny = losowa_data_miedzy(concat('20',rok,'-02-01'), concat('20',rok,'-06-30'));
                  END IF;
                  INSERT INTO oceny (id_ucznia, id_kursu, data, semestr, typ, wartosc, waga, opis)
                  VALUES (psl, kurs, data_oceny, semestr_, 'cząstkowa', wartosc_oc, waga_oc, elt(waga_oc, 'praca domowa', 'odpowiedź', 'kartkówka', 'test', 'sprawdzian'));
                    SET k = k + 1;
              END WHILE;

            END LOOP;
        END BLOCK2;
      END IF ;
    END LOOP;
  CLOSE index_uczen_klasa;
END BLOCK1;


CALL generuj_oceny_na_semestr('11/1');
CALL generuj_oceny_na_semestr('12/2');
CALL generuj_oceny_na_semestr('12/1');
CALL generuj_oceny_na_semestr('13/2');
CALL generuj_oceny_na_semestr('13/1');
CALL generuj_oceny_na_semestr('14/2');
CALL generuj_oceny_na_semestr('14/1');
CALL generuj_oceny_na_semestr('15/2');
CALL generuj_oceny_na_semestr('15/1');
CALL generuj_oceny_na_semestr('16/2');
CALL generuj_oceny_na_semestr('16/1');
CALL generuj_oceny_na_semestr('17/2');
CALL generuj_oceny_na_semestr('17/1');
CALL generuj_oceny_na_semestr('18/2');
CALL generuj_oceny_na_semestr('18/1');

SELECT (substring('11/2', 4,1) LIKE '2');

SELECT DISTINCT id_klasy FROM oceny JOIN klasa_uczniowie ON oceny.id_ucznia = klasa_uczniowie.id_ucznia;
SELECT DISTINCT id_ucznia FROM oceny;
DELETE FROM oceny WHERE semestr LIKE '11/1';

SELECT @max_lo, @max_k, @ucz, @c;

SELECT DISTINCT id_kursu FROM zajecia JOIN klasa_uczniowie ON zajecia.id_klasy = klasa_uczniowie.id_klasy WHERE id_ucznia LIKE '05020754432' AND semestr LIKE '18/1';

SELECT id_ucznia, count(DISTINCT id_kursu) as ile
FROM zajecia JOIN klasa_uczniowie ON zajecia.id_klasy = klasa_uczniowie.id_klasy WHERE semestr LIKE '11/1' GROUP BY id_ucznia ORDER BY ile desc ;

SELECT id_klasy, count(DISTINCT id_kursu) as ile FROM zajecia WHERE semestr LIKE '11/1' GROUP BY id_klasy ORDER BY ile desc;
SELECT liczebnosc FROM klasy WHERE id_klasy LIKE '11%';

SELECT id_ucznia,count( wartosc) FROM oceny WHERE semestr LIKE '11/1' GROUP BY id_ucznia;
SELECT id_klasy, count( DISTINCT id_kursu) FROM zajecia WHERE semestr LIKE '11/1' GROUP BY id_klasy;
SELECT id_klasy, zajecia.id_kursu, nazwa FROM zajecia JOIN kursy k ON zajecia.id_kursu = k.id_kursu JOIN przedmioty p ON k.id_przedmiotu = p.id_przedmiotu WHERE semestr LIKE '11/1' AND id_klasy = '11/A' GROUP BY id_klasy, k.id_kursu;

DELETE FROM oceny;

ALTER TABLE oceny
  AUTO_INCREMENT = 1;