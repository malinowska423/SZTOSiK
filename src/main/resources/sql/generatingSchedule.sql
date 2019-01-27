DROP PROCEDURE IF EXISTS generuj_plan;
CREATE PROCEDURE generuj_plan ()
BEGIN
  DECLARE dzien int DEFAULT 1;
  DECLARE lekcja int DEFAULT 0;
  DECLARE rok int;
  DECLARE semestr_ int DEFAULT 1;
  DECLARE kurs int;
  DECLARE sala int;
	DECLARE klasa char(4);
	DECLARE max_lekcji int;
	DECLARE sukces boolean DEFAULT TRUE;
	DECLARE done INT DEFAULT FALSE;
  DECLARE bad_data CONDITION FOR 30001;
  DECLARE index_klasa CURSOR FOR (SELECT id_klasy FROM klasy);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	DECLARE CONTINUE HANDLER FOR bad_data SET sukces = FALSE;
  OPEN index_klasa;
    read_loop: LOOP
      FETCH index_klasa INTO klasa;
      IF done THEN
        LEAVE read_loop;
      END IF;
      SET rok = cast(substring(klasa,1,2) AS int);
      SET semestr_ = 1;
      WHILE rok < 19 DO
        SET dzien = 1;
        WHILE dzien < 6 DO
          SET lekcja = 1;
          SET max_lekcji = floor(rand()*3)+5;
          WHILE lekcja <= max_lekcji DO
            SET sukces = FALSE;
            WHILE sukces = FALSE DO
              SET sukces = TRUE;
              SET kurs = (SELECT id_kursu FROM kursy ORDER BY rand() LIMIT 1);
              SET sala = (SELECT nr_sali FROM sale ORDER BY rand() LIMIT 1);
              INSERT INTO zajecia (id_kursu, id_klasy, id_sali, nr_lekcji, dzien_tygodnia, semestr)
              VALUES (kurs, klasa, sala, lekcja, elt(dzien, 'pon', 'wt', 'śr', 'czw', 'pt'), concat(rok, '/', semestr_));
              IF sukces = TRUE THEN
                SET lekcja = lekcja + 1;
              END IF;
            END WHILE ;
          END WHILE;
          SET dzien = dzien + 1;
        END WHILE;
        IF semestr_ = 1 THEN
          SET semestr_ = 2;
          SET rok = rok + 1;
          ELSE
          SET semestr_ = 1;
        END IF;
      END WHILE;
    END LOOP;
  CLOSE index_klasa;
END;

CALL generuj_plan();

# SELECT dzien_tygodnia, nr_lekcji, nazwa, k.id_kursu FROM zajecia JOIN kursy k ON zajecia.id_kursu = k.id_kursu JOIN przedmioty p ON k.id_przedmiotu = p.id_przedmiotu
# WHERE semestr LIKE '18/1' AND id_klasy LIKE '11/A' ORDER BY nazwa;
#
# INSERT INTO zajecia (id_kursu, id_klasy, id_sali, nr_lekcji, dzien_tygodnia, semestr) VALUES (183, '11/A', 1, 0, 'pt', '18/1');
#
# SELECT id_klasy, count(DISTINCT semestr) FROM zajecia GROUP BY id_klasy;
#
# SELECT id_klasy, semestr FROM zajecia WHERE id_klasy LIKE '18/A' GROUP BY semestr;
# DELETE FROM zajecia;
#
# SELECT (SELECT DISTINCT zajecia.id_kursu FROM zajecia JOIN kursy k ON zajecia.id_kursu = k.id_kursu
#                                               JOIN przedmioty p ON k.id_przedmiotu = p.id_przedmiotu
# WHERE semestr = '18/1' AND id_klasy = '11/A' AND nazwa LIKE (SELECT nazwa FROM kursy JOIN przedmioty on kursy.id_przedmiotu = przedmioty.id_przedmiotu WHERE id_kursu = 183)) t;