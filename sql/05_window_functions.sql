-- #########################################################
-- Window Functions for ranking, aggregation, and comparison
-- across partitions and ordered row contexts
-- #########################################################

-- ========================================================
-- SECTION 1: OVER() Clause – Average Goals Across All Matches
-- ========================================================

-- Return match data with the overall average goals repeated on each row
SELECT 
  m.id, 
  c.name AS country, 
  m.season,
  m.home_goal,
  m.away_goal,
  AVG(m.home_goal + m.away_goal) OVER() AS overall_avg
FROM match AS m
LEFT JOIN country AS c 
  ON m.country_id = c.id;


-- ========================================================
-- SECTION 2: RANK() OVER() – Rank Leagues by Average Goals Descending (2011/2012)
-- ========================================================

-- Rank each league from highest to lowest average total goals in 2011/2012 season
SELECT 
  l.name AS league,
  AVG(m.home_goal + m.away_goal) AS avg_goals,
  RANK() OVER(ORDER BY AVG(m.home_goal + m.away_goal) DESC) AS league_rank
FROM league AS l
LEFT JOIN match AS m 
  ON l.id = m.country_id
WHERE m.season = '2011/2012'
GROUP BY l.name
ORDER BY league_rank;


-- ========================================================
-- SECTION 3: PARTITION BY – Warsaw Goals by Season and Month
-- ========================================================

SELECT
  date,
  season,
  home_goal,
  away_goal,
  CASE WHEN hometeam_id = 8673 THEN 'home' ELSE 'away' END AS warsaw_location,
  AVG(home_goal) OVER(PARTITION BY season) AS season_homeavg,
  AVG(away_goal) OVER(PARTITION BY season) AS season_awayavg,
  AVG(home_goal) OVER(PARTITION BY season, EXTRACT(MONTH FROM date)) AS season_mo_home,
  AVG(away_goal) OVER(PARTITION BY season, EXTRACT(MONTH FROM date)) AS season_mo_away
FROM match
WHERE hometeam_id = '8673' OR awayteam_id = '8673';


-- ========================================================
-- SECTION 4: Sliding Window – Running Totals for FC Utrecht (2011/2012)
-- ========================================================

-- Subsection A: Running total and average at home
SELECT 
  date,
  home_goal,
  away_goal,
  SUM(home_goal) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
  AVG(home_goal) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM match
WHERE hometeam_id = 9908 AND season = '2011/2012';

-- Subsection B: Reverse running total and average away
SELECT 
  date,
  home_goal,
  away_goal,
  SUM(home_goal) OVER(ORDER BY date DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_total,
  AVG(home_goal) OVER(ORDER BY date DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_avg
FROM match
WHERE awayteam_id = 9908 AND season = '2011/2012';


-- ========================================================
-- SECTION 5: RANK() OVER() – MU Losses Ranked by Goal Difference (2014/2015)
-- ========================================================

-- Rank all Manchester United losses in 2014/2015 by goal difference using a window function
WITH home AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
         WHEN m.home_goal < m.away_goal THEN 'MU Loss' ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id
),
away AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
         WHEN m.home_goal < m.away_goal THEN 'MU Win' ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id
)
SELECT DISTINCT
  m.date,
  home.team_long_name AS home_team,
  away.team_long_name AS away_team,
  m.home_goal, m.away_goal,
  RANK() OVER(ORDER BY ABS(home_goal - away_goal) DESC) AS match_rank
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
  AND ((home.team_long_name = 'Manchester United' AND home.outcome = 'MU Loss')
    OR (away.team_long_name = 'Manchester United' AND away.outcome = 'MU Loss'));


-- ========================================================
-- SECTION 6: Olympic Champions with LAG() – Gender and Event Variants
-- ========================================================

-- A. Javelin gold medalists by gender
WITH Tennis_Gold AS (
  SELECT DISTINCT Gender, Year, Country
  FROM Summer_Medals
  WHERE Year >= 2000 AND Event = 'Javelin Throw' AND Medal = 'Gold')
SELECT Gender, Year, Country AS Champion,
  LAG(Country) OVER(PARTITION BY Gender ORDER BY Year ASC) AS Last_Champion
FROM Tennis_Gold
ORDER BY Gender, Year;

-- B. 100M & 10000M gold medalists by gender and event
WITH Athletics_Gold AS (
  SELECT DISTINCT Gender, Year, Event, Country
  FROM Summer_Medals
  WHERE Year >= 2000 AND Discipline = 'Athletics'
    AND Event IN ('100M', '10000M') AND Medal = 'Gold')
SELECT Gender, Year, Event, Country AS Champion,
  LAG(Country, 1) OVER(PARTITION BY Gender, Event ORDER BY Year ASC) AS Last_Champion
FROM Athletics_Gold
ORDER BY Event, Gender, Year;


-- ========================================================
-- SECTION 7: Olympic Medalist Forecasting – LEAD() and Value Comparisons
-- ========================================================

-- A. Future gold medalists in women's discus (3 ahead)
WITH Discus_Medalists AS (
  SELECT DISTINCT Year, Athlete
  FROM Summer_Medals
  WHERE Medal = 'Gold' AND Event = 'Discus Throw' AND Gender = 'Women' AND Year >= 2000)
SELECT Year, Athlete,
  LEAD(Athlete, 3) OVER (ORDER BY Year ASC) AS Future_Champion
