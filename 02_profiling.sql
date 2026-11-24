USE farm_programme_analytics;
SHOW TABLES;
USE farm_programme_analytics;
SELECT 'stg_farmers' AS table_name, COUNT(*) AS row_count FROM stg_farmers
UNION ALL
SELECT 'stg_practice_adoption', COUNT(*) FROM stg_practice_adoption
UNION ALL
SELECT 'stg_sales_transactions', COUNT(*) FROM stg_sales_transactions
UNION ALL
SELECT 'stg_training_attendance', COUNT(*) FROM stg_training_attendance
UNION ALL
SELECT 'stg_training_sessions', COUNT(*) FROM stg_training_sessions;

-- After importing CSVs, run the profiling queries in 02_data_profiling.sql.
SELECT * FROM stg_farmers LIMIT 10;
SELECT * FROM stg_practice_adoption LIMIT 10;
SELECT * FROM stg_sales_transactions LIMIT 10;
SELECT * FROM stg_training_attendance LIMIT 10;
SELECT * FROM stg_training_sessions LIMIT 10;
SELECT farmer_id,first_name
FROM stg_farmers;
SELECT * FROM stg_training_sessions LIMIT 5;
SELECT farmer_id,county, primary_crop FROM stg_farmers LIMIT 15;
SELECT farmer_id, COUNT(*) AS duplicate_count
FROM stg_farmers
GROUP BY farmer_id
HAVING COUNT(*)>1;
SELECT
     COUNT(*) AS total_records,
     COUNT(DISTINCT farmer_id) AS unique_farmer_ids
FROM stg_farmers;
SELECT COUNT(*)FROM stg_farmers;
SELECT DATABASE();
SHOW TABLES;
SELECT * FROM stg_farmers LIMIT 10;
SELECT 'stg_farmers' AS table_name, COUNT(*) AS row_count FROM stg_farmers
UNION ALL
SELECT 'stg_practice_adoption', COUNT(*) FROM stg_practice_adoption
UNION ALL
SELECT 'stg_sales_transactions', COUNT(*) FROM stg_sales_transactions
UNION ALL
SELECT 'stg_training_attendance', COUNT(*) FROM stg_training_attendance
UNION ALL
SELECT 'stg_training_sessions', COUNT(*) FROM stg_training_sessions;
USE farm_programme_analytics;
SELECT 'stg_farmers' AS table_name, COUNT(*) AS row_count FROM stg_farmers
UNION ALL
SELECT 'stg_practice_adoption', COUNT(*) FROM stg_practice_adoption
UNION ALL
SELECT 'stg_sales_transactions', COUNT(*) FROM stg_sales_transactions
UNION ALL
SELECT 'stg_training_attendance', COUNT(*) FROM stg_training_attendance
UNION ALL
SELECT 'stg_training_sessions', COUNT(*) FROM stg_training_sessions;
USE farm_programme_analytics;
SELECT farmer_id, Count(*) as times_seen
FROM stg_farmers
GROUP BY farmer_id
HAVING times_seen> 1;
SELECT COUNT(*) AS total_records,
	   COUNT(DISTINCT farmer_id) as unique_farmer_ids
FROM stg_farmers;
SELECT 
		first_name,
        last_name,
        phone_number,
        COUNT(*) as times_seen
FROM stg_farmers
GROUP BY
		first_name,
        last_name,
        phone_number
HAVING times_seen>1;
SELECT *
FROM stg_farmers
WHERE phone_number IS NULL
		OR phone_number='';
SELECT 
	 stg_sales_transactions.transaction_id,
     stg_sales_transactions.farmer_id
FROM stg_sales_transactions
LEFT JOIN stg_farmers
		ON stg_farmers.farmer_id=stg_sales_transactions.farmer_id
WHERE stg_farmers.farmer_id IS NULL;
SELECT 	phone_number, LENGTH(phone_number) AS len
FROM stg_farmers
LIMIT 15;
SELECT 
            s.farmer_id,
			COUNT(*) as total_sales
FROM stg_sales_transactions s
LEFT JOIN stg_farmers f ON
	s.farmer_id=f.farmer_id
