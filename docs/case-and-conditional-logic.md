# CASE Statements & Conditional Logic in SQL

Conditional logic is a cornerstone of SQL reporting and transformation. The `CASE` expression allows you to apply decision-based logic within SELECT, WHERE, GROUP BY, and ORDER BY clauses.

This guide covers:

* What `CASE` is and how it works
* Syntax and use cases
* Business examples where conditional logic is essential

---

## 🔤 What Is a CASE Statement?

A `CASE` statement works like an if-then-else expression:

```sql
CASE 
  WHEN condition THEN result
  [WHEN ...]
  [ELSE default_result]
END
```

You can use it inside any SELECT statement to transform, group, or filter values.

---

## 🧱 Basic Example

```sql
SELECT
  name,
  salary,
  CASE
    WHEN salary >= 100000 THEN 'High'
    WHEN salary >= 50000 THEN 'Medium'
    ELSE 'Low'
  END AS salary_band
FROM employees;
```

---

## 📊 Aggregation with CASE

You can count or sum conditionally:

```sql
SELECT
  department,
  COUNT(CASE WHEN gender = 'Female' THEN 1 END) AS female_count,
  COUNT(CASE WHEN gender = 'Male' THEN 1 END) AS male_count
FROM employees
GROUP BY department;
```

---

## ✅ Filter Logic in WHERE with CASE

Though less common, you can use `CASE` in `WHERE` for complex logic:

```sql
SELECT *
FROM sales
WHERE
  CASE
    WHEN country = 'US' THEN amount > 100
    ELSE amount > 200
  END;
```

---

## 🧠 Real-World Examples

### 1. 🎯 Funnel Stage Classification

```sql
SELECT user_id,
  MAX(CASE WHEN step = 'signup' THEN 1 ELSE 0 END) AS did_signup,
  MAX(CASE WHEN step = 'checkout' THEN 1 ELSE 0 END) AS did_checkout
FROM user_steps
GROUP BY user_id;
```

**Business Value:** Identify where users drop off in the journey.

---

### 2. 🛒 Basket Size Tiering

```sql
SELECT order_id, total_value,
  CASE
    WHEN total_value >= 200 THEN 'Premium'
    WHEN total_value >= 100 THEN 'Mid'
    ELSE 'Low'
  END AS order_tier
FROM orders;
```

**Business Value:** Segment customer orders for loyalty or promo analysis.

---

### 3. 📦 Conditional Discounts

```sql
SELECT customer_id, order_date,
  total_price,
  CASE
    WHEN total_price >= 500 THEN total_price * 0.9
    ELSE total_price
  END AS final_price
FROM transactions;
```

**Business Value:** Simulate or apply conditional discount logic.

---

## 🔁 Combine with Window Functions

You can embed CASE logic inside window functions:

```sql
SELECT
  country,
  year,
  SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END)
    OVER (PARTITION BY country ORDER BY year) AS cumulative_gold
FROM medals;
```

**Business Value:** Running tally of gold medals over time.

---

## ✅ Summary

| Use Case                | How CASE Adds Value                  |
| ----------------------- | ------------------------------------ |
| Binning/Labeling        | Simplifies reporting tiers           |
| Conditional aggregation | Enables custom metrics per group     |
| Dynamic pricing/logic   | Reflects real business rules in SQL  |
| Funnel analysis         | Converts step data into binary flags |

---

CASE statements make your SQL logic expressive, rule-based, and aligned with real-world business scenarios. Mastering this gives you flexibility in everything from BI dashboards to decision-making queries.
