# Window Functions Explained

Window functions allow you to perform calculations across rows that are related to the current row. Unlike aggregate functions, window functions do not collapse rows.

This guide covers the structure, use cases, and key examples of common window functions in SQL.

---

## 🧠 OVER() – Basic Structure

```sql
SELECT
  ...,
  AVG(score) OVER() AS avg_score
FROM table;
```

Returns the average across all rows, repeated per row.

---

## 🔀 PARTITION BY – Segment Windows

Groups the window function within subsets.

```sql
AVG(score) OVER(PARTITION BY class_id)
```

Calculates average per class.

```sql
AVG(revenue) OVER(PARTITION BY region)
```

Calculates a separate average per region.

```sql
RANK() OVER(PARTITION BY team ORDER BY score DESC)
```

Ranks each player within their team.

---

## ⬇️ ORDER BY in OVER

Orders rows inside each partition to apply ranking or cumulative logic.

```sql
RANK() OVER(PARTITION BY country ORDER BY medals DESC)
```

---

## 🔢 Common Window Functions

| Function        | Purpose                          |
| --------------- | ---------------------------------|
| `RANK()`        | Ranking (with gaps)              |
| `DENSE_RANK()`  | Ranking (no gaps)                |
| `ROW_NUMBER()`  | Unique row ordering              |
| `LAG()`         | Value from previous row          |
| `LEAD()`        | Value from next row              |
| `FIRST_VALUE()` | First row in partition           |
| `LAST_VALUE()`  | Last row in partition            |
| `NTILE(n)`      | Distribute rows into n buckets   |

---

## 🪟 ROWS BETWEEN – Frame for Aggregates

```sql
SUM(sales) OVER(
  ORDER BY month
  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
)
```

Creates a moving sum over the current and previous two rows.

Use for:
 * Moving averages
 * Rolling totals
 * Period-on-period comparisons

---

## ✅ When to Use

* Rankings (`RANK()` + `PARTITION BY`) 
* Running totals / averages (`SUM()` + `ROWS BETWEEN`) 
* Trend or Before/after comparison (`LAG()` or `LEAD()`)
* Percentile analysis (`NTILE(4)` or `PERCENT_RANK()`)
* Advanced reporting
