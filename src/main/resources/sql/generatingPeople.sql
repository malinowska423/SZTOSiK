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

DROP PROCEDURE IF EXISTS generuj_uczniow;
CREATE PROCEDURE generuj_uczniow ()
BEGIN
	DECLARE i int DEFAULT 1;
	DECLARE urodziny date;
	DECLARE psl char(11);
	DECLARE max int;
	DECLARE klasa char(4);
	DECLARE pojemnosci_sali int;
	DECLARE sukces boolean DEFAULT TRUE;
	DECLARE done INT DEFAULT FALSE;
  DECLARE bad_data CONDITION FOR 30001;
  DECLARE index_klasa CURSOR FOR
  (SELECT id_klasy, pojemnosc FROM klasy JOIN sale s ON klasy.sala = s.nr_sali);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	DECLARE CONTINUE HANDLER FOR bad_data SET sukces = FALSE;
# 	SET AUTOCOMMIT = 0;
# 	START TRANSACTION ;
  OPEN index_klasa;
    read_loop: LOOP
      FETCH index_klasa INTO klasa, pojemnosci_sali;
      IF done THEN
        LEAVE read_loop;
      END IF;
      SET max = floor(rand()*10)+(pojemnosci_sali - 10);
      SET i = 0;
      WHILE i < max DO
        SET urodziny = losowa_data_urodzin((year(curdate())-2000) - cast(substring(klasa,1,2) AS int) + 6);
        SET psl = CONCAT(RIGHT(DATE_FORMAT(urodziny, '%Y%m%d'),6), FLOOR(RAND()*89999+10000));
        SET sukces = TRUE;
        INSERT INTO uczniowie (pesel, imie, nazwisko, data_urodzenia, adres, tel_do_rodzica1, tel_do_rodzica2)
        VALUES (CONCAT(RIGHT(DATE_FORMAT(urodziny, '%Y%m%d'),6), FLOOR(RAND()*89999+10000)),
                elt(floor(rand()*100) + 1, 'Anna', 'Maria', 'Katarzyna', 'Małgorzata', 'Agnieszka', 'Krystyna', 'Barbara', 'Ewa', 'Elżbieta', 'Zofia', 'Janina', 'Teresa', 'Joanna', 'Magdalena', 'Monika', 'Jadwiga', 'Danuta', 'Irena', 'Halina', 'Helena', 'Beata', 'Aleksandra', 'Marta', 'Dorota', 'Marianna', 'Grażyna', 'Jolanta', 'Stanisława', 'Iwona', 'Karolina', 'Bożena', 'Urszula', 'Justyna', 'Renata', 'Alicja', 'Paulina', 'Sylwia', 'Natalia', 'Wanda', 'Agata', 'Aneta', 'Izabela', 'Ewelina', 'Marzena', 'Wiesława', 'Genowefa', 'Patrycja', 'Kazimiera', 'Edyta', 'Stefania', 'Jan', 'Andrzej', 'Piotr', 'Krzysztof', 'Stanisław', 'Tomasz', 'Paweł', 'Józef', 'Marcin', 'Marek', 'Michał', 'Grzegorz', 'Jerzy', 'Tadeusz', 'Adam', 'Łukasz', 'Zbigniew', 'Ryszard', 'Dariusz', 'Henryk', 'Mariusz', 'Kazimierz', 'Wojciech', 'Robert', 'Mateusz', 'Marian', 'Rafał', 'Jacek', 'Janusz', 'Mirosław', 'Maciej', 'Sławomir', 'Jarosław', 'Kamil', 'Wiesław', 'Roman', 'Władysław', 'Jakub', 'Artur', 'Zdzisław', 'Edward', 'Mieczysław', 'Damian', 'Dawid', 'Przemysław', 'Sebastian', 'Czesław', 'Leszek', 'Daniel', 'Waldemar'),
                elt(floor(rand()*100) + 1, 'Karcz', 'Mrozik', 'Wierzbicki', 'Zioło', 'Przybyła', 'Dziekoński', 'Surowiec', 'Żarski', 'Antkiewicz', 'Mateja', 'Reczek', 'Klimowicz', 'Małkowski', 'Fijał', 'Kluski', 'Buczak', 'Piontek', 'Synowiec', 'Karczewski', 'Kędziora', 'Kielak', 'Bargiel', 'Łagowski', 'Kądziela', 'Jurecki', 'Pindel', 'Basiński', 'Dąbrowa', 'Zborowski', 'Just', 'Pietroń', 'Smołka', 'Lenartowicz', 'Małolepszy', 'Pieniak', 'Binkowski', 'Kuliński', 'Wojtaś', 'Jakimiuk', 'Rogoziński', 'Zapart', 'Byczkowski', 'Żmuda', 'Filipiuk', 'Ambroży', 'Pajewski', 'Ferenc', 'Schneider', 'Kopyciński', 'Siembida', 'Kozielski', 'Sykuła', 'Migdalski', 'Taras', 'Burzyński', 'Gnat', 'Bączyk', 'Staniewski', 'Roszczyk', 'Fudali', 'Lenczewski', 'Ratajski', 'Maćkiewicz', 'Cichoń', 'Romanowicz', 'Franek', 'Wronowski', 'Polański', 'Bocheński', 'Skorek', 'Bielak', 'Janczak', 'Jankowski', 'Grzybek', 'Napieraj', 'Łukaszyk', 'Koza', 'Papierz', 'Seweryn', 'Mroczek', 'Szczęsna', 'Kuźma', 'Czapka', 'Kukułka', 'Drozdowski', 'Pawluczuk', 'Strzałkowski', 'Miarka', 'Cabaj', 'Kałużyński', 'Młynarczyk', 'Schulz', 'Lemański', 'Hadryś', 'Bandurski', 'Chojnacki', 'Szymoniak', 'Harasim', 'Czyżewski', 'Mrzygłód'),
                urodziny,
                concat('ul. Uczniowska ' , (floor(rand()*1000) + 1) , ', Wrocław'),
                (FLOOR(RAND()*999999999)+100000000),
                (FLOOR(RAND()*999999999)+100000000));
        IF sukces = TRUE THEN
#           INSERT INTO klasa_uczniowie (id_klasy, id_ucznia) VALUES (klasa, psl);
          SET i = i + 1;
        END IF;
      END WHILE;
    END LOOP;
  CLOSE index_klasa;
#   COMMIT ;
END;


CALL generuj_uczniow();

DROP PROCEDURE IF EXISTS tiara_przydzialu;
CREATE PROCEDURE tiara_przydzialu ()
BEGIN
	DECLARE psl char(11);
	DECLARE klasa char(4);
	DECLARE sukces boolean DEFAULT TRUE;
	DECLARE done INT DEFAULT FALSE;
  DECLARE bad_data CONDITION FOR 30001;
  DECLARE index_uczen CURSOR FOR (SELECT pesel FROM uczniowie);
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	DECLARE CONTINUE HANDLER FOR bad_data SET sukces = FALSE;
  OPEN index_uczen;
    read_loop: LOOP
      FETCH index_uczen INTO psl;
      IF done THEN
        LEAVE read_loop;
      END IF;
      SET sukces = FALSE;
      WHILE sukces = FALSE DO
        SET sukces = TRUE;
      SET klasa = concat(cast(substring(psl,1,2) AS int) + 6, '/', elt(floor(rand()*3) + 1, 'A', 'B', 'C'));
        INSERT INTO klasa_uczniowie (id_klasy, id_ucznia) VALUES (klasa, psl);
      END WHILE ;
    END LOOP;
  CLOSE index_uczen;
END;

CALL tiara_przydzialu();