GROUP BY s.farmer_id
HAVING total_sales>3;
SELECT *
FROM stg_farmers
WHERE phone_number IS NULL OR TRIM(phone_number)='';
SELECT
  SUM(date_of_birth LIKE '%/%') AS slash_dob,
  SUM(registration_date LIKE '%/%') AS slash_reg,
  SUM(date_of_birth NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$') AS non_iso_dob
FROM stg_farmers;
SELECT 
	  lower(trim(county)),
      count(*) as total_values
FROM stg_farmers
GROUP BY lower(trim(county))
ORDER BY total_values DESC;
SELECT 
	  county,
      count(*) as total_values
FROM stg_farmers
WHERE lower(county) like '%uasin%'
GROUP BY county
ORDER BY total_values DESC;
SELECT 
		county,
        count(*) as total_values
FROM stg_farmers
WHERE county like 'Uasin%'
GROUP BY county;
USE farm_programme_analytics;
SELECT
		farmer_id,
        first_name,
        last_name
FROM stg_farmers
WHERE gender='' or farm_size_acres='';
SELECT COUNT(*) FROM stg_sales_transactions;

SELECT COUNT(*)
FROM stg_sales_transactions s
LEFT JOIN stg_farmers f ON f.farmer_id = s.farmer_id;
SELECT a.attendance_id, a.farmer_id
FROM stg_training_attendance a
LEFT JOIN stg_farmers f ON f.farmer_id = a.farmer_id
WHERE f.farmer_id IS NULL;
SELECT
	transaction_id,
    count(*) as total_times
FROM stg_sales_transactions
GROUP BY transaction_id
HAVING total_times>1;
SELECT
		quantity_kg,
        price_per_kg_kes,
        recorded_total_kes,
        CAST(quantity_kg AS DECIMAL(12,2)) *
        CAST(price_per_kg_kes AS DECIMAL(12,2)) AS calculated_total
FROM stg_sales_transactions
LIMIT 20;
SELECT
		transaction_id,
		CAST(quantity_kg AS DECIMAL(12,2))*
        CAST(price_per_kg_kes AS DECIMAL(12,2)) AS calculated_total,
        CAST(recorded_total_kes AS DECIMAL(12,2)) AS recorded_total
FROM stg_sales_transactions
WHERE
		CAST(quantity_kg AS DECIMAL(12,2))*
        CAST(price_per_kg_kes AS DECIMAL(12,2))
        <>
        CAST(recorded_total_kes AS DECIMAL(12,2));
SELECT
			transaction_id,
            quantity_kg,
            price_per_kg_kes,
            recorded_total_kes,
            CAST(quantity_kg AS DECIMAL(12,2))*
            CAST(price_per_kg_kes AS DECIMAL(12,2)) AS calculated_total_kes,
            ABS(
            CAST(quantity_kg AS DECIMAL(12,2))*CAST(price_per_kg_kes AS DECIMAL(12,2))
            -
            CAST(recorded_total_kes AS DECIMAL(12,2))
            ) AS DIFFERENCE
FROM stg_sales_transactions
WHERE ABS(
			CAST(quantity_kg AS DECIMAL(12,2))*
            CAST(price_per_kg_kes AS DECIMAL(12,2))
            -
            CAST(recorded_total_kes AS DECIMAL(12,2))
            )>1
LIMIT 5;
SELECT DISTINCT crop
FROM stg_sales_transactions
ORDER BY crop;
SELECT DISTINCT buyer_type
FROM stg_sales_transactions
ORDER BY buyer_type;
SELECT DISTINCT payment_status
FROM stg_sales_transactions
ORDER BY payment_status;
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT transaction_id) AS unique_ids
FROM stg_sales_transactions;
SELECT COUNT(*) FROM stg_sales_transactions
WHERE TRIM(recorded_total_kes) = '' OR recorded_total_kes IS NULL
   OR TRIM(quantity_kg) = '' OR TRIM(price_per_kg_kes) = '';
SELECT crop, COUNT(*) AS n
FROM stg_sales_transactions
GROUP BY crop
ORDER BY n DESC;
SELECT COUNT(*) AS original_count
FROM stg_sales_transactions;
SELECT COUNT(*) AS joined_count
FROM stg_sales_transactions s
LEFT JOIN stg_farmers f
    ON s.farmer_id = f.farmer_id;
SELECT
    ta.*
FROM stg_training_attendance ta
LEFT JOIN stg_farmers f
    ON ta.farmer_id = f.farmer_id
WHERE f.farmer_id IS NULL;
SELECT COUNT(*)
FROM stg_sales_transactions
WHERE farmer_id='F0011';
SELECT farmer_id,
	   count(*) as total_sales