FROM Discus_Medalists
ORDER BY Year;


-- ========================================================
-- SECTION 8: Olympic Medalists – First and Last Values
-- ========================================================

-- A. First alphabetical male gold medalist
WITH All_Male_Medalists AS (
  SELECT DISTINCT Athlete
  FROM Summer_Medals
  WHERE Medal = 'Gold' AND Gender = 'Men')
SELECT Athlete,
  FIRST_VALUE(Athlete) OVER (ORDER BY Athlete ASC) AS First_Athlete
FROM All_Male_Medalists;

-- B. Last city to host the Olympic Games
WITH Hosts AS (
  SELECT DISTINCT Year, City
  FROM Summer_Medals)
SELECT Year, City,
  LAST_VALUE(City) OVER (
    ORDER BY Year ASC
    RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS Last_City
FROM Hosts
ORDER BY Year;


-- ========================================================
-- SECTION 9: Olympic Athlete Rankings – DENSE_RANK by Country
-- ========================================================

-- Rank athletes within each country by medal count using DENSE_RANK (no skipped ranks)
WITH Athlete_Medals AS (
  SELECT
    Country, Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE Country IN ('JPN', 'KOR') AND Year >= 2000
  GROUP BY Country, Athlete
  HAVING COUNT(*) > 1
)
SELECT
  Country,
  Athlete,
  DENSE_RANK() OVER (
    PARTITION BY Country
    ORDER BY Medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Country ASC, Rank_N ASC;


-- ========================================================
-- SECTION 10: Olympic Event Pagination – NTILE for Grouping Events
-- ========================================================

-- Divide 666 unique events into 111 evenly sized groups for paging
WITH Events AS (
  SELECT DISTINCT Event
  FROM Summer_Medals
)
SELECT
  Event,
  NTILE(111) OVER (ORDER BY Event ASC) AS Page
FROM Events
ORDER BY Event ASC;


-- ========================================================
-- SECTION 11: Olympic Athlete Medal Distribution – NTILE(3)
-- ========================================================

-- Split athletes into top, middle, and bottom thirds based on medal counts
WITH Athlete_Medals AS (
  SELECT Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Athlete
  HAVING COUNT(*) > 1
)
SELECT
  Athlete,
  Medals,
  NTILE(3) OVER (ORDER BY Medals DESC) AS Third
FROM Athlete_Medals
ORDER BY Medals DESC, Athlete ASC;


-- ========================================================
-- SECTION 12: Olympic Athlete Running Totals – Cumulative SUM by Name
-- ========================================================

-- Calculate running total of gold medals by USA athletes since 2000
WITH Athlete_Medals AS (
  SELECT
    Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country = 'USA' AND Medal = 'Gold'
    AND Year >= 2000
  GROUP BY Athlete
)
SELECT
  Athlete,
  Medals,
  SUM(Medals) OVER (ORDER BY athlete ASC) AS Max_Medals
FROM Athlete_Medals
ORDER BY Athlete ASC;


-- ========================================================
-- SECTION 13: Olympic Country Medal Records – Yearly Max with PARTITION
-- ========================================================

-- Return each country's medal count by year and the maximum achieved so far
WITH Country_Medals AS (
  SELECT
    Year, Country, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country IN ('CHN', 'KOR', 'JPN')
    AND Medal = 'Gold' AND Year >= 2000
  GROUP BY Year, Country
)
SELECT
  Year,
  Country,
  Medals,
  MAX(Medals) OVER (PARTITION BY Country ORDER BY Year ASC) AS Max_Medals
FROM Country_Medals
ORDER BY Country ASC, Year ASC;


-- ========================================================
-- SECTION 14: Moving Aggregates – Framed Calculations Across Country & Time
-- ========================================================

-- A. Max between current and next year (Scandinavia)
WITH Scandinavian_Medals AS (
  SELECT Year, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE Country IN ('DEN', 'NOR', 'FIN', 'SWE', 'ISL') AND Medal = 'Gold'
  GROUP BY Year)
SELECT
  Year,
  Medals,
  MAX(Medals) OVER (
    ORDER BY Year ASC
    ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS moving_max
FROM Scandinavian_Medals
ORDER BY Year ASC;

-- B. Max over current and previous 2 athletes (China)
WITH Chinese_Medals AS (
  SELECT Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE Country = 'CHN' AND Medal = 'Gold' AND Year >= 2000
  GROUP BY Athlete)
SELECT
  Athlete,
  Medals,
  MAX(Medals) OVER (
    ORDER BY Athlete ASC
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_max
FROM Chinese_Medals
ORDER BY Athlete ASC;

-- C. 3-year moving average of gold medals (Russia)
WITH Russian_Medals AS (
  SELECT Year, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE Country = 'RUS' AND Medal = 'Gold' AND Year >= 1980
  GROUP BY Year)
SELECT
  Year,
  Medals,
  AVG(Medals) OVER (
    ORDER BY Year ASC
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM Russian_Medals
ORDER BY Year ASC;

-- D. 3-year moving sum per country (global)
WITH Country_Medals AS (
  SELECT Year, Country, COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Year, Country)
SELECT
  Year,
  Country,
  Medals,
  SUM(Medals) OVER (
    PARTITION BY Country
    ORDER BY Year ASC
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_sum
FROM Country_Medals
ORDER BY Country ASC, Year ASC;
