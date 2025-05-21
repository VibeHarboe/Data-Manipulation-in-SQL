-- #########################################################
-- Beyond Window Functions: PIVOT, ROLLUP & CUBE
-- Summarizing, reshaping, and expanding SQL outputs for analysis
-- #########################################################

-- ========================================================
-- SECTION 1: Basic Pivot with CROSSTAB – Pole Vault Gold Medalists
-- ========================================================

-- Enable tablefunc extension to use crosstab
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- Pivot country results for Pole Vault gold medalists by year
SELECT * FROM CROSSTAB($$
  SELECT
    Gender, Year, Country
  FROM Summer_Medals
  WHERE
    Year IN (2008, 2012)
    AND Medal = 'Gold'
    AND Event = 'Pole Vault'
  ORDER BY Gender ASC, Year ASC
$$) AS ct (
  Gender VARCHAR,
  "2008" VARCHAR,
  "2012" VARCHAR
)
ORDER BY Gender ASC;


-- ========================================================
-- SECTION 2: Medal Count by Country and Year – FRA, GBR, GER (2004–2012)
-- ========================================================

-- Count the gold medals per country and year
SELECT
  Country,
  Year,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE
  Country IN ('FRA', 'GBR', 'GER')
  AND Year IN (2004, 2008, 2012)
  AND Medal = 'Gold'
GROUP BY Country, Year
ORDER BY Country ASC, Year ASC;


-- ========================================================
-- SECTION 3: Country-Level Subtotals using ROLLUP – Scandinavian Golds in 2004
-- ========================================================

-- Count the gold medals per country and gender
-- Replace NULLs in subtotal rows with readable labels
-- Include Country-level subtotals using ROLLUP
SELECT
  COALESCE(Country, 'All countries') AS Country,
  COALESCE(Gender, 'All genders') AS Gender,
  COUNT(*) AS Gold_Awards
FROM Summer_Medals
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country IN ('DEN', 'NOR', 'SWE')
GROUP BY Country, ROLLUP(Gender)
ORDER BY Country ASC, Gender ASC;


-- ========================================================
-- SECTION 3: Country-Level Subtotals using ROLLUP – Scandinavian Golds in 2004
-- ========================================================

-- Count the gold medals per country and gender
-- Replace NULLs in subtotal rows with readable labels
-- Include Country-level subtotals using ROLLUP
SELECT
  COALESCE(Country, 'All countries') AS Country,
  COALESCE(Gender, 'All genders') AS Gender,
  COUNT(*) AS Gold_Awards
FROM Summer_Medals
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country IN ('DEN', 'NOR', 'SWE')
GROUP BY Country, ROLLUP(Gender)
ORDER BY Country ASC, Gender ASC;


-- ========================================================
-- SECTION 4: All Group-Level Subtotals using CUBE – Russian Medals in 2012
-- ========================================================

-- Count the medals awarded to Russia per gender and medal type
-- Replace NULLs in subtotal rows with readable labels
-- Include all group-level subtotals and grand total using CUBE
SELECT
  COALESCE(Gender, 'All genders') AS Gender,
  COALESCE(Medal, 'All medals') AS Medal,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE
  Year = 2012
  AND Country = 'RUS'
GROUP BY CUBE(Gender, Medal)
ORDER BY Gender ASC, Medal ASC;


-- ========================================================
-- SECTION 5: Ranked Countries as Comma-Separated List – Top 3 Golds in 2000
-- ========================================================

-- Rank all countries by number of gold medals awarded in 2000
WITH Country_Medals AS (
  SELECT Country, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE Year = 2000 AND Medal = 'Gold'
  GROUP BY Country
), Ranked AS (
  SELECT Country,
         RANK() OVER(ORDER BY Medals DESC) AS Rank
  FROM Country_Medals
)
SELECT
  STRING_AGG(Country, ', ') AS Top3_Countries
FROM Ranked
WHERE Rank <= 3;