FROM stg_sales_transactions
GROUP BY farmer_id
ORDER BY total_sales DESC;
SELECT
    farmer_id,
    COUNT(*) AS occurrences
FROM stg_farmers
GROUP BY farmer_id
HAVING COUNT(*) > 1;
SELECT COUNT(*)
FROM stg_sales_transactions s
LEFT JOIN stg_farmers f ON f.farmer_id = s.farmer_id
WHERE s.farmer_id = 'F0011';
SELECT
		crop,
        count(*) as crops
FROM stg_sales_transactions
GROUP BY crop
ORDER BY crops DESC;
SELECT
		payment_status,
        count(*) as payment_status_count
FROM stg_sales_transactions
GROUP BY payment_status
ORDER BY payment_status_count DESC;
SELECT
		buyer_type,
        count(*) as buyer_type_count
FROM stg_sales_transactions
GROUP BY buyer_type
ORDER BY buyer_type_count DESC;
SELECT p.adoption_id, p.farmer_id
FROM stg_practice_adoption p
LEFT JOIN stg_farmers f ON f.farmer_id = p.farmer_id
WHERE f.farmer_id IS NULL;

SELECT a.attendance_id, a.session_id
FROM stg_training_attendance a
LEFT JOIN stg_training_sessions s ON s.session_id = a.session_id
WHERE s.session_id IS NULL;
SELECT transaction_id, quantity_kg, price_per_kg_kes, recorded_total_kes,
       CAST(quantity_kg AS DECIMAL(12,2)) * CAST(price_per_kg_kes AS DECIMAL(12,2)) AS calculated_total
FROM stg_sales_transactions
WHERE transaction_id IN ('T000018', 'T000067');
SELECT COUNT(*) AS discrepancy_rows
FROM stg_sales_transactions
WHERE ABS(CAST(quantity_kg AS DECIMAL(12,2)) * CAST(price_per_kg_kes AS DECIMAL(12,2))
        - CAST(recorded_total_kes AS DECIMAL(12,2))) > 1;
SELECT *
FROM stg_sales_transactions
WHERE transaction_id = 'T000018';
SELECT MIN(CAST(price_per_kg_kes AS DECIMAL(12,2))) AS min_price,
       AVG(CAST(price_per_kg_kes AS DECIMAL(12,2))) AS avg_price,
       MAX(CAST(price_per_kg_kes AS DECIMAL(12,2))) AS max_price
FROM stg_sales_transactions
WHERE crop = 'Onions';
SELECT *
FROM stg_sales_transactions
WHERE transaction_id IS NULL
   OR TRIM(transaction_id) = '';
SELECT transaction_id, LENGTH(transaction_id) AS len, COUNT(*) AS n
FROM stg_sales_transactions
GROUP BY transaction_id, LENGTH(transaction_id)
ORDER BY len DESC, n DESC
LIMIT 10;
SELECT *
FROM stg_sales_transactions
WHERE transaction_id = 'T000009';
SELECT MIN(CAST(quantity_kg AS DECIMAL(12,2))) AS min_qty,
       AVG(CAST(quantity_kg AS DECIMAL(12,2))) AS avg_qty,
       MAX(CAST(quantity_kg AS DECIMAL(12,2))) AS max_qty
FROM stg_sales_transactions
WHERE crop = 'Onions' AND TRIM(quantity_kg) <> '';
SELECT * FROM stg_sales_transactions WHERE payment_status = 'complete';
-- Adoption farmers not in the farmers table
SELECT p.adoption_id, p.farmer_id
FROM stg_practice_adoption p
LEFT JOIN stg_farmers f ON f.farmer_id = p.farmer_id
WHERE f.farmer_id IS NULL;

-- Attendance sessions not in the sessions table
SELECT a.attendance_id, a.session_id
FROM stg_training_attendance a
LEFT JOIN stg_training_sessions s ON s.session_id = a.session_id
WHERE s.session_id IS NULL;
-- Check 17: total rows vs unique attendance_id
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT attendance_id) AS unique_ids
FROM stg_training_attendance;
-- Check 17a: duplicated attendance_id
SELECT attendance_id, COUNT(*) AS times_seen
FROM stg_training_attendance
GROUP BY attendance_id
HAVING COUNT(*) > 1;
-- Check 17b: missing attendance_id
SELECT *
FROM stg_training_attendance
WHERE attendance_id IS NULL OR TRIM(attendance_id) = '';

