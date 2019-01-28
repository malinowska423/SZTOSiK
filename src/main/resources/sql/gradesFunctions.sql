DROP FUNCTION IF EXISTS wartosc_oceny;
CREATE FUNCTION wartosc_oceny( ocena varchar(2))
RETURNS double
BEGIN
  IF ocena LIKE '1' OR
     ocena LIKE '2' OR
     ocena LIKE '3' OR
     ocena LIKE '4' OR
     ocena LIKE '5' OR
     ocena LIKE '6' THEN
    RETURN cast(ocena AS double);
    ELSE IF substring(ocena,2,1) LIKE '-' THEN
      RETURN cast(substring(ocena,1,1) AS double) - 0.25;
      ELSE
      RETURN cast(substring(ocena,1,1) AS double) + 0.5;
    END IF;
  END IF;
END;

DROP FUNCTION IF EXISTS ocena_semestralna;
CREATE FUNCTION ocena_semestralna( ocena double)
RETURNS varchar(2)
BEGIN
  IF ocena BETWEEN 0 AND 1.8 THEN
    RETURN '1';
  END IF;
  IF ocena < 2 THEN
    RETURN '2-';
  END IF;
  IF ocena < 2.5 THEN
    RETURN '2';
  END IF;
  IF ocena < 2.75 THEN
    RETURN '2+';
  END IF;
  IF ocena < 3.0 THEN
    RETURN '3-';
  END IF;
  IF ocena < 3.5 THEN
    RETURN '3';
  END IF;
  IF ocena < 3.75 THEN
    RETURN '3+';
  END IF;
  IF ocena < 4.0 THEN
    RETURN '4-';
  END IF;
  IF ocena < 4.5 THEN
    RETURN '4';
  END IF;
  IF ocena < 4.75 THEN
    RETURN '4+';
  END IF;
  IF ocena < 5.0 THEN
    RETURN '5-';
  END IF;
  IF ocena < 5.5 THEN
    RETURN '5';
  END IF;
  IF ocena < 5.9 THEN
    RETURN '5+';
  END IF;
  IF ocena <= 6.0 THEN
    RETURN '6';
  END IF;
END;


DROP FUNCTION IF EXISTS ocena_roczna;
CREATE FUNCTION ocena_roczna( ocena double)
  RETURNS varchar(2)
BEGIN
  IF ocena BETWEEN 0 AND 1.99999 THEN
    RETURN '1';
  END IF;
  IF ocena < 2.5 THEN
    RETURN '2';
  END IF;
  IF ocena < 3.5 THEN
    RETURN '3';
  END IF;
  IF ocena < 4.5 THEN
    RETURN '4';
  END IF;
  IF ocena < 5.8 THEN
    RETURN '5';
  END IF;
  IF ocena <= 6.0 THEN
    RETURN '6';
  END IF;
END;
