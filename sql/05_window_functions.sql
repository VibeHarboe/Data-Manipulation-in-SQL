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
-- SECTION 3: PARTITION BY – Compare Legia Warszawa Goals to Season Averages
-- ========================================================

-- Compare Warsaw's home and away goals to season-wide averages
SELECT
  date,
  season,
  home_goal,
  away_goal,
  CASE WHEN hometeam_id = 8673 THEN 'home' 
       ELSE 'away' END AS warsaw_location,
  AVG(home_goal) OVER(PARTITION BY season) AS season_homeavg,
  AVG(away_goal) OVER(PARTITION BY season) AS season_awayavg
FROM match
WHERE 
  hometeam_id = '8673' 
  OR awayteam_id = '8673'
ORDER BY (home_goal + away_goal) DESC;


-- ========================================================
-- SECTION 4: PARTITION BY Multiple Columns – Warsaw Goals by Season and Month
-- ========================================================

-- Average home/away goals partitioned by both season and calendar month
SELECT 
  date,
  season,
  home_goal,
  away_goal,
  CASE WHEN hometeam_id = 8673 THEN 'home' 
       ELSE 'away' END AS warsaw_location,
  AVG(home_goal) OVER(PARTITION BY season, EXTRACT(MONTH FROM date)) AS season_mo_home,
  AVG(away_goal) OVER(PARTITION BY season, EXTRACT(MONTH FROM date)) AS season_mo_away
FROM match
WHERE 
  hometeam_id = '8673'
  OR awayteam_id = '8673'
ORDER BY (home_goal + away_goal) DESC;


-- ========================================================
-- SECTION 5: Sliding Window – Running Total and Average for FC Utrecht (2011/2012)
-- ========================================================

-- Calculate running total and average of home goals for FC Utrecht across 2011/2012 season
SELECT 
  date,
  home_goal,
  away_goal,
  SUM(home_goal) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
  AVG(home_goal) OVER(ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM match
WHERE 
  hometeam_id = 9908 
  AND season = '2011/2012';


-- ========================================================
-- SECTION 6: Sliding Window – Backward Running Total for FC Utrecht (Away Games, 2011/2012)
-- ========================================================

-- Calculate reverse running total and average of home goals when FC Utrecht played away
SELECT 
  date,
  home_goal,
  away_goal,
  SUM(home_goal) OVER(ORDER BY date DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_total,
  AVG(home_goal) OVER(ORDER BY date DESC ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_avg
FROM match
WHERE 
  awayteam_id = 9908 
  AND season = '2011/2012';


-- ========================================================
-- SECTION 7: RANK() OVER() – MU Losses Ranked by Goal Difference (2014/2015)
-- ========================================================

-- Rank all Manchester United losses in 2014/2015 by goal difference using a window function
WITH home AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
         WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
         ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id
),
away AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
         WHEN m.home_goal < m.away_goal THEN 'MU Win' 
         ELSE 'Tie' END AS outcome
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
-- SECTION 8: Olympic Javelin – Previous Champions by Gender (LAG with PARTITION)
-- ========================================================

-- Return gold medalists by gender and event, with previous year's winner per group
WITH Tennis_Gold AS (
  SELECT DISTINCT
    Gender, Year, Country
  FROM Summer_Medals
  WHERE
    Year >= 2000 AND
    Event = 'Javelin Throw' AND
    Medal = 'Gold'
)
SELECT
  Gender, Year,
  Country AS Champion,
  LAG(Country) OVER(PARTITION BY Gender ORDER BY Year ASC) AS Last_Champion
FROM Tennis_Gold
ORDER BY Gender ASC, Year ASC;


-- ========================================================
-- SECTION 9: Olympic Athletics – Previous Champions by Gender and Event
-- ========================================================

-- Return previous year's gold medalist by gender and event for select Athletics competitions
WITH Athletics_Gold AS (
  SELECT DISTINCT
    Gender, Year, Event, Country
  FROM Summer_Medals
  WHERE
    Year >= 2000 AND
    Discipline = 'Athletics' AND
    Event IN ('100M', '10000M') AND
    Medal = 'Gold'
)
SELECT
  Gender, Year, Event,
  Country AS Champion,
  LAG(Country, 1) OVER(PARTITION BY Gender, Event ORDER BY Year ASC) AS Last_Champion
FROM Athletics_Gold
ORDER BY Event ASC, Gender ASC, Year ASC;


-- ========================================================
-- SECTION 10: Olympic Discus – Future Medalists (LEAD)
-- ========================================================

-- Return current and future (3 competitions ahead) gold medalists in women's discus throw
WITH Discus_Medalists AS (
  SELECT DISTINCT
    Year,
    Athlete
  FROM Summer_Medals
  WHERE Medal = 'Gold'
    AND Event = 'Discus Throw'
    AND Gender = 'Women'
    AND Year >= 2000
)
SELECT
  Year,
  Athlete,
  LEAD(Athlete, 3) OVER (ORDER BY Year ASC) AS Future_Champion
FROM Discus_Medalists
ORDER BY Year ASC;


-- ========================================================
-- SECTION 11: Olympic First Value – First Alphabetical Male Medalist
-- ========================================================

-- Return all male gold medalists and highlight the first alphabetically
WITH All_Male_Medalists AS (
  SELECT DISTINCT
    Athlete
  FROM Summer_Medals
  WHERE Medal = 'Gold'
    AND Gender = 'Men'
)
SELECT
  Athlete,
  FIRST_VALUE(Athlete) OVER (ORDER BY Athlete ASC) AS First_Athlete
FROM All_Male_Medalists;


-- ========================================================
-- SECTION 12: Olympic Last Value – Most Recent Host City
-- ========================================================

-- Return Olympic host cities and highlight the last city chronologically
WITH Hosts AS (
  SELECT DISTINCT Year, City
  FROM Summer_Medals
)
SELECT
  Year,
  City,
  LAST_VALUE(City) OVER (
    ORDER BY Year ASC
    RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS Last_City
FROM Hosts
ORDER BY Year ASC;


