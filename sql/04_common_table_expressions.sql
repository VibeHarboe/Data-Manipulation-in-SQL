-- #########################################################
-- Common Table Expressions (CTEs) for modular, readable,
-- and reusable query components across transformations
-- For more advanced CTE's, check out --> 05_window_functions.sql
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

## ===============================================================
## For more advanced CTE's, check out --> 05_window_functions.sql
## ===============================================================
