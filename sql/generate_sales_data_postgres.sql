-- PostgreSQL: create SalesData table and insert 10,000 realistic random rows

-- Create table (CustomerID is SERIAL which is an integer auto-increment)
CREATE TABLE IF NOT EXISTS SalesData (
  CustomerID SERIAL PRIMARY KEY,
  Name VARCHAR(100),
  Age INT,
  City VARCHAR(100),
  PurchaseAmount DECIMAL(10,2),
  PurchaseDate DATE
);

-- Insert 10,000 rows using generate_series and arrays of realistic names/cities
INSERT INTO SalesData (Name, Age, City, PurchaseAmount, PurchaseDate)
SELECT
  ( (array['James','Mary','John','Patricia','Robert','Jennifer','Michael','Linda','William','Elizabeth','David','Barbara','Richard','Susan','Joseph','Jessica','Thomas','Sarah','Charles','Karen','Christopher','Nancy','Daniel','Lisa','Matthew','Margaret','Anthony','Betty','Mark','Sandra','Donald','Ashley','Steven','Dorothy','Paul','Kimberly','Andrew','Emily','Joshua','Donna','Kenneth','Michelle','Kevin','Carol','Brian','Amanda','George','Melissa','Edward','Deborah'])[(floor(random()*50)::int)+1]
    || ' ' ||
  (array['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez','Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas','Taylor','Moore','Jackson','Martin','Lee','Perez','Thompson','White','Harris','Sanchez','Clark','Ramirez','Lewis','Robinson','Walker','Young','Allen','King','Wright','Scott','Torres','Nguyen','Hill','Flores','Green','Adams','Nelson','Baker','Hall','Rivera','Campbell','Mitchell','Carter','Roberts'])[(floor(random()*50)::int)+1]
    AS Name,
  (floor(random()*60)+18)::int AS Age,
  (array['New York','Los Angeles','Chicago','Houston','Phoenix','Philadelphia','San Antonio','San Diego','Dallas','San Jose','Austin','Jacksonville','Fort Worth','Columbus','Charlotte','San Francisco','Indianapolis','Seattle','Denver','Washington'])[(floor(random()*20)::int)+1] AS City,
  round((random()*990 + 10)::numeric,2) AS PurchaseAmount,
  (CURRENT_DATE - (floor(random()* (365*3) )::int))::date AS PurchaseDate
FROM generate_series(1,10000);
