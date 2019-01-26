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
    IF NEW.nazwisko IN (SELECT nazwisko FROM nauczyciele WHERE imie LIKE NEW.imie) THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Taki nauczyciel już tu pracuje';
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
#     DELETE FROM oceny WHERE id_kursu = (SELECT id_kursu FROM kursy WHERE id_nauczyciela = OLD.pesel);
    DELETE FROM kursy WHERE id_nauczyciela = OLD.pesel;
  END;

# DROP TRIGGER IF EXISTS nauczyciele_after_delete;
# CREATE TRIGGER nauczyciele_after_delete
#   AFTER DELETE ON nauczyciele
#   FOR EACH ROW
#   BEGIN
#   END;


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
    IF NEW.nr_lekcji < 0 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt mały numer lekcji';
    END IF;
    IF (SELECT count(nr_lekcji) FROM dzwonki) > 10 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt wiele lekcji';
    END IF;
    IF timediff(NEW.koniec, NEW.poczatek) < '00:45:00' THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt krótka lekcja';
    END IF;
    IF NEW.nr_lekcji > 1 AND timediff(NEW.poczatek, (SELECT koniec FROM dzwonki WHERE nr_lekcji = NEW.nr_lekcji - 1)) < '00:05:00' THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt krotka przerwa';
    END IF;

  END;

DROP TRIGGER IF EXISTS dzwonki_update;
CREATE TRIGGER dzwonki_update
  BEFORE UPDATE ON dzwonki
  FOR EACH ROW
  BEGIN
    IF NEW.nr_lekcji > 10 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt duży numer lekcji';
    END IF;
    IF (SELECT count(nr_lekcji) FROM dzwonki) > 10 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt wiele lekcji';
    END IF;
    IF timediff(NEW.koniec, NEW.poczatek) < '00:45:00' THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt krótka lekcja';
    END IF;
    IF NEW.nr_lekcji > 1 AND timediff(NEW.poczatek, (SELECT koniec FROM dzwonki WHERE nr_lekcji = NEW.nr_lekcji - 1)) < '00:05:00' THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt krotka przerwa';
    END IF;

  END;

# kursy

DROP TRIGGER IF EXISTS kursy_insert;
CREATE TRIGGER kursy_insert
  BEFORE INSERT ON kursy
  FOR EACH ROW
  BEGIN
    IF (SELECT id_kursu FROM kursy WHERE id_nauczyciela = NEW.id_nauczyciela AND id_przedmiotu = NEW.id_przedmiotu) IS NOT NULL THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Taki kurs już istnieje';
    END IF;
    IF (SELECT count(id_przedmiotu) FROM kursy WHERE id_nauczyciela = NEW.id_nauczyciela) > 2 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt wiele kursów tego nauczyciela';
    END IF;
    IF (SELECT count(id_nauczyciela) FROM kursy WHERE id_przedmiotu = NEW.id_przedmiotu) > 3 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zbyt wiele kursów tego przedmiotu';
    END IF;
  END;

DROP TRIGGER IF EXISTS kursy_delete;
CREATE TRIGGER kursy_delete
  BEFORE DELETE ON kursy
  FOR EACH ROW
  BEGIN
    DELETE FROM oceny WHERE id_kursu = OLD.id_kursu;
  END;

#uczniowie

DROP TRIGGER IF EXISTS uczniowie_insert;
CREATE TRIGGER uczniowie_insert
  BEFORE INSERT ON uczniowie
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
	     OR (  @newpsl IN (SELECT pesel FROM uczniowie)) THEN
		    SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowy numer PESEL';
	  END IF;
# 	  weryfikacja daty urodzenia z peselem
    IF (cast(substring(@newpsl,1,2) AS int) <> year(NEW.data_urodzenia)-1900
      OR cast(substring(@newpsl,3,2) AS int) <> month(NEW.data_urodzenia)
      OR cast(substring(@newpsl,5,2) AS int) <> day(NEW.data_urodzenia)) THEN
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowa data urodzenia lub PESEL';
    END IF;
