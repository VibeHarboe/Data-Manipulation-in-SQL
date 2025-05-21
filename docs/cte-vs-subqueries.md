CTEs vs. Subqueries

CTEs (Common Table Expressions) and subqueries both allow you to build intermediate result sets, but they differ in readability, reusability, and structure.

🆚 Basic Structure

Subquery

SELECT name
FROM (
  SELECT name, salary FROM employees
  WHERE department = 'Sales'
) AS sales_employees;

CTE

WITH sales_employees AS (
  SELECT name, salary
  FROM employees
  WHERE department = 'Sales'
)
SELECT name
FROM sales_employees;

🧠 Key Differences

Feature

CTE

Subquery

Readability

High – named blocks

Moderate – nested structures

Reusability

Reusable within the query

Not reusable

Modularity

Easy to refactor/extend

Less modular

Recursive support

✅ Yes

❌ No

Performance

Similar, but depends on engine

Similar, can vary

✅ When to Use CTEs

When the logic is complex and reused multiple times

When working with recursive structures (e.g., hierarchies)

When you want to separate transformation steps clearly

✅ When to Use Subqueries

For one-off filters or simple nesting

When you don't need to reuse logic

Bonus: CTEs with Window Functions

CTEs pair especially well with window functions for readable and layered analytics:

WITH medal_counts AS (
  SELECT country, COUNT(*) AS medals
  FROM Summer_Medals
  WHERE year = 2012
  GROUP BY country
)
SELECT *,
  RANK() OVER(ORDER BY medals DESC) AS rank
FROM medal_counts;

This allows clear separation between data preparation and ranking logic.

