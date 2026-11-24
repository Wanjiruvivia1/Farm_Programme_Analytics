CREATE OR REPLACE VIEW vw_kpi_programme_summary AS
SELECT
    (SELECT COUNT(*) FROM clean_farmers) AS registered_farmers,
    (SELECT COUNT(DISTINCT farmer_id) FROM clean_attendance
      WHERE attendance_status IN ('Attended','Late')) AS farmers_trained,
    (SELECT COUNT(DISTINCT farmer_id) FROM clean_adoption
      WHERE adoption_status = 'Yes') AS farmers_adopting,
    (SELECT SUM(recorded_total_kes) FROM clean_sales) AS total_sales_kes;
-- KPI 1: registered farmers
SELECT COUNT(DISTINCT farmer_id) AS registered_farmers
FROM clean_farmers;
-- KPI 2: attendance rate (Attended + Late) / all records
-- KPI 3: farmers trained (at least one Attended/Late record)
-- KPI 4: adoption rate by practice
SELECT practice_name,
       COUNT(*) AS assessments,
       SUM(adoption_status = 'Yes') AS adopted,
       ROUND(100 * SUM(adoption_status = 'Yes') / COUNT(*), 1) AS adoption_rate_pct
FROM clean_adoption
GROUP BY practice_name
ORDER BY adoption_rate_pct DESC;
-- KPI 5: total sales and sales by crop
SELECT crop,
       COUNT(*) AS transactions,
       SUM(recorded_total_kes) AS total_sales_kes
FROM clean_sales
GROUP BY crop WITH ROLLUP;
SELECT SUM(CAST(recorded_total_kes AS DECIMAL(12,2))) - 2745 AS expected_clean_total
FROM stg_sales_transactions;
-- KPI 6: data quality summary
SELECT 'Duplicate farmers removed' AS issue,
       (SELECT COUNT(*) FROM stg_farmers) - (SELECT COUNT(*) FROM clean_farmers) AS records
UNION ALL SELECT 'Duplicate sales removed',
       (SELECT COUNT(*) FROM stg_sales_transactions) - (SELECT COUNT(*) FROM clean_sales)
UNION ALL SELECT 'Duplicate attendance removed',
       (SELECT COUNT(*) FROM stg_training_attendance) - (SELECT COUNT(*) FROM clean_attendance)
UNION ALL SELECT 'Sales total mismatches flagged', SUM(total_mismatch_flag) FROM clean_sales
UNION ALL SELECT 'Quantities recovered', SUM(quantity_recovered_flag) FROM clean_sales
UNION ALL SELECT 'Absent but scored feedback', SUM(feedback_status_conflict) FROM clean_attendance
UNION ALL SELECT 'Adopted but area missing', SUM(adopted_area_missing_flag) FROM clean_adoption;
CREATE OR REPLACE VIEW vw_kpi_programme_summary AS
SELECT
    (SELECT COUNT(DISTINCT farmer_id) FROM clean_farmers) AS registered_farmers,
    (SELECT COUNT(DISTINCT farmer_id) FROM clean_attendance
      WHERE attendance_status IN ('Attended','Late')) AS farmers_trained,
    (SELECT COUNT(DISTINCT farmer_id) FROM clean_adoption
      WHERE adoption_status = 'Yes') AS farmers_adopting,
    (SELECT SUM(recorded_total_kes) FROM clean_sales) AS total_sales_kes;

CREATE OR REPLACE VIEW vw_kpi_adoption_by_practice AS
SELECT practice_name,
       COUNT(*) AS assessments,
       SUM(adoption_status = 'Yes') AS adopted,
       ROUND(100 * SUM(adoption_status = 'Yes') / COUNT(*), 1) AS adoption_rate_pct
FROM clean_adoption
GROUP BY practice_name;

CREATE OR REPLACE VIEW vw_kpi_sales_by_crop AS
SELECT crop,
       COUNT(*) AS transactions,
       SUM(recorded_total_kes) AS total_sales_kes
FROM clean_sales
GROUP BY crop;
SELECT * FROM vw_kpi_programme_summary;      -- 250, 227, 148, 2327320.00
SELECT * FROM vw_kpi_sales_by_crop;          -- six crops, sum 2327320.00