-- Check 18: attendance_status values
SELECT attendance_status, COUNT(*) AS n
FROM stg_training_attendance
GROUP BY attendance_status
ORDER BY n DESC;
-- Check 19: feedback_score values
SELECT feedback_score, COUNT(*) AS n
FROM stg_training_attendance
GROUP BY feedback_score
ORDER BY n DESC;
-- Check 20: total rows vs unique adoption_id
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT adoption_id) AS unique_ids
FROM stg_practice_adoption;
-- Check 21: practice_name values
SELECT practice_name, COUNT(*) AS n
FROM stg_practice_adoption
GROUP BY practice_name
ORDER BY n DESC;
-- Check 22: adoption_status values
SELECT adoption_status, COUNT(*) AS n
FROM stg_practice_adoption
GROUP BY adoption_status
ORDER BY n DESC;
-- Check 23: blank or non-numeric area
SELECT adoption_id, farmer_id, area_under_practice_acres
FROM stg_practice_adoption
WHERE area_under_practice_acres IS NULL
   OR TRIM(area_under_practice_acres) = ''
   OR TRIM(area_under_practice_acres) NOT REGEXP '^[0-9]+(\\.[0-9]+)?$';
   -- Check 24: sessions, duplicate IDs and delivery modes
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT session_id) AS unique_ids
FROM stg_training_sessions;

SELECT delivery_mode, COUNT(*) AS n
FROM stg_training_sessions
GROUP BY delivery_mode
ORDER BY n DESC;
-- Check 25: non-ISO dates in farmers (expect F0036's 'not_recorded')
SELECT farmer_id, date_of_birth, registration_date
FROM stg_farmers
WHERE date_of_birth NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
   OR registration_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';
-- Check 26: blank feedback by attendance status
SELECT attendance_status,
       SUM(TRIM(feedback_score) = '') AS blank_feedback,
       COUNT(*) AS total
FROM stg_training_attendance
GROUP BY attendance_status;
-- Check 27: blank area by adoption status
SELECT adoption_status,
       SUM(area_under_practice_acres IS NULL OR TRIM(area_under_practice_acres) = '') AS blank_area,
       COUNT(*) AS total
FROM stg_practice_adoption
GROUP BY adoption_status;
-- Check 28: adopted but no area recorded
SELECT *
FROM stg_practice_adoption
WHERE adoption_status = 'Yes'
  AND (area_under_practice_acres IS NULL OR TRIM(area_under_practice_acres) = '');
-- Check 29: exact-case status values
SELECT BINARY adoption_status AS status_exact, COUNT(*) AS n
FROM stg_practice_adoption
GROUP BY BINARY adoption_status;

-- Check 30: date formats in adoption
SELECT SUM(assessment_date LIKE '%/%') AS slash_dates,
       SUM(assessment_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$') AS iso_dates,
       COUNT(*) AS total
FROM stg_practice_adoption;
-- Check 31: non-ISO dates in sales, sessions
SELECT 'sales' AS tbl, COUNT(*) AS non_iso
FROM stg_sales_transactions
WHERE transaction_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
UNION ALL
SELECT 'sessions', COUNT(*)
FROM stg_training_sessions
WHERE session_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';
SELECT * FROM stg_training_attendance WHERE attendance_id = 'A00005';
-- Dedupe test: show only the surplus copies
WITH ranked AS (
    SELECT f.*,
           ROW_NUMBER() OVER (PARTITION BY farmer_id ORDER BY farmer_id) AS rn
    FROM stg_farmers f
)
SELECT *
FROM ranked
WHERE rn > 1;
-- Check 29: exact-case adoption_status
SELECT BINARY adoption_status AS status_exact, COUNT(*) AS n
FROM stg_practice_adoption
GROUP BY BINARY adoption_status;

-- Check 30: which adoption dates are not ISO?
SELECT adoption_id, assessment_date
FROM stg_practice_adoption
WHERE assessment_date NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';
-- Check 32: confirm DD/MM/YYYY (expect 0 rows with month > 12)
SELECT adoption_id, assessment_date
FROM stg_practice_adoption
WHERE assessment_date LIKE '%/%'
  AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(assessment_date, '/', 2), '/', -1) AS UNSIGNED) > 12;
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