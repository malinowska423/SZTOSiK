DROP PROCEDURE IF EXISTS generuj_oceny_semestralne;
CREATE PROCEDURE generuj_oceny_semestralne()
BLOCK1 : BEGIN
  DECLARE rok int;
  DECLARE semestr_ int DEFAULT 1;
  DECLARE kurs int;

  DECLARE psl char(11);
  DECLARE klasa char(4);
  DECLARE data_oceny date;
  DECLARE wartosc_oc varchar(2);
  DECLARE waga_oc int;

  DECLARE done int DEFAULT FALSE;
  DECLARE bad_data CONDITION FOR 30001;
  DECLARE index_uczen_klasa CURSOR FOR (SELECT id_ucznia,id_klasy FROM klasa_uczniowie);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
  DECLARE CONTINUE HANDLER FOR bad_data ROLLBACK ;
  SET AUTOCOMMIT = 0;
  START TRANSACTION ;
  OPEN index_uczen_klasa;
  read_loop:
    LOOP
      FETCH index_uczen_klasa INTO psl,klasa;
      IF done THEN
        LEAVE read_loop;
      END IF;
      SET rok = cast(substring(klasa, 1, 2) AS int);
      SET semestr_ = 1;
      WHILE rok < 19 DO

      BLOCK2 : BEGIN
        DECLARE typ_oc varchar(10);
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
            SET waga_oc = 0;
            IF semestr_ = 1 THEN
              SET data_oceny = concat('20', rok+1, '-01-25');
              SET wartosc_oc = (SELECT ocena_semestralna(sum(wartosc_oceny(wartosc)*waga)/sum(waga))
                               FROM oceny
                               WHERE id_ucznia = psl AND semestr LIKE concat(rok, '/', semestr_)
                                AND typ LIKE 'cząstkowa' AND id_kursu = kurs GROUP BY id_kursu);
              SET typ_oc = 'sem';
            ELSE
              SET data_oceny = concat('20',rok,'-06-30');
              SET wartosc_oc = (SELECT ocena_roczna(sum(wartosc_oceny(wartosc)*waga)/sum(waga))
                                FROM oceny
                                WHERE id_ucznia = psl AND (semestr LIKE concat(rok, '/', semestr_) OR semestr LIKE concat(rok-1, '/1'))
                                  AND typ LIKE 'cząstkowa' AND id_kursu = kurs GROUP BY id_kursu);
              SET typ_oc = 'rocz';
            END IF;
            INSERT INTO oceny (id_ucznia, id_kursu, data, semestr, typ, wartosc, waga, opis)
            VALUES (psl, kurs, data_oceny, concat(rok, '/', semestr_), typ_oc, wartosc_oc, waga_oc, concat('ocena ', typ_oc));
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
  COMMIT ;
END BLOCK1;

CALL generuj_oceny_semestralne();

DELETE FROM oceny WHERE typ LIKE 'rocz' OR typ LIKE 'sem';