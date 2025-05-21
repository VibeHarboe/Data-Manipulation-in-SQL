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

## 🔀 PARTITION BY

Groups the window function within subsets.

```sql
AVG(score) OVER(PARTITION BY class_id)
```

Calculates average per class.

---

## ⬇️ ORDER BY in OVER

Orders rows inside each partition to apply ranking or cumulative logic.

```sql
RANK() OVER(PARTITION BY country ORDER BY medals DESC)
```

---

## 🔢 Common Window Functions

| Function        | Purpose                 |
| --------------- | ----------------------- |
| `RANK()`        | Ranking (with gaps)     |
| `DENSE_RANK()`  | Ranking (no gaps)       |
| `ROW_NUMBER()`  | Unique row ordering     |
| `LAG()`         | Value from previous row |
| `LEAD()`        | Value from next row     |
| `FIRST_VALUE()` | First row in partition  |
| `LAST_VALUE()`  | Last row in partition   |

---

## 🪟 ROWS BETWEEN – Framing

```sql
SUM(score) OVER(
  ORDER BY year
  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
)
```

Defines a custom range of rows to aggregate.

---

## ✅ When to Use

* Rankings
* Running totals / averages
* Trend comparison
* Before/after comparison
* Advanced reporting
