# nauczyciele

DROP TRIGGER IF EXISTS nauczyciele_insert;
CREATE TRIGGER nauczyciele_insert
  BEFORE INSERT ON nauczyciele
  FOR EACH ROW
  BEGIN
    SET @newpsl = NEW.pesel;
#     weryfikacja numeru pesel
    IF (((CAST(SUBSTRING(@newpsl,1,1) AS int))
			+(CAST(SUBSTRING(@newpsl,2,1) AS int)*3)
			+(CAST(SUBSTRING(@newpsl,3,1) AS int)*7)
			+(CAST(SUBSTRING(@newpsl,4,1) AS int)*9)
			+(CAST(SUBSTRING(@newpsl,5,1) AS int))
			+(CAST(SUBSTRING(@newpsl,6,1) AS int)*3)
			+(CAST(SUBSTRING(@newpsl,7,1) AS int)*7)
			+(CAST(SUBSTRING(@newpsl,8,1) AS int)*9)
			+(CAST(SUBSTRING(@newpsl,9,1) AS int))
			+(CAST(SUBSTRING(@newpsl,10,1) AS int)*3)
			+(CAST(SUBSTRING(@newpsl,11,1) AS int)))%10 <> 0)
	     OR @newpsl IN (SELECT pesel FROM nauczyciele) THEN
		    SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowy numer PESEL';
	  END IF;
# 	  weryfikacja daty urodzenia z peselem
    IF (cast(substring(@newpsl,1,2) AS int) <> year(NEW.data_urodzenia)-1900
      OR cast(substring(@newpsl,3,2) AS int) <> month(NEW.data_urodzenia)
      OR cast(substring(@newpsl,5,2) AS int) <> day(NEW.data_urodzenia)) THEN
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowa data urodzenia lub PESEL';
    END IF;
#     weryfikacja numeru telefonu
    IF NEW.nr_kontaktowy < 100000000 OR NEW.nr_kontaktowy > 999999999 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowy numer telefonu';
    END IF;
  END;

DROP TRIGGER IF EXISTS nauczyciele_update;
CREATE TRIGGER nauczyciele_update
  BEFORE UPDATE ON nauczyciele
  FOR EACH ROW
  BEGIN
    SET @newpsl = NEW.pesel;
#     weryfikacja numeru pesel
    IF (((CAST(SUBSTRING(@newpsl,1,1) AS int))
			+(CAST(SUBSTRING(@newpsl,2,1) AS int)*3)
			+(CAST(SUBSTRING(@newpsl,3,1) AS int)*7)
			+(CAST(SUBSTRING(@newpsl,4,1) AS int)*9)
			+(CAST(SUBSTRING(@newpsl,5,1) AS int))
			+(CAST(SUBSTRING(@newpsl,6,1) AS int)*3)
			+(CAST(SUBSTRING(@newpsl,7,1) AS int)*7)
			+(CAST(SUBSTRING(@newpsl,8,1) AS int)*9)
			+(CAST(SUBSTRING(@newpsl,9,1) AS int))
			+(CAST(SUBSTRING(@newpsl,10,1) AS int)*3)
			+(CAST(SUBSTRING(@newpsl,11,1) AS int)))%10 <> 0)
	     OR ( @newpsl <> OLD.pesel AND @newpsl IN (SELECT pesel FROM nauczyciele)) THEN
		    SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowy numer PESEL';
	  END IF;
# 	  weryfikacja daty urodzenia z peselem
    IF (cast(substring(@newpsl,1,2) AS int) <> year(NEW.data_urodzenia)-1900
      OR cast(substring(@newpsl,3,2) AS int) <> month(NEW.data_urodzenia)
      OR cast(substring(@newpsl,5,2) AS int) <> day(NEW.data_urodzenia)) THEN
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowa data urodzenia lub PESEL';
    END IF;
#     weryfikacja numeru telefonu
    IF NEW.nr_kontaktowy < 100000000 OR NEW.nr_kontaktowy > 999999999 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowy numer telefonu';
    END IF;
  END;

DROP TRIGGER IF EXISTS nauczyciele_before_delete;
CREATE TRIGGER nauczyciele_before_delete
  BEFORE DELETE ON nauczyciele
  FOR EACH ROW
  BEGIN
    IF OLD.pesel IN (SELECT wychowawca FROM klasy) THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Ten nauczyciel jest wychowawcą którejś klasy. Zmień najpierw wychowawcę.';
    END IF;
  END;

DROP TRIGGER IF EXISTS nauczyciele_after_delete;
CREATE TRIGGER nauczyciele_after_delete
  AFTER DELETE ON nauczyciele
  FOR EACH ROW
  BEGIN
    DELETE FROM kursy WHERE id_nauczyciela LIKE OLD.pesel;
  END;


# przedmioty

DROP TRIGGER IF EXISTS przedmioty_delete;
CREATE TRIGGER przedmioty_delete
  AFTER DELETE ON przedmioty
  FOR EACH ROW DELETE FROM kursy WHERE kursy.id_przedmiotu LIKE OLD.id_przedmiotu;

# sale

DROP TRIGGER IF EXISTS sale_insert;
CREATE TRIGGER sale_insert
  BEFORE INSERT ON sale
  FOR EACH ROW
  BEGIN
    IF NEW.pojemnosc < 15 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt mała pojemność sali';
    END IF;
  END;

DROP TRIGGER IF EXISTS sale_update;
CREATE TRIGGER sale_update
  BEFORE UPDATE ON sale
  FOR EACH ROW
  BEGIN
    IF NEW.pojemnosc < 15
      OR NEW.pojemnosc < (SELECT MAX(liczebnosc) FROM zajecia JOIN klasy k ON zajecia.id_klasy = k.id_klasy WHERE id_sali = NEW.nr_sali)
      THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt mała pojemność sali';
    END IF;
  END;



# dzwonki

DROP TRIGGER IF EXISTS dzwonki_insert;
CREATE TRIGGER dzwonki_insert
  BEFORE INSERT ON dzwonki
  FOR EACH ROW
  BEGIN
    IF NEW.nr_lekcji > 10 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt duży numer lekcji';
    END IF;
    IF (SELECT count(nr_lekcji) FROM dzwonki) > 10 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt wiele lekcji';
    END IF;
    IF timediff(NEW.koniec, NEW.poczatek)

  END;


