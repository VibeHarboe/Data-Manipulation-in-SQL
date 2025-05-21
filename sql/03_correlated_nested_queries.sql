-- #########################################################
-- Correlated Queries and Nested Subqueries for advanced
-- filtering, comparisons, and contextual calculations
-- #########################################################

-- ========================================================
-- SECTION 1: Correlated Subquery – Extreme Goal Outliers by Country
-- ========================================================

-- Return matches with 3x the average goal total within each country
SELECT 
  main.country_id,
  main.date,
  main.home_goal, 
  main.away_goal
FROM match AS main
WHERE 
  (home_goal + away_goal) > 
    (SELECT AVG((sub.home_goal + sub.away_goal) * 3)
     FROM match AS sub
     WHERE main.country_id = sub.country_id);


-- ========================================================
-- SECTION 2: Correlated Subquery – Highest Scoring Match per Country and Season
-- ========================================================

-- Return match with highest goal total for each country and season
SELECT 
  main.country_id,
  main.date,
  main.home_goal,
  main.away_goal
FROM match AS main
WHERE 
  (home_goal + away_goal) =
    (SELECT MAX(sub.home_goal + sub.away_goal)
     FROM match AS sub
     WHERE main.country_id = sub.country_id
       AND main.season = sub.season);


-- ========================================================
-- SECTION 3: Nested Subqueries – Seasonal and Monthly Goal Maxima
-- ========================================================

-- Compare max goals per season with overall and July-specific max goals
SELECT
  season,
  MAX(home_goal + away_goal) AS max_goals,
  (SELECT MAX(home_goal + away_goal)
   FROM match) AS overall_max_goals,
  (SELECT MAX(home_goal + away_goal)
   FROM match
   WHERE id IN (
     SELECT id
     FROM match
     WHERE EXTRACT(MONTH FROM date) = 07
   )) AS july_max_goals
FROM match
GROUP BY season;


-- ========================================================
-- SECTION 4: Nested Subqueries in FROM – Average High-Scoring Matches per Country
-- ========================================================

-- Return average number of 5+ goal matches per season, grouped by country
SELECT
  c.name AS country,
  AVG(outer_s.matches) AS avg_seasonal_high_scores
FROM country AS c
LEFT JOIN (
  SELECT country_id, season,
         COUNT(id) AS matches
  FROM (
    SELECT country_id, season, id
    FROM match
    WHERE home_goal >= 5 OR away_goal >= 5
  ) AS inner_s
  GROUP BY country_id, season
) AS outer_s
  ON c.id = outer_s.country_id
GROUP BY country;


-- ========================================================
-- SECTION 5: Correlated Subqueries in SELECT – Team Names per Match
-- ========================================================

-- Return match data with home and away team names using correlated subqueries in SELECT clause
SELECT
  m.date,
  (SELECT team_long_name
   FROM team AS t
   WHERE t.team_api_id = m.hometeam_id) AS hometeam,
  (SELECT team_long_name
   FROM team AS t
   WHERE t.team_api_id = m.awayteam_id) AS awayteam,
  m.home_goal,
  m.away_goal
FROM match AS m;
