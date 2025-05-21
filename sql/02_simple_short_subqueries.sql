-- #########################################################
-- Short and Simple Subqueries in SELECT, FROM, and WHERE
-- for filtering, comparison, and derived calculations
-- #########################################################

-- ========================================================
-- SECTION 1: Scalar Subquery in WHERE – Above Average Goal Total
-- ========================================================

-- Return matches from 2013/2014 where total goals scored exceeded 3x the seasonal average
SELECT 
  date,
  home_goal,
  away_goal
FROM matches_2013_2014
WHERE (home_goal + away_goal) > 
  (SELECT 3 * AVG(home_goal + away_goal)
   FROM matches_2013_2014);


-- ========================================================
-- SECTION 2: Subquery with List in WHERE – Teams That Never Played at Home
-- ========================================================

-- Return all teams that never appeared as the home team in any match
SELECT 
  team_long_name,
  team_short_name
FROM team
WHERE team_api_id NOT IN (
  SELECT DISTINCT hometeam_id
  FROM match
);


-- ========================================================
-- SECTION 3: Subquery with Filtered List – Teams That Scored 8+ Goals at Home
-- ========================================================

-- Return all teams that scored 8 or more goals in a single home match
SELECT
  team_long_name,
  team_short_name
FROM team
WHERE team_api_id IN (
  SELECT hometeam_id 
  FROM match
  WHERE home_goal >= 8
);


-- ========================================================
-- SECTION 4: Subquery in FROM – High Scoring Matches by Country
-- ========================================================

-- Return number of high scoring matches (10+ total goals) per country using subquery in FROM
SELECT
  c.name AS country_name,
  COUNT(sub.id) AS matches
FROM country AS c
INNER JOIN (
  SELECT country_id, id
  FROM match
  WHERE (home_goal + away_goal) >= 10
) AS sub
  ON c.id = sub.country_id
GROUP BY country_name;


-- ========================================================
-- SECTION 5: Subquery in FROM – Details of 10+ Goal Matches
-- ========================================================

-- Return country, date, and score breakdown for matches with 10 or more total goals
SELECT
  country,
  date,
  home_goal,
  away_goal
FROM (
  SELECT 
    c.name AS country, 
    m.date, 
    m.home_goal, 
    m.away_goal,
    (m.home_goal + m.away_goal) AS total_goals
  FROM match AS m
  LEFT JOIN country AS c
    ON m.country_id = c.id
) AS subq
WHERE total_goals >= 10;


-- ========================================================
-- SECTION 6: Subquery in SELECT – League vs. Overall Avg Goals (2013/2014)
-- ========================================================

-- Return each league's average goals and compare to overall 2013/2014 average
SELECT 
  l.name AS league,
  ROUND(AVG(m.home_goal + m.away_goal), 2) AS avg_goals,
  (SELECT ROUND(AVG(home_goal + away_goal), 2)
   FROM match
   WHERE season = '2013/2014') AS overall_avg
FROM league AS l
LEFT JOIN match AS m
  ON l.country_id = m.country_id
WHERE season = '2013/2014'
GROUP BY l.name;


-- ========================================================
-- SECTION 7: Subquery in SELECT – Difference from Overall Avg (2013/2014)
-- ========================================================

-- Return league-level average and difference from overall season average
SELECT
  l.name AS league,
  ROUND(AVG(m.home_goal + m.away_goal), 2) AS avg_goals,
  ROUND(AVG(m.home_goal + m.away_goal) -
    (SELECT AVG(home_goal + away_goal)
     FROM match
     WHERE season = '2013/2014'), 2) AS diff
FROM league AS l
LEFT JOIN match AS m
  ON l.country_id = m.country_id
WHERE season = '2013/2014'
GROUP BY l.name;


-- ========================================================
-- SECTION 8: Subqueries for Temporal Comparison – Stage-Level Goal Analysis (2012/2013)
-- ========================================================

-- Return average goals per stage and compare with overall season average
SELECT 
  m.stage,
  ROUND(AVG(m.home_goal + m.away_goal), 2) AS avg_goals,
  ROUND((SELECT AVG(home_goal + away_goal) 
         FROM match 
         WHERE season = '2012/2013'), 2) AS overall
FROM match AS m
WHERE season = '2012/2013'
GROUP BY m.stage;


-- ========================================================
-- SECTION 9: Subquery in FROM + WHERE – Stages with Above-Average Goals
-- ========================================================

-- Return only stages where average goals exceed season average using FROM + scalar subqueries
SELECT 
  s.stage,
  ROUND(s.avg_goals, 2) AS avg_goals
FROM (
  SELECT
    stage,
    AVG(home_goal + away_goal) AS avg_goals
  FROM match
  WHERE season = '2012/2013'
  GROUP BY stage
) AS s
WHERE s.avg_goals > (
  SELECT AVG(home_goal + away_goal)
  FROM match
  WHERE season = '2012/2013'
);


-- ========================================================
-- SECTION 10: Subqueries in SELECT, FROM, and WHERE – Final Comparison by Stage
-- ========================================================

-- Compare each stage's average to overall 2012/2013 average using subqueries in SELECT, FROM, and WHERE
SELECT 
  s.stage,
  ROUND(s.avg_goals, 2) AS avg_goal,
  (SELECT AVG(home_goal + away_goal)
   FROM match
   WHERE season = '2012/2013') AS overall_avg
FROM (
  SELECT
    stage,
    AVG(home_goal + away_goal) AS avg_goals
  FROM match
  WHERE season = '2012/2013'
  GROUP BY stage
) AS s
WHERE s.avg_goals > (
  SELECT AVG(home_goal + away_goal)
  FROM match
  WHERE season = '2012/2013'
);


-- ========================================================
-- SECTION 11: Dual Subqueries in FROM – Team Names per Match
-- ========================================================

-- Return match data with both home and away team names using two subqueries in FROM
SELECT
  m.date,
  home.hometeam,
  away.awayteam,
  m.home_goal,
  m.away_goal
FROM match AS m
LEFT JOIN (
  SELECT match.id, team.team_long_name AS hometeam
  FROM match
  LEFT JOIN team
    ON match.hometeam_id = team.team_api_id
) AS home
  ON home.id = m.id
LEFT JOIN (
  SELECT match.id, team.team_long_name AS awayteam
  FROM match
  LEFT JOIN team
    ON match.awayteam_id = team.team_api_id
) AS away
  ON away.id = m.id;
