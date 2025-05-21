# Pivot, ROLLUP & CUBE – Guide to Summarizing and Reshaping SQL Results

This guide explains how to reshape and summarize your SQL query results using PostgreSQL’s pivoting and multidimensional aggregation tools: `CROSSTAB`, `ROLLUP`, and `CUBE`.

---

## 🔁 Pivoting with CROSSTAB

`CROSSTAB` allows you to transform rows into columns. It is part of PostgreSQL's `tablefunc` extension.

### Enable Extension

```sql
CREATE EXTENSION IF NOT EXISTS tablefunc;
```

### Example: Gold Medalists by Year

```sql
SELECT * FROM CROSSTAB($$
  SELECT Gender, Year, Country
  FROM Summer_Medals
  WHERE Medal = 'Gold' AND Event = 'Pole Vault'
  ORDER BY Gender, Year
$$) AS ct (
  Gender VARCHAR,
  "2008" VARCHAR,
  "2012" VARCHAR
);
```

---

## 🧮 ROLLUP – Hierarchical Subtotals

`ROLLUP` lets you aggregate data at multiple levels of a hierarchy.

### Example: Subtotals per Country and Gender

```sql
SELECT
  COALESCE(Country, 'All countries') AS Country,
  COALESCE(Gender, 'All genders') AS Gender,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE Year = 2004 AND Medal = 'Gold'
GROUP BY ROLLUP(Country, Gender)
ORDER BY Country, Gender;
```

✅ Adds grouped subtotals and grand total rows.

### Output:

* Country + Gender
* Country (subtotal)
* Grand total (all NULLs)

---

## 🔷 CUBE – All Grouping Combinations

`CUBE` generates aggregations for all combinations of the given columns.

### Example: Russian Medal Summary (Gender × Medal)

```sql
SELECT
  COALESCE(Gender, 'All genders') AS Gender,
  COALESCE(Medal, 'All medals') AS Medal,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE Year = 2012 AND Country = 'RUS'
GROUP BY CUBE(Gender, Medal)
ORDER BY Gender, Medal;
```

✅ Useful for multidimensional reports and dashboards.

Generates:

* Gender + Medal breakdown
* Gender total
* Medal total
* Grand total

---

## 🔍 ROLLUP vs. CUBE

| Feature     | ROLLUP                           | CUBE                            |
| ----------- | -------------------------------- | ------------------------------- |
| Subtotals   | Yes (in hierarchy order)         | Yes (all possible combinations) |
| Grand total | Yes                              | Yes                             |
| Use case    | Reports with logical drill-downs | Multidimensional analysis       |

---

## 🧠 Tips

* Use `COALESCE()` to replace `NULL` in subtotal/grand total rows.
* Combine with `ORDER BY` to keep grouped data readable.
* Use with `WHERE`, `HAVING`, or joins for custom segmentation.

---

## Bonus: Combine with Pivoting

You can apply `ROLLUP` or `CUBE` to queries before pivoting the results, enabling layered reporting logic.

Mastering these SQL tools lets you go from raw data to dynamic reports in just a few lines of code!
