# 📊 Delivery Delays & Customer Satisfaction — Olist Case Study

## Overview
This project analyzes the impact of **delivery delays on customer satisfaction and business performance** for Olist, a Brazilian e-commerce marketplace.

The objective is to go beyond descriptive dashboards and provide **actionable, decision-oriented insights**, focusing on identifying **critical delivery delays** and quantifying their **customer and revenue impact**.


Project presentation available here : [📊](presentation/olist_customersatisfaction.pdf)

---

## 🎯 Business Questions
- Is **customer satisfaction** linked to delivery delays and logistical promises ?
- Are **delivery delays** significantly lower customers ratings ?
- Are delivery risks evenly distributed across **sellers** and **regions** ?
- What **business value** could be unlocked by fixing the most critical delays?

---

## 📦 Dataset
- **Source**: Olist Brazilian E-commerce Dataset (Kaggle)
- **Data types**: orders transactions
- **Scope**: ~96K delivered orders, ~93K unique customers

---

## 🗂️ Data Modeling & Preparation
- SQL-based data cleaning and transformation
- Feature engineering:
  - `is_delayed` flag
  - `delay_days`
  - delay severity levels (On time → Critical 7+ days) 
- OLAP **star schema**:
  - `fact_deliveries` (order-level grain, ONE ROW : one delivery->one seller->one customer->one review)
  - dimensions: customers, sellers, time
- Correct customer modeling using `customer_unique_id` (true business key)
- `review_score` Assign the most recent review score to the order (sometimes the review get updated couple times by the customer)
- `seller_id` Assign each order to the seller with the highest revenue within the order
  
---

## 📈 Key Insights

### 1️⃣ Customer Satisfaction
- Average rating (all orders): **4.16**
- Average rating on delayed orders: **2.27**
- **12.81%** of reviews ≤ 2

➡️ **Customer satisfaction collapses when delivery delays exceed 7 days.**  
Beyond this threshold, negative reviews become dominant.
[📊](screenshots/customersatisfaction.png)

---
