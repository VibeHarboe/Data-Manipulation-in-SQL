# All .sql files organized by concept

## 📄 SQL Files
- [01_case_statement.sql](01_case_statement.sql) – CASE WHEN logic used to label, filter, and aggregate match results across teams, countries, and seasons
- [02_simple_short_subqueries.sql](02_simple_short_subqueries.sql) – Practical subqueries in SELECT, FROM, and WHERE clauses for filtering and aggregation
- [03_correlated_nested_queries.sql](03_correlated_nested_queries.sql) – Advanced use of correlated and nested subqueries for contextual goal analysis across country, season, and match-level dimensions
- [04_common_table_expressions.sql](04_common_table_expressions.sql) – 04_common_table_expressions.sql – Practical use of single and multiple CTEs for filtering, nesting, team lookups, and match outcome analysis


## 📄 SQL Files Overview

* [01_case_statement.sql](01_case_statement.sql) – Use of SQL CASE WHEN expressions to classify, count, filter, and compare match outcomes across multiple scenarios:

  * Label categorical values dynamically based on logic (e.g., win/loss/tie)
  * Use CASE in SELECT to build readable, user-facing categories
  * Combine CASE with SUM, COUNT, and AVG for conditional aggregation
  * Apply CASE inside WHERE clauses to filter based on outcome logic
  * Analyze specific matchups (e.g., El Clásico, Bologna wins, Barcelona performance)
  * Generate cross-season comparisons for match counts and tie percentages by country

* [02_simple_short_subqueries.sql](02_simple_short_subqueries.sql) – These examples illustrate real-world SQL logic for performance analytics, league trends, and advanced data slicing using subqueries. Techniques include:

  * Scalar subqueries for conditional filtering
  * List-based subqueries to include/exclude teams
  * Subqueries in FROM for pre-aggregation and structure
  * Subqueries in SELECT for calculated comparisons
  * Multi-layered subqueries to compare stages against season-wide averages
  * Combined clause strategies (SELECT, FROM, WHERE) in one query

* [03_correlated_nested_queries.sql](03_correlated_nested_queries.sql) – These examples reflect real-world SQL patterns for exploratory data analysis and league-level performance comparison. Covered patterns include:

  * Correlated subqueries in WHERE clauses to identify outlier matches by country and season
  * Multi-condition correlation (e.g. country + season) for pinpointed maximum value filtering
  * Nested subqueries in SELECT to compute temporal maxima (e.g. overall vs. monthly highs)
  * Nested subqueries in FROM to support complex aggregation workflows like average of counts
  * Stepwise transformations with clean logic and scalable performance queries

* [04_common_table_expressions.sql](04_common_table_expressions.sql) – This file demonstrates how Common Table Expressions (CTEs) improve SQL clarity and flexibility through stepwise logic structuring and reusable components:

  * Simple CTEs to replace subqueries for filtering and aggregation
  * CTEs with JOINs and derived columns for enriched context (e.g. total goals)
  * Nested subqueries inside CTEs for filtered aggregates (e.g. goals in August)
  * Multiple CTEs layered to calculate per-season high scoring patterns
  * Dual CTEs to extract both home and away team names for matches
  * CTE-driven match outcome tagging for specific teams (e.g. Manchester United in 2014/2015)