#     weryfikacja numeru telefonu
    IF NEW.tel_do_rodzica1 < 100000000 OR NEW.tel_do_rodzica1 > 999999999 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowy numer telefonu do rodzica 1';
    END IF;
    IF NEW.tel_do_rodzica2 IS NOT NULL AND (NEW.tel_do_rodzica2 < 100000000 OR NEW.tel_do_rodzica2 > 999999999) THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowy numer telefonu do rodzica 2';
    END IF;

  END;


DROP TRIGGER IF EXISTS uczniowie_update;
CREATE TRIGGER uczniowie_update
  BEFORE UPDATE ON uczniowie
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
	     OR ( @newpsl <> OLD.pesel AND @newpsl IN (SELECT pesel FROM uczniowie)) THEN
		    SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowy numer PESEL';
	  END IF;
# 	  weryfikacja daty urodzenia z peselem
    IF (cast(substring(@newpsl,1,2) AS int) <> year(NEW.data_urodzenia)-1900
      OR cast(substring(@newpsl,3,2) AS int) <> month(NEW.data_urodzenia)
      OR cast(substring(@newpsl,5,2) AS int) <> day(NEW.data_urodzenia)) THEN
        SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowa data urodzenia lub PESEL';
    END IF;
#     weryfikacja numeru telefonu
    IF NEW.tel_do_rodzica1 < 100000000 OR NEW.tel_do_rodzica1 > 999999999 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowy numer telefonu do rodzica 1';
    END IF;
    IF NEW.tel_do_rodzica2 IS NOT NULL AND (NEW.tel_do_rodzica2 < 100000000 OR NEW.tel_do_rodzica2 > 999999999) THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidlowy numer telefonu do rodzica 2';
    END IF;

  END;

DROP TRIGGER IF EXISTS uczniowie_delete;
CREATE TRIGGER uczniowie_delete
  AFTER DELETE ON uczniowie
  FOR EACH ROW
  BEGIN
    SET @id_klasy = (SELECT id_klasy FROM klasa_uczniowie WHERE id_ucznia = OLD.pesel);
#     SET AUTOCOMMIT = 0;
#     START TRANSACTION;
#       UPDATE klasy SET liczebnosc = liczebnosc - 1 WHERE id_klasy = @id_klasy;
      DELETE FROM oceny WHERE OLD.pesel = id_ucznia;
      DELETE FROM klasa_uczniowie WHERE id_ucznia = OLD.pesel;
#     COMMIT;
  END;


# klasy

DROP TRIGGER IF EXISTS klasy_insert;
CREATE TRIGGER klasy_insert
  BEFORE INSERT ON klasy
  FOR EACH ROW
  BEGIN
    IF NEW.liczebnosc > 36 OR NEW.liczebnosc < 0 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidłowa liczba osób w klasie';
    END IF;
    IF NEW.wychowawca IN (SELECT wychowawca FROM klasy) THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Ten nauczyciel jest już wychowawcą';
    END IF;
    IF NEW.sala IN (SELECT sala FROM klasy) THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Ta sala jest już przypisana do innej klasy';
    END IF;
  END;


DROP TRIGGER IF EXISTS klasy_update;
CREATE TRIGGER klasy_update
  BEFORE UPDATE ON klasy
  FOR EACH ROW
  BEGIN
    IF NEW.liczebnosc > 36 OR NEW.liczebnosc < 0 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidłowa liczba osób w klasie';
    END IF;
    IF NEW.wychowawca IN (SELECT wychowawca FROM klasy) THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Ten nauczyciel jest już wychowawcą';
    END IF;
    IF NEW.sala IN (SELECT sala FROM klasy) THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Ta sala jest już przypisana do innej klasy';
    END IF;
  END;


DROP TRIGGER IF EXISTS klasy_delete;
CREATE TRIGGER klasy_delete
  AFTER DELETE ON klasy
  FOR EACH ROW
  BEGIN
#     SET AUTOCOMMIT = 0;
#     START TRANSACTION ;

    DELETE FROM zajecia WHERE id_klasy = OLD.id_klasy;
    DELETE FROM klasa_uczniowie WHERE id_klasy = OLD.id_klasy;
