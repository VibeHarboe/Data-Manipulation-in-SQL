# Short vs. Correlated Subqueries

Subqueries are a powerful way to break down complex queries into manageable logic. But not all subqueries behave the same — especially when it comes to correlated subqueries.

This guide compares short (non-correlated) and correlated subqueries, outlines when to use each, and provides examples for practical data analysis.

---

## 🔍 What is a Subquery?

A subquery is a query nested inside another SQL statement. It can return scalar values, lists, or even full tables.

There are two major types:

* **Short / Non-Correlated Subqueries** – Independent of the outer query.
* **Correlated Subqueries** – Depend on a reference from the outer query.

---

## 🔹 Short (Non-Correlated) Subqueries

### ✅ Independent logic — can be run standalone.

### Example: Find users who have spent more than the average

```sql
SELECT user_id, total_spent
FROM customers
WHERE total_spent > (
  SELECT AVG(total_spent) FROM customers
);
```

### 🔹 Best used when:

* Filtering based on an overall value
* Comparing to aggregated summaries
* Logic doesn’t change row by row

---

## 🔸 Correlated Subqueries

### 🔁 Re-run for each row in the outer query — more powerful, but heavier.

### Example: Get latest order date for each user

```sql
SELECT user_id, order_id, order_date
FROM orders o
WHERE order_date = (
  SELECT MAX(order_date)
  FROM orders
  WHERE user_id = o.user_id
);
```

### 🔸 Best used when:

* Comparing values row by row
* Filtering based on group-specific max/min
* You need a dynamic reference to the outer query

---

## 📊 Performance Considerations

| Feature               | Short Subqueries | Correlated Subqueries     |
| --------------------- | ---------------- | ------------------------- |
| Can run independently | ✅ Yes            | ❌ No                      |
| Executes once         | ✅ Yes            | ❌ Executes per row        |
| Readability           | High             | Moderate to Low           |
| Typical speed         | Faster           | Slower (can be optimized) |

✅ Many databases optimize correlated subqueries internally, but with large datasets, performance may degrade.

---

## 🧠 Business Use Cases

| Scenario                             | Suggested Subquery Type |
| ------------------------------------ | ----------------------- |
| Compare orders to overall average    | Short                   |
| Find most recent purchase per user   | Correlated              |
| Filter stores above median revenue   | Short                   |
| Match country’s best-selling product | Correlated              |

---

## 🏁 Summary

| Use Case              | Use This Type           |
| --------------------- | ----------------------- |
| Overall comparison    | Short / Scalar Subquery |
| Row-by-row evaluation | Correlated Subquery     |
| Filtering by rank     | Correlated or window fn |

Subqueries let you nest logic elegantly inside queries — choose short ones for simplicity and speed, or correlated ones for precision and contextual filtering.
