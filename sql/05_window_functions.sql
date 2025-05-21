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
