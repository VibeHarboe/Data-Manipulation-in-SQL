-- #########################################################
-- CASE WHEN logic to transform and categorize data
-- for reporting, labeling, and conditional aggregation
-- #########################################################

-- ========================================================
-- SECTION 1: Basic CASE Statement – Labeling Home Teams
-- ========================================================

-- Classify German home teams as Bayern Munich, Schalke 04, or Other
SELECT 
  CASE 
    WHEN hometeam_id = 10189 THEN 'FC Schalke 04'
    WHEN hometeam_id = 9823 THEN 'FC Bayern Munich'
    ELSE 'Other' 
  END AS home_team,
  COUNT(id) AS total_matches
FROM matches_germany
GROUP BY home_team;


-- ========================================================
-- SECTION 2: Categorizing Match Results with CASE
-- ========================================================

-- Label each match based on score difference
SELECT 
  id,
  home_goal,
  away_goal,
  CASE
    WHEN home_goal > away_goal THEN 'Home Win'
    WHEN away_goal > home_goal THEN 'Away Win'
    ELSE 'Draw'
  END AS match_result
FROM match;


-- ========================================================
-- SECTION 3: CASE WHEN with Aggregation – Win Count by Type
-- ========================================================

-- Aggregate match outcomes using conditional CASE inside SUM
SELECT 
  COUNT(*) AS total_matches,
  SUM(CASE WHEN home_goal > away_goal THEN 1 ELSE 0 END) AS home_wins,
  SUM(CASE WHEN away_goal > home_goal THEN 1 ELSE 0 END) AS away_wins,
  SUM(CASE WHEN home_goal = away_goal THEN 1 ELSE 0 END) AS draws
FROM match;


-- ========================================================
-- SECTION 4: CASE WHEN – Home Match Outcomes for Barcelona (2011/2012)
-- ========================================================

-- Analyze outcomes of matches where FC Barcelona played at home
-- Uses CASE to classify results and joins for opponent name
SELECT 
  m.date,
  t.team_long_name AS opponent,
  CASE 
    WHEN m.home_goal > m.away_goal THEN 'Barcelona win'
    WHEN m.home_goal < m.away_goal THEN 'Barcelona loss'
    ELSE 'Tie'
  END AS outcome 
FROM matches_spain AS m
LEFT JOIN teams_spain AS t 
  ON m.awayteam_id = t.team_api_id
WHERE m.hometeam_id = 8634;


-- ========================================================
-- SECTION 5: CASE WHEN – Away Match Outcomes for Barcelona (2011/2012)
-- ========================================================

-- Analyze outcomes of matches where FC Barcelona played away
-- Opponent is identified via LEFT JOIN and results categorized with CASE
SELECT  
  m.date,
  t.team_long_name AS opponent,
  CASE 
    WHEN m.home_goal < m.away_goal THEN 'Barcelona win'
    WHEN m.home_goal > m.away_goal THEN 'Barcelona loss'
    ELSE 'Tie' 
  END AS outcome
FROM matches_spain AS m
LEFT JOIN teams_spain AS t 
  ON m.hometeam_id = t.team_api_id
WHERE m.awayteam_id = 8634;


-- ========================================================
-- SECTION 6: CASE WHEN – El Clásico Match Results (Barcelona vs. Real Madrid)
-- ========================================================

-- Identify each El Clásico match and determine the winner based on goals and team identity
SELECT
  date,
  CASE WHEN hometeam_id = 8634 THEN 'FC Barcelona' 
       ELSE 'Real Madrid CF' END AS home,
  CASE WHEN awayteam_id = 8634 THEN 'FC Barcelona' 
       ELSE 'Real Madrid CF' END AS away,
  CASE 
    WHEN home_goal > away_goal AND hometeam_id = 8634 THEN 'Barcelona win'
    WHEN home_goal > away_goal AND hometeam_id = 8633 THEN 'Real Madrid win'
    WHEN home_goal < away_goal AND awayteam_id = 8634 THEN 'Barcelona win'
    WHEN home_goal < away_goal AND awayteam_id = 8633 THEN 'Real Madrid win'
    ELSE 'Tie'
  END AS outcome
FROM matches_spain
WHERE (awayteam_id = 8634 OR hometeam_id = 8634)
  AND (awayteam_id = 8633 OR hometeam_id = 8633);


-- ========================================================
-- SECTION 7: CASE WHEN with Filtering – Bologna Wins Only
-- ========================================================

-- Identify Bologna's wins as home or away team using CASE logic
-- Filter to include only matches where Bologna won
SELECT 
  season,
  date,
  home_goal,
  away_goal
FROM matches_italy
WHERE 
  CASE 
    WHEN hometeam_id = 9857 AND home_goal > away_goal THEN 'Bologna Win'
    WHEN awayteam_id = 9857 AND away_goal > home_goal THEN 'Bologna Win'
  END IS NOT NULL;


-- ========================================================
-- SECTION 8: CASE WHEN with COUNT – Match Volume per Country per Season
-- ========================================================

-- Count number of matches played in each country per season using CASE inside COUNT
SELECT 
  c.name AS country,
  COUNT(CASE WHEN m.season = '2012/2013' THEN m.id END) AS matches_2012_2013,
  COUNT(CASE WHEN m.season = '2013/2014' THEN m.id END) AS matches_2013_2014,
  COUNT(CASE WHEN m.season = '2014/2015' THEN m.id END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
  ON c.id = m.country_id
GROUP BY country;


-- ========================================================
-- SECTION 9: CASE WHEN with SUM – Home Wins per Country per Season
-- ========================================================

-- Use CASE with SUM to count home wins per country across seasons
SELECT 
  c.name AS country,
  SUM(CASE WHEN m.season = '2012/2013' AND m.home_goal > m.away_goal THEN 1 ELSE 0 END) AS matches_2012_2013,
  SUM(CASE WHEN m.season = '2013/2014' AND m.home_goal > m.away_goal THEN 1 ELSE 0 END) AS matches_2013_2014,
  SUM(CASE WHEN m.season = '2014/2015' AND m.home_goal > m.away_goal THEN 1 ELSE 0 END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
  ON c.id = m.country_id
GROUP BY country;


-- ========================================================
-- SECTION 10: CASE WHEN with AVG – Percentage of Tied Matches
-- ========================================================

-- Calculate the percentage of tied matches using CASE logic inside AVG and ROUND to 2 decimals
SELECT 
  c.name AS country,
  ROUND(AVG(CASE WHEN m.season = '2013/2014' AND m.home_goal = m.away_goal THEN 1
                 WHEN m.season = '2013/2014' AND m.home_goal != m.away_goal THEN 0
            END), 2) AS pct_ties_2013_2014,
  ROUND(AVG(CASE WHEN m.season = '2014/2015' AND m.home_goal = m.away_goal THEN 1
                 WHEN m.season = '2014/2015' AND m.home_goal != m.away_goal THEN 0
            END), 2) AS pct_ties_2014_2015
FROM country AS c
LEFT JOIN match AS m
  ON c.id = m.country_id
GROUP BY country;
