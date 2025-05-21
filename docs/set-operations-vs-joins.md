# Set Operations vs. Joins

Both **set operations** and **joins** allow you to combine data from multiple tables, but they do so in fundamentally different ways.

This guide walks through their use cases, syntax, and when to use each.

---

## 🔁 Set Operations Overview

Set operations combine **entire result sets** (rows and columns must match in number and type):

| Operation   | Description                               |
| ----------- | ----------------------------------------- |
| `UNION`     | Combine distinct rows from both queries   |
| `UNION ALL` | Combine all rows, including duplicates    |
| `INTERSECT` | Return rows that exist in both queries    |
| `EXCEPT`    | Return rows in first query but not second |

---

### Example: UNION vs UNION ALL

```sql
SELECT country FROM 2016_gold_medals
UNION
SELECT country FROM 2020_gold_medals;
```

Returns unique countries from both years.

```sql
SELECT country FROM 2016_gold_medals
UNION ALL
SELECT country FROM 2020_gold_medals;
```

Returns **all** countries (including duplicates).

---

## 🔗 Joins Overview

Joins combine **columns from multiple tables** based on relationships:

| Join Type    | Description                                       |
| ------------ | ------------------------------------------------- |
| `INNER JOIN` | Rows with matching keys in both tables            |
| `LEFT JOIN`  | All rows from left table + matches from right     |
| `RIGHT JOIN` | All rows from right table + matches from left     |
| `FULL JOIN`  | All rows from both tables, matched where possible |

### Example: INNER JOIN

```sql
SELECT a.name, b.population
FROM countries a
INNER JOIN demographics b
  ON a.code = b.country_code;
```

---

## 🔍 Key Differences

| Feature            | Set Operations             | Joins                         |
| ------------------ | -------------------------- | ----------------------------- |
| Merge Type         | Stack rows                 | Combine columns               |
| Schema requirement | Same column count & types  | Can differ between tables     |
| Common use case    | De-duplication, comparison | Data integration & enrichment |
| Output format      | One column structure       | Wider combined row            |

---

## ✅ When to Use Set Operations

* You have similar data from separate sources (e.g. logs, snapshots)
* You want to compare datasets (INTERSECT / EXCEPT)
* You need to union historic vs. current records

## ✅ When to Use Joins

* You need to enrich data with dimensions (e.g. country names, user attributes)
* You’re modeling relationships (1\:many, many\:many)
* You want to align multiple fact tables by key

---

## Bonus: Set Operation Inside Join

You can combine the two! Example:

```sql
WITH all_events AS (
  SELECT * FROM 2012_events
  UNION ALL
  SELECT * FROM 2016_events
)
SELECT e.event, c.city
FROM all_events e
JOIN cities c ON e.city_id = c.id;
```

---

Set operations = vertical stacking
Joins = horizontal linking

Mastering both lets you reshape datasets and combine sources with power and clarity.
