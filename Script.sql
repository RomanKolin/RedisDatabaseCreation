CREATE TABLE Person(ID serial PRIMARY KEY, nam varchar(10), bday smallint, dday smallint NULL, sex varchar(10) CHECK(sex IN('Male', 'Female')));
CREATE TABLE "Marital status"(ID serial PRIMARY KEY, husb smallint, wif smallint CHECK(husb != wif), mday smallint, endmday smallint NULL, FOREIGN KEY (husb) REFERENCES Person(ID), FOREIGN KEY (wif) REFERENCES Person(ID));
CREATE TABLE Child(ID serial PRIMARY KEY, pers smallint, par smallint, FOREIGN KEY (pers) REFERENCES Person(ID), FOREIGN KEY (par) REFERENCES "Marital status"(ID));
INSERT INTO Person(nam, bday, dday, sex) VALUES('Dmitry', 1932, 1982, 'Male'),
                                                                                          ('Victoria', 1934, 2006, 'Female'),
                                                                                          ('Fedor', 1958, null, 'Male'),
                                                                                          ('Anna', 1967, null, 'Female'),
                                                                                          ('Christina', 1957, 2018, 'Female'),
                                                                                          ('Daniil', 1984, null, 'Male'),
                                                                                          ('Elena', 1986, 2010, 'Female'),
                                                                                          ('Anatoly', 2010, null, 'Male'),
                                                                                          ('Natalia', 1982, null, 'Female'),
                                                                                          ('Georgy', 2012, null, 'Male'),
                                                                                          ('Anton', 1965, null, 'Male'),
                                                                                          ('Boris', 1997, null, 'Male'),
                                                                                          ('Julia', 2000, null, 'Female');     
INSERT INTO "Marital status"(husb, wif, mday, endmday) VALUES(1, 2, 1956, 1982),
                                                                                                                (3, 5, 1981, 2018),
                                                                                                                (6, 7, 2008, 2010),
                                                                                                                (6, 9, 2011, null),
                                                                                                                (11, 4, 1992, null); 
INSERT INTO Child(pers, par) VALUES(3, 1),
                                                                    (6, 2),
                                                                    (8, 3),
                                                                    (10, 4),
                                                                    (4, 1),
                                                                    (12, 5),
                                                                    (13, 5);
                                                                    
SELECT nam AS "Name", bday AS "Birthday" FROM Person ORDER BY bday;
SELECT nam AS "Name", bday AS "Birthday" FROM Person WHERE bday < 1969 ORDER BY bday;
SELECT nam AS "Name" FROM Person WHERE dday IS NULL;
SELECT nam AS "Name", dday-bday AS "Age" FROM Person WHERE dday IS NOT NULL;
SELECT ROUND(AVG(dday-bday)) AS "Average age" FROM Person WHERE dday IS NOT NULL;
SELECT dday AS "Deathday" FROM Person WHERE nam='Christina';
SELECT nam AS "Name", mday-bday AS "Marriage age" FROM Person JOIN "Marital status" ON Person.ID="Marital status".husb UNION SELECT nam AS "Name", mday-bday AS "Marriage age" FROM Person JOIN "Marital status" ON Person.ID="Marital status".wif;
WITH avermarrage AS (SELECT AVG(mday-bday) AS "Average marriage age" FROM Person JOIN "Marital status" ON Person.ID="Marital status".husb UNION SELECT AVG(mday-bday) AS " Average marriage age" FROM Person JOIN "Marital status" ON Person.ID="Marital status".wif)
SELECT ROUND(AVG("Average marriage age")) AS "Average marriage age" FROM avermarrage;
SELECT nam AS "Name" FROM Person JOIN "Marital status" ON Person.ID="Marital status".wif JOIN Child ON "Marital status".ID=Child.par WHERE pers=(SELECT ID FROM Person WHERE nam='Georgy');
SELECT COUNT(Child.ID) AS "Number of children" FROM Child JOIN "Marital status" ON Child.par="Marital status".ID JOIN Person ON "Marital status".husb=Person.ID WHERE "Marital status".husb=(SELECT ID FROM Person WHERE nam='Anton');
CREATE TEMPORARY TABLE maritalstatus(husb smallint, wif smallint, child smallint);
INSERT INTO maritalstatus  SELECT DISTINCT "Marital status".husb, "Marital status".wif, Child.pers FROM Person JOIN "Marital status" ON (Person.ID="Marital status".husb OR Person.ID="Marital status".wif) JOIN Child ON "Marital status".ID=Child.par ORDER BY husb;
WITH wife AS (WITH husband AS (WITH child AS (WITH RECURSIVE ancestor AS (SELECT child, husb, wif FROM maritalstatus WHERE child=(SELECT ID FROM Person WHERE nam='Anatoly') UNION SELECT maritalstatus.child, maritalstatus.husb, maritalstatus.wif FROM maritalstatus JOIN ancestor ON (maritalstatus.child=ancestor.husb OR maritalstatus.child=ancestor.wif)) SELECT * FROM ancestor) SELECT child.child, nam AS "Child", child.husb, child.wif FROM Person JOIN child ON Person.ID=child.child) SELECT husband."Child", nam AS "Husband", husband.wif FROM Person JOIN husband ON Person.ID=husband.husb) SELECT wife."Child", wife."Husband", nam AS "Wife" FROM Person JOIN wife ON Person.ID=wife.wif;
WITH child AS (WITH wife AS (WITH husband AS (WITH RECURSIVE descendant AS (SELECT husb, wif, child FROM maritalstatus WHERE wif=(SELECT ID FROM Person WHERE nam='Victoria') UNION SELECT maritalstatus.husb, maritalstatus.wif, maritalstatus.child FROM maritalstatus JOIN descendant ON (maritalstatus.husb=descendant.child OR maritalstatus.wif=descendant.child)) SELECT * FROM descendant) SELECT husband.husb, nam AS "Husband", husband.wif, husband.child FROM Person JOIN husband ON Person.ID=husband.husb) SELECT wife."Husband", nam AS "Wife", wife.child FROM Person JOIN wife ON Person.ID=wife.wif) SELECT child."Husband", child."Wife", nam AS "Child" FROM Person JOIN child ON Person.ID=child.child;
WITH cousin AS(WITH cousin2 AS (WITH cousin1 AS (WITH cousin AS (SELECT * FROM maritalstatus WHERE child=(SELECT ID FROM Person where nam='Daniil')) SELECT husb, wif, child FROM maritalstatus WHERE child=(SELECT husb FROM cousin)) SELECT child FROM maritalstatus WHERE wif=(SELECT wif FROM cousin1)) SELECT child FROM maritalstatus WHERE wif IN(SELECT child FROM cousin2)) SELECT nam AS "Name" FROM Person JOIN cousin ON Person.ID=cousin.child;
