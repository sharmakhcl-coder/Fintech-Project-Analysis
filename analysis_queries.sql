-- SQL Queries for Transaction Analysis

-- 1 tx by status
SELECT status, COUNT(*) as transaction_count FROM transactions GROUP BY status;

-- 2 captured gmv by merchant
SELECT merchant_name, SUM(amount_usd) as total_captured_gmv FROM transactions WHERE status = 'CAPTURED' GROUP BY merchant_name;

-- 3 top 10 merchants gmv
SELECT merchant_name, SUM(amount_usd) as total_captured_gmv FROM transactions WHERE status = 'CAPTURED' GROUP BY merchant_name ORDER BY total_captured_gmv DESC LIMIT 10;

-- 4 daily gmv and success count
SELECT transaction_date_standardized, SUM(amount_usd) as daily_gmv, COUNT(*) as successful_transaction_count FROM transactions WHERE status = 'CAPTURED' GROUP BY transaction_date_standardized;

-- 5 high chargeback merchants
SELECT merchant_name, (CAST(SUM(CASE WHEN status = 'CHARGEBACK' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 as chargeback_ratio FROM transactions GROUP BY merchant_name HAVING chargeback_ratio > 1;

-- 6 high risk regions
SELECT gateway_region, AVG(risk_score) as avg_risk, COUNT(*) as tx_count FROM transactions GROUP BY gateway_region HAVING avg_risk > 50 AND tx_count > 20;

-- 7 problematic users
SELECT user_id, transaction_date_standardized, COUNT(*) as problematic_tx_count FROM transactions WHERE status IN ('FAILED', 'CHARGEBACK') GROUP BY user_id, transaction_date_standardized HAVING problematic_tx_count >= 3;

-- 8 chargeback details
SELECT merchant_name, COUNT(*) as chargeback_count, COUNT(DISTINCT user_id) as unique_users, SUM(amount_usd) as total_chargeback_amount FROM transactions WHERE status = 'CHARGEBACK' GROUP BY merchant_name;

