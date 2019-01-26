DROP FUNCTION IF EXISTS losowa_data_urodzin;
CREATE FUNCTION losowa_data_urodzin (wiek int)
RETURNS date
BEGIN
  DECLARE data date;
  SET data = date_sub(curdate(), INTERVAL (wiek*365 - floor(rand()*365)) DAY );
  RETURN data;
END;

DROP PROCEDURE IF EXISTS generuj_nauczycieli;
CREATE PROCEDURE generuj_nauczycieli ()
BEGIN
	DECLARE i int DEFAULT 1;
	DECLARE urodziny date;

	DECLARE bad_data CONDITION FOR 30001;
	DECLARE CONTINUE HANDLER FOR bad_data SET i = i - 1;

	WHILE i <= 20 DO
	  SET urodziny = losowa_data_urodzin(floor(rand()*40)+20);
		INSERT INTO nauczyciele (pesel, imie, nazwisko, data_urodzenia, adres, nr_kontaktowy)
		VALUES (CONCAT(RIGHT(DATE_FORMAT(urodziny, '%Y%m%d'),6), FLOOR(RAND()*89999+10000)),
						elt(floor(rand()*6) + 1, 'Antoni', 'Jakub', 'Jan', 'Zuzanna', 'Julia', 'Zofia'),
						elt(floor(rand()*5) + 1, 'Nowak', 'Wójcik', 'Kowalczyk', 'Woźniak', 'Mazur'),
		        urodziny,
		        concat('ul. Szkolna ' , (floor(rand()*100) + 1) , ', Wrocław'),
						(FLOOR(RAND()*999999999)+100000000));
		set i = i + 1;
	end while;
END;

CALL generuj_nauczycieli();

# DROP PROCEDURE IF EXISTS generuj_uczniow;
# CREATE PROCEDURE generuj_uczniow ()
# BEGIN
# 	DECLARE i int DEFAULT 1;
# 	DECLARE urodziny date;
#
# 	DECLARE bad_data CONDITION FOR 30001;
# 	DECLARE CONTINUE HANDLER FOR bad_data SET i = i - 1;
#
# 	WHILE i <= 20 DO
# 	  SET urodziny = losowa_data_urodzin(floor(rand()*40)+20);
# 		INSERT INTO nauczyciele (pesel, imie, nazwisko, data_urodzenia, adres, nr_kontaktowy)
# 		VALUES (CONCAT(RIGHT(DATE_FORMAT(urodziny, '%Y%m%d'),6), FLOOR(RAND()*89999+10000)),
# 						elt(floor(rand()*6) + 1, 'Antoni', 'Jakub', 'Jan', 'Zuzanna', 'Julia', 'Zofia'),
# 						elt(floor(rand()*5) + 1, 'Nowak', 'Wójcik', 'Kowalczyk', 'Woźniak', 'Mazur'),
# 		        urodziny,
# 		        concat('ul. Szkolna ' , (floor(rand()*100) + 1) , ', Wrocław'),
# 						(FLOOR(RAND()*999999999)+100000000));
# 		set i = i + 1;
# 	end while;
# END;
#
#
# CALL generuj_uczniow();

