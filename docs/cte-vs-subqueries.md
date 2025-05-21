# CTEs vs. Subqueries

CTEs (Common Table Expressions) and subqueries both allow you to build intermediate result sets, but they differ in readability, reusability, and structure.

This guide summarizes when and why to use each, with practical SQL syntax examples.

---

## 🧱 Basic Syntax Comparison

### Subquery

```sql
SELECT name
FROM (
  SELECT name, salary
  FROM employees
  WHERE department = 'Sales'
) AS sales_employees;
```

### CTE (WITH Clause)

```sql
WITH sales_employees AS (
  SELECT name, salary
  FROM employees
  WHERE department = 'Sales'
)
SELECT name
FROM sales_employees;
```

---

## 🔍 Key Differences

| Feature               | CTE                        | Subquery                     |
| --------------------- | -------------------------- | ---------------------------- |
| **Readability**       | High – named query blocks  | Moderate – inline/nested     |
| **Reusability**       | Reusable within same query | Not reusable                 |
| **Modularity**        | Clear stepwise logic       | Often buried in WHERE/SELECT |
| **Recursive support** | ✅ Yes                      | ❌ No                         |
| **Performance**       | Usually similar            | Usually similar              |

---

## ✅ When to Use CTEs

* Complex queries with multiple transformation steps
* Recursive structures (e.g. org charts, tree hierarchies)
* Improved clarity by isolating logic into named blocks

## ✅ When to Use Subqueries

* Simple filters or one-time transformations
* You don’t need to reference the result multiple times
* Compact logic embedded inside WHERE or SELECT

---

## 💡 CTEs + Window Functions = Powerful Pattern

CTEs work exceptionally well with window functions, allowing you to:

* Pre-calculate aggregations
* Cleanly layer ranking, running totals, or gaps
* Build readable analytical pipelines

### Example

```sql
WITH medal_counts AS (
  SELECT country, COUNT(*) AS medals
  FROM Summer_Medals
  WHERE year = 2012
  GROUP BY country
)
SELECT *,
  RANK() OVER(ORDER BY medals DESC) AS rank
FROM medal_counts;
```

---

Use CTEs when your query deserves to be broken into clear, named steps.
Use subqueries when you just need a quick inline result.

Both are essential tools in SQL – and mastering when to use which makes your code cleaner, faster to debug, and easier to maintain.
