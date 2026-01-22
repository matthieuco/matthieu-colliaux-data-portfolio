WITH dates AS (
    SELECT
        day AS date_day
    FROM UNNEST(
        GENERATE_DATE_ARRAY(
            DATE '2016-01-01',
            DATE '2019-12-31',
            INTERVAL 1 DAY
        )
    ) AS day
)

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

FROM dates