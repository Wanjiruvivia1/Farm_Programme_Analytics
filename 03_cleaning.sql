-- 03_cleaning.sql
USE farm_programme_analytics;

CREATE TABLE clean_farmers AS
WITH ranked AS (
    SELECT f.*,
           ROW_NUMBER() OVER (PARTITION BY farmer_id ORDER BY farmer_id) AS rn
    FROM stg_farmers f
)
SELECT
    farmer_id,
    first_name,
    last_name,
    NULLIF(TRIM(gender), '') AS gender,
    CASE WHEN date_of_birth REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
         THEN STR_TO_DATE(date_of_birth, '%Y-%m-%d') END AS date_of_birth,
    CASE
        WHEN LOWER(TRIM(county)) IN ('muranga', 'murang''a') THEN 'Murang''a'
        WHEN LOWER(TRIM(county)) IN ('uasin-gishu', 'uasin gishu') THEN 'Uasin Gishu'
        ELSE CONCAT(UPPER(LEFT(TRIM(county), 1)), LOWER(SUBSTRING(TRIM(county), 2)))
    END AS county,
    sub_county,
    STR_TO_DATE(registration_date, '%Y-%m-%d') AS registration_date,
    CAST(NULLIF(TRIM(farm_size_acres), '') AS DECIMAL(6,2)) AS farm_size_acres,
    primary_crop,
    NULLIF(TRIM(phone_number), '') AS phone_number
FROM ranked
WHERE rn = 1;
DESCRIBE stg_sales_transactions;
SHOW VARIABLES LIKE 'datadir';
SELECT DATABASE();
DROP TABLE IF EXISTS clean_sales;

CREATE TABLE clean_sales AS
WITH ranked AS (
    SELECT s.*,
           ROW_NUMBER() OVER (
               PARTITION BY TRIM(transaction_id)
               ORDER BY transaction_id) AS rn
    FROM stg_sales_transactions s
),
typed AS (
    SELECT
        NULLIF(TRIM(transaction_id), '') AS transaction_id,
        NULLIF(TRIM(farmer_id), '') AS farmer_id,
        CASE WHEN TRIM(transaction_date) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
             THEN STR_TO_DATE(TRIM(transaction_date), '%Y-%m-%d') END AS transaction_date,
        NULLIF(TRIM(crop), '') AS crop,
        CASE WHEN TRIM(quantity_kg) REGEXP '^[0-9]+(\\.[0-9]+)?$'
             THEN CAST(TRIM(quantity_kg) AS DECIMAL(12,2)) END AS quantity_kg,
        CASE WHEN TRIM(price_per_kg_kes) REGEXP '^[0-9]+(\\.[0-9]+)?$'
             THEN CAST(TRIM(price_per_kg_kes) AS DECIMAL(12,2)) END AS price_per_kg_kes,
        CASE WHEN TRIM(recorded_total_kes) REGEXP '^[0-9]+(\\.[0-9]+)?$'
             THEN CAST(TRIM(recorded_total_kes) AS DECIMAL(12,2)) END AS recorded_total_kes,
        CASE
            WHEN LOWER(TRIM(payment_status)) IN ('paid', 'complete') THEN 'Paid'
            WHEN LOWER(TRIM(payment_status)) = 'pending' THEN 'Pending'
            WHEN LOWER(TRIM(payment_status)) = 'partially paid' THEN 'Partially paid'
            ELSE NULLIF(TRIM(payment_status), '')
        END AS payment_status,
        NULLIF(TRIM(buyer_type), '') AS buyer_type
    FROM ranked
    WHERE rn = 1
)
SELECT
    transaction_id, farmer_id, transaction_date, crop,
    COALESCE(quantity_kg,
             ROUND(recorded_total_kes / NULLIF(price_per_kg_kes, 0), 2)) AS quantity_kg,
    price_per_kg_kes,
    recorded_total_kes,
    payment_status,
    buyer_type,
    CASE WHEN quantity_kg IS NULL THEN 1 ELSE 0 END AS quantity_recovered_flag,
    CASE WHEN quantity_kg IS NOT NULL
          AND ABS(quantity_kg * price_per_kg_kes - recorded_total_kes) > 1
         THEN 1 ELSE 0 END AS total_mismatch_flag
FROM typed;
DROP TABLE IF EXISTS clean_attendance;

CREATE TABLE clean_attendance AS
WITH ranked AS (
    SELECT a.*,
           ROW_NUMBER() OVER (
               PARTITION BY TRIM(attendance_id)
               ORDER BY attendance_id) AS rn
    FROM stg_training_attendance a
),
typed AS (
    SELECT
        NULLIF(TRIM(attendance_id), '') AS attendance_id,
        NULLIF(TRIM(session_id), '')    AS session_id,
        NULLIF(TRIM(farmer_id), '')     AS farmer_id,
        CASE
            WHEN LOWER(TRIM(attendance_status)) IN ('attended', 'present') THEN 'Attended'
            WHEN LOWER(TRIM(attendance_status)) = 'late'   THEN 'Late'
            WHEN LOWER(TRIM(attendance_status)) = 'absent' THEN 'Absent'
            ELSE NULLIF(TRIM(attendance_status), '')
        END AS attendance_status,
        CASE WHEN TRIM(feedback_score) REGEXP '^[1-5]$'
             THEN CAST(TRIM(feedback_score) AS UNSIGNED) END AS feedback_score
    FROM ranked
    WHERE rn = 1
)
SELECT
    attendance_id, session_id, farmer_id, attendance_status, feedback_score,
    CASE WHEN attendance_status = 'Absent' AND feedback_score IS NOT NULL
         THEN 1 ELSE 0 END AS feedback_status_conflict
