-- Farm Programme Performance Analytics
-- MySQL 8.0 | Start by loading CSVs into staging tables.
CREATE DATABASE IF NOT EXISTS farm_programme_analytics;
USE farm_programme_analytics;

-- Raw staging tables intentionally use VARCHAR so imperfect source values can be imported.
DROP TABLE IF EXISTS stg_farmers;
CREATE TABLE stg_farmers (
  farmer_id VARCHAR(20), first_name VARCHAR(100), last_name VARCHAR(100),
  gender VARCHAR(30), date_of_birth VARCHAR(30), county VARCHAR(100),
  sub_county VARCHAR(100), registration_date VARCHAR(30),
  farm_size_acres VARCHAR(30), primary_crop VARCHAR(50), phone_number VARCHAR(30)
);

DROP TABLE IF EXISTS stg_training_sessions;
CREATE TABLE stg_training_sessions (
  session_id VARCHAR(20), session_date VARCHAR(30), county VARCHAR(100),
  training_topic VARCHAR(100), facilitator VARCHAR(100), delivery_mode VARCHAR(100)
);

DROP TABLE IF EXISTS stg_training_attendance;
CREATE TABLE stg_training_attendance (
  attendance_id VARCHAR(20), session_id VARCHAR(20), farmer_id VARCHAR(20),
  attendance_status VARCHAR(30), feedback_score VARCHAR(30)
);

DROP TABLE IF EXISTS stg_practice_adoption;
CREATE TABLE stg_practice_adoption (
  adoption_id VARCHAR(20), farmer_id VARCHAR(20), practice_name VARCHAR(100),
  assessment_date VARCHAR(30), adoption_status VARCHAR(30),
  area_under_practice_acres VARCHAR(30)
);

DROP TABLE IF EXISTS stg_sales_transactions;
CREATE TABLE stg_sales_transactions (
  transaction_id VARCHAR(30), farmer_id VARCHAR(20), transaction_date VARCHAR(30),
  crop VARCHAR(50), quantity_kg VARCHAR(30), price_per_kg_kes VARCHAR(30),
  recorded_total_kes VARCHAR(30), payment_status VARCHAR(30), buyer_type VARCHAR(50)
);

-- After importing CSVs, run the profiling queries in 02_data_profiling.sql.