#     COMMIT ;
  END;


# klasy uczniowie

DROP TRIGGER IF EXISTS ku_before_insert;
CREATE TRIGGER ku_before_insert
  BEFORE INSERT ON klasa_uczniowie
  FOR EACH ROW
  BEGIN
    IF NEW.id_ucznia IN (SELECT id_ucznia FROM klasa_uczniowie) THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Ten uczeń należy już do jakiejś klasy';
    END IF;
  END;

DROP TRIGGER IF EXISTS ku_after_insert;
CREATE TRIGGER ku_after_insert
  AFTER INSERT ON klasa_uczniowie
  FOR EACH ROW UPDATE klasy SET liczebnosc = liczebnosc + 1 WHERE id_klasy = NEW.id_klasy;




DROP TRIGGER IF EXISTS ku_update;
CREATE TRIGGER ku_update
  AFTER UPDATE ON klasa_uczniowie
  FOR EACH ROW
  BEGIN
    UPDATE klasy SET liczebnosc = liczebnosc + 1 WHERE id_klasy = NEW.id_klasy;
    UPDATE klasy SET liczebnosc = liczebnosc - 1 WHERE id_klasy = OLD.id_klasy;
  END;

DROP TRIGGER IF EXISTS ku_delete;
CREATE TRIGGER ku_delete
  AFTER DELETE on klasa_uczniowie
  FOR EACH ROW
  BEGIN
    UPDATE klasy SET liczebnosc = liczebnosc - 1 WHERE id_klasy = OLD.id_klasy;
    IF (SELECT * FROM klasa_uczniowie WHERE id_klasy = OLD.id_klasy) IS NULL THEN
      DELETE FROM klasy WHERE klasy.id_klasy = OLD.id_klasy;
    END IF;
  END;


# oceny

DROP TRIGGER IF EXISTS oceny_insert;
CREATE TRIGGER oceny_insert
  BEFORE INSERT ON oceny
  FOR EACH ROW
  BEGIN
    IF NEW.data > now() THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Ocena nie może zostać dodana w przyszłości';
    END IF;
    IF NEW.waga < 0 OR NEW.waga > 5 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidłowa waga oceny';
    END IF;
  END;

DROP TRIGGER IF EXISTS oceny_update;
CREATE TRIGGER oceny_update
  BEFORE UPDATE ON oceny
  FOR EACH ROW
  BEGIN
    IF NEW.data > now() THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Ocena nie może zostać dodana w przyszłości';
    END IF;
    IF NEW.waga < 0 OR NEW.waga > 5 THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Nieprawidłowa waga oceny';
    END IF;
  END;


# zajęcia

DROP TRIGGER IF EXISTS zajecia_insert;
CREATE TRIGGER zajecia_insert
  BEFORE INSERT ON zajecia
  FOR EACH ROW
  BEGIN
    IF (SELECT * FROM zajecia WHERE semestr = NEW.semestr
                                AND dzien_tygodnia = NEW.dzien_tygodnia
                                AND nr_lekcji = NEW.nr_lekcji
                                AND (id_klasy = NEW.id_klasy OR id_sali = NEW.id_sali OR id_kursu = NEW.id_kursu)) IS NOT NULL THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zajęcia w tym czasie już istnieją';
    END IF;
  END;


DROP TRIGGER IF EXISTS zajecia_update;
CREATE TRIGGER zajecia_update
  BEFORE UPDATE ON zajecia
  FOR EACH ROW
  BEGIN
    IF (SELECT * FROM zajecia WHERE semestr = NEW.semestr
                                AND dzien_tygodnia = NEW.dzien_tygodnia
                                AND nr_lekcji = NEW.nr_lekcji
                                AND (id_klasy = NEW.id_klasy OR id_sali = NEW.id_sali OR id_kursu = NEW.id_kursu)) IS NOT NULL THEN
      SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO=30001, MESSAGE_TEXT='Zajęcia w tym czasie już istnieją';
    END IF;
  END;

