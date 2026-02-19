-- dimension time
/* GENERATE FROM DATE '2021-01-01' TO DATE '2024-12-01' */
CREATE TABLE `sbfd-project.sbfd_dataset.dim_time` (
    time_key        INT64         NOT NULL,   -- ex: 20210101
    date_yyyy_mm_dd     DATE        NOT NULL,

    day             INT64         NOT NULL,
    day_name        STRING NOT NULL,
    day_of_week     INT64         NOT NULL,       -- 1 = lundi
    week_of_year    INT64         NOT NULL,

    month           INT64         NOT NULL,
    month_name      STRING NOT NULL,
    quarter         INT64         NOT NULL,
    year            INT64         NOT NULL,

    is_weekend      BOOLEAN     NOT NULL,
    is_month_end    BOOLEAN     NOT NULL,
    is_quarter_end  BOOLEAN     NOT NULL,
    is_year_end     BOOLEAN     NOT NULL
);

ALTER TABLE `sbfd-project.sbfd_dataset.dim_time`
ADD PRIMARY KEY(time_key) NOT ENFORCED;

INSERT INTO `sbfd-project.sbfd_dataset.dim_time` 
SELECT
    CAST(FORMAT_DATE('%Y%m%d', date_day) AS INT64) AS time_key,
    date_day                         AS date_actual,

    EXTRACT(DAY FROM date_day)       AS day,
    FORMAT_DATE('%A', date_day)      AS day_name,
    EXTRACT(DAYOFWEEK FROM date_day) AS day_of_week,
    EXTRACT(WEEK FROM date_day)      AS week_of_year,

    EXTRACT(MONTH FROM date_day)     AS month,
    FORMAT_DATE('%B', date_day)      AS month_name,
    EXTRACT(QUARTER FROM date_day)   AS quarter,
    EXTRACT(YEAR FROM date_day)      AS year,

    EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7) AS is_weekend,
    date_day = LAST_DAY(date_day)             AS is_month_end,
    date_day = DATE_SUB(
        DATE_ADD(DATE_TRUNC(date_day, QUARTER), INTERVAL 3 MONTH),
        INTERVAL 1 DAY
    ) AS is_quarter_end,
    date_day = DATE_SUB(
        DATE_ADD(DATE_TRUNC(date_day, YEAR), INTERVAL 1 YEAR),
        INTERVAL 1 DAY
    ) AS is_year_end
    
    FROM UNNEST(
        GENERATE_DATE_ARRAY(
            DATE '2021-01-01',
            DATE '2024-12-31',
            INTERVAL 1 DAY
        )
    ) as date_day;