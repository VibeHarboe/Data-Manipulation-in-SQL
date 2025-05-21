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