FROM typed;
DROP TABLE IF EXISTS clean_adoption;

CREATE TABLE clean_adoption AS
WITH typed AS (
    SELECT
        NULLIF(TRIM(adoption_id), '')   AS adoption_id,
        NULLIF(TRIM(farmer_id), '')     AS farmer_id,
        NULLIF(TRIM(practice_name), '') AS practice_name,
        STR_TO_DATE(NULLIF(TRIM(assessment_date), ''), '%d/%m/%Y') AS assessment_date,
        CASE
            WHEN LOWER(TRIM(adoption_status)) = 'yes'         THEN 'Yes'
            WHEN LOWER(TRIM(adoption_status)) = 'no'          THEN 'No'
            WHEN LOWER(TRIM(adoption_status)) = 'in progress' THEN 'In progress'
            ELSE NULLIF(TRIM(adoption_status), '')
        END AS adoption_status,
        CASE WHEN TRIM(area_under_practice_acres) REGEXP '^[0-9]+(\\.[0-9]+)?$'
             THEN CAST(TRIM(area_under_practice_acres) AS DECIMAL(8,2)) END AS area_under_practice_acres
    FROM stg_practice_adoption
)
SELECT
    adoption_id, farmer_id, practice_name, assessment_date,
    adoption_status, area_under_practice_acres,
    CASE WHEN adoption_status = 'Yes' AND area_under_practice_acres IS NULL
         THEN 1 ELSE 0 END AS adopted_area_missing_flag
FROM typed;
DROP TABLE IF EXISTS clean_sessions;

CREATE TABLE clean_sessions AS
SELECT
    NULLIF(TRIM(session_id), '') AS session_id,
    CASE WHEN TRIM(session_date) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
         THEN STR_TO_DATE(TRIM(session_date), '%Y-%m-%d') END AS session_date,
    CASE
        WHEN LOWER(TRIM(county)) IN ('muranga', 'murang''a') THEN 'Murang''a'
        WHEN LOWER(TRIM(county)) IN ('uasin-gishu', 'uasin gishu') THEN 'Uasin Gishu'
        ELSE CONCAT(UPPER(LEFT(TRIM(county), 1)), LOWER(SUBSTRING(TRIM(county), 2)))
    END AS county,
    NULLIF(TRIM(training_topic), '') AS training_topic,
    NULLIF(TRIM(facilitator), '')    AS facilitator,
    NULLIF(TRIM(delivery_mode), '')  AS delivery_mode
FROM stg_training_sessions;
SELECT county, COUNT(*) FROM clean_sessions GROUP BY county;
SELECT training_topic, COUNT(*) FROM clean_sessions GROUP BY training_topic;
SELECT facilitator, COUNT(*) FROM clean_sessions GROUP BY facilitator;
SELECT 'clean_farmers' AS tbl, COUNT(*) AS n FROM clean_farmers      
UNION ALL SELECT 'clean_sales', COUNT(*) FROM clean_sales           
UNION ALL SELECT 'clean_attendance', COUNT(*) FROM clean_attendance  
UNION ALL SELECT 'clean_adoption', COUNT(*) FROM clean_adoption      
UNION ALL SELECT 'clean_sessions', COUNT(*) FROM clean_sessions;  
SELECT COUNT(*) FROM clean_sales s      LEFT JOIN clean_farmers f ON f.farmer_id = s.farmer_id;
SELECT COUNT(*) FROM clean_attendance a LEFT JOIN clean_farmers f ON f.farmer_id = a.farmer_id;
SELECT COUNT(*) FROM clean_adoption p   LEFT JOIN clean_farmers f ON f.farmer_id = p.farmer_id;   
SELECT 'sales_join (900)' AS check_name, COUNT(*) AS result
FROM clean_sales s LEFT JOIN clean_farmers f ON f.farmer_id = s.farmer_id
UNION ALL
SELECT 'attendance_join (693)', COUNT(*)
FROM clean_attendance a LEFT JOIN clean_farmers f ON f.farmer_id = a.farmer_id
UNION ALL
SELECT 'adoption_join (500)', COUNT(*)
FROM clean_adoption p LEFT JOIN clean_farmers f ON f.farmer_id = p.farmer_id
UNION ALL
SELECT 'paid_count (282)', COUNT(*) FROM clean_sales WHERE payment_status = 'Paid'
UNION ALL
SELECT 'T000067_qty_is_12', COUNT(*) FROM clean_sales
WHERE transaction_id = 'T000067' AND quantity_kg = 12
UNION ALL
SELECT 'mismatch_flags (1)', SUM(total_mismatch_flag) FROM clean_sales
UNION ALL
SELECT 'absent_with_score (~93)', SUM(feedback_status_conflict) FROM clean_attendance
UNION ALL
SELECT 'adopted_area_missing (1)', SUM(adopted_area_missing_flag) FROM clean_adoption
UNION ALL
SELECT 'null_adoption_dates (1)', SUM(assessment_date IS NULL) FROM clean_adoption
UNION ALL
SELECT 'attended (539)', COUNT(*) FROM clean_attendance WHERE attendance_status = 'Attended';