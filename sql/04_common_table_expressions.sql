-- #########################################################
-- Common Table Expressions (CTEs) for modular, readable,
-- and reusable query components across transformations
-- #########################################################

-- ========================================================
-- SECTION 1: Basic CTE – High Scoring Matches per League
-- ========================================================

-- Return number of matches with 10+ total goals per league using a CTE for filtering
WITH match_list AS (
  SELECT 
    country_id, 
    id
  FROM match
  WHERE (home_goal + away_goal) >= 10
)
SELECT
  l.name AS league,
  COUNT(match_list.id) AS matches
FROM league AS l
LEFT JOIN match_list 
  ON l.id = match_list.country_id
GROUP BY l.name;


-- ========================================================
-- SECTION 2: CTE with JOIN and Derived Column – Match Details with High Scores
-- ========================================================

-- Return detailed list of matches with 10+ total goals, including league info
WITH match_list AS (
  SELECT 
    l.name AS league,
    m.date,
    m.home_goal,
    m.away_goal,
    (m.home_goal + m.away_goal) AS total_goals
  FROM match AS m
  LEFT JOIN league AS l ON m.country_id = l.id
)
SELECT 
  league,
  date,
  home_goal,
  away_goal
FROM match_list
WHERE total_goals >= 10;


-- ========================================================
-- SECTION 3: CTE with Nested Subquery – Avg Goals in August 2013/2014
-- ========================================================

-- Return average goals scored in August of the 2013/2014 season using CTE + nested subquery
WITH match_list AS (
  SELECT 
    country_id,
    (home_goal + away_goal) AS goals
  FROM match
  WHERE id IN (
    SELECT id
    FROM match
    WHERE season = '2013/2014' AND EXTRACT(MONTH FROM date) = 08
  )
)
SELECT 
  l.name,
  AVG(goals)
FROM league AS l
LEFT JOIN match_list 
  ON l.id = match_list.country_id
GROUP BY l.name;


-- ========================================================
-- SECTION 4: Multiple CTEs – Layered Analysis of 5+ Goal Matches
-- ========================================================

-- Use multiple CTEs to structure intermediate transformations
WITH filtered_matches AS (
  SELECT id, season, country_id
  FROM match
  WHERE home_goal >= 5 OR away_goal >= 5
),
seasonal_counts AS (
  SELECT country_id, season, COUNT(id) AS high_scoring_matches
  FROM filtered_matches
  GROUP BY country_id, season
)
SELECT 
  c.name AS country,
  AVG(seasonal_counts.high_scoring_matches) AS avg_matches_per_season
FROM country AS c
LEFT JOIN seasonal_counts
  ON c.id = seasonal_counts.country_id
GROUP BY country;


-- ========================================================
-- SECTION 5: Dual CTEs – Get Home and Away Team Names per Match
-- ========================================================

-- Use two CTEs to retrieve home and away team names for each match
WITH home AS (
  SELECT m.id, m.date, 
         t.team_long_name AS hometeam, m.home_goal
  FROM match AS m
  LEFT JOIN team AS t 
    ON m.hometeam_id = t.team_api_id
),
away AS (
  SELECT m.id, m.date, 
         t.team_long_name AS awayteam, m.away_goal
  FROM match AS m
  LEFT JOIN team AS t 
    ON m.awayteam_id = t.team_api_id
)
SELECT 
  home.date,
  home.hometeam,
  away.awayteam,
  home.home_goal,
  away.away_goal
FROM home
INNER JOIN away
  ON home.id = away.id;


-- ========================================================
-- SECTION 6: Dual CTEs with Outcome Filter – Manchester United Matches (2014/2015)
-- ========================================================

-- Return matches played by Manchester United with outcome and team names from both sides
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
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
         WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
         ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id
)
SELECT DISTINCT
  m.date,
  home.team_long_name AS home_team,
  away.team_long_name AS away_team,
  m.home_goal,
  m.away_goal
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE season = '2014/2015'
  AND (home.team_long_name = 'Manchester United' OR away.team_long_name = 'Manchester United');

----------------------------------------------------------------------------------------------------------------
-- ========================================================
-- SECTION 7: RANK() OVER() – MU Losses Ranked by Goal Difference (2014/2015)
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
-- SECTION 8: Olympic Champions with LAG() – Gender and Event Variants
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
-- SECTION 9: Olympic Medalist Forecasting – LEAD() and Value Comparisons
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
-- SECTION 10: Olympic Medalists – First and Last Values
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
-- SECTION 11: Olympic Athlete Rankings – DENSE_RANK by Country
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

