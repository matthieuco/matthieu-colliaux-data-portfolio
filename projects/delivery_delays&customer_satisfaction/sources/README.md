## 🧱 Data Transformation with dbt (BigQuery)

This project uses **dbt (data build tool)** to transform raw data stored in **BigQuery** into analytics-ready tables consumed by **Power BI**.  
dbt ensures **data quality, modular transformations, documentation, and lineage** across the entire analytics pipeline.

---

## 🏗️ Architecture Overview

```text
Raw CSV files
   ↓
BigQuery (raw dataset)
   ↓
dbt (staging → intermediate → marts)
   ↓
BigQuery (analytics dataset)
   ↓
Power BI dashboards
```


=> dbt acts as the transformation and semantic layer, enforcing business logic and exposing clean, trusted tables for BI consumption.


## 📁 dbt Project Structure

```text
models/
├── staging/
│   └── stg_*.sql          -- Cleaning, renaming, typing
├── intermediate/
│   └── int_*.sql          -- Business logic & joins
└── marts/
    ├── facts/
    │   └── fact_*.sql     -- Business events at defined grain
    └── dimensions/
        └── dim_*.sql      -- Descriptive entities

tests/
macros/
dbt_project.yml
packages.yml
```


## 🔹 Modelling Strategy

Staging models (stg_*)
- One-to-one mapping with raw source tables
- Column renaming and standardization
- Type casting and basic data cleaning
- No business logic
  
Intermediate models (int_*)
- Business logic consolidation
- Complex joins and transformations
- Preparation for analytical use cases
  
Marts (fact_*, dim_*)
- Star-schema inspired modeling
- Facts defined at a clear and documented grain
- Dimensions designed for BI filtering and slicing
- Optimized for Power BI performance and usability

## 🧪 Data Quality & Testing
Data quality is enforced using dbt tests, including:
- not_null
- unique
- Relationship tests between facts and dimensions
Example:

``` text
tests:
  - not_null
  - unique
```

## 📚 Documentation & Lineage
dbt documentation is generated to provide:
- Column-level descriptions
- Model-level explanations
- Full data lineage across the warehouse

``` text
dbt docs generate
dbt docs serve
```

## 📊 Consumption Layer (Power BI)
Power BI connects exclusively to dbt marts stored in BigQuery:
- fact_delivery
- dim_sellers
- dim_customers
- dim_time
  
This approach guarantees:
- Consistent KPIs
- Improved query performance
- Clear separation between transformation and visualization layers

## 🚀 Why dbt?
Using dbt allows this project to follow analytics engineering best practices:
- Version-controlled transformations
- Reusable and testable SQL models
- Centralized business logic
- Scalable architecture 

