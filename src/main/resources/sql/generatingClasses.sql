DROP PROCEDURE IF EXISTS generuj_klasy;
CREATE PROCEDURE generuj_klasy ()
BEGIN
	DECLARE i int DEFAULT 1;
	DECLARE rocznik int DEFAULT year(curdate()) - 8 - 2000;
	DECLARE kod int DEFAULT 1;

	DECLARE bad_data CONDITION FOR 30001;
	DECLARE CONTINUE HANDLER FOR bad_data
	  BEGIN
			SET i = i - 1;
			SET kod = kod - 1;
		END;

	WHILE i <= 24 DO
		INSERT INTO klasy (id_klasy, liczebnosc, wychowawca, sala)
		VALUES (CONCAT(rocznik,'/', elt(kod, 'A', 'B', 'C')),
		        0,
            (SELECT pesel FROM nauczyciele ORDER BY rand() LIMIT 1),
            (SELECT nr_sali FROM sale ORDER BY rand() LIMIT 1));
		SET i = i + 1;
	  SET kod = kod + 1;
	  IF kod = 4 THEN
      SET kod = 1;
      SET rocznik = rocznik + 1;
    END IF;
	END WHILE ;
END;

CALL generuj_klasy();


DROP PROCEDURE IF EXISTS generuj_kursy;
CREATE PROCEDURE generuj_kursy ()
BEGIN
	DECLARE i int DEFAULT 1;

	DECLARE bad_data CONDITION FOR 30001;
	DECLARE CONTINUE HANDLER FOR bad_data SET i = i - 1;

	WHILE i <= 48 DO
		INSERT INTO kursy (id_nauczyciela, id_przedmiotu)
		VALUES ((SELECT pesel FROM nauczyciele ORDER BY rand() LIMIT 1),
            (SELECT id_przedmiotu FROM przedmioty ORDER BY rand() LIMIT 1));
		SET i = i + 1;
	END WHILE ;
END;

CALL generuj_kursy();

SELECT id_przedmiotu, count(id_nauczyciela) as ile FROM kursy GROUP BY id_przedmiotu ORDER BY ile desc;
SELECT id_nauczyciela, count(id_przedmiotu) as ile FROM kursy GROUP BY  id_nauczyciela ORDER BY ile DESC;

SELECT imie, nazwisko, group_concat(nazwa) as nauczane_przedmioty
FROM kursy JOIN przedmioty p ON kursy.id_przedmiotu = p.id_przedmiotu  JOIN nauczyciele n ON kursy.id_nauczyciela = n.pesel
GROUP BY id_nauczyciela;