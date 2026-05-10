# Transaction Data Analysis Summary

This document outlines the findings from the transaction analysis

## 1 tx by status
**Logic:** Grouping by status to count volumes.

SELECT status, COUNT(*) as transaction_count FROM transactions GROUP BY status;

**Findings:**
| status     |   transaction_count |
|:-----------|--------------------:|
| CAPTURED   |                  19 |
| CHARGEBACK |                   4 |
| FAILED     |                   7 |

## 2 captured gmv by merchant
**Logic:** Summing `amount_usd` for 'CAPTURED' transactions.

SELECT merchant_name, SUM(amount_usd) as total_captured_gmv FROM transactions WHERE status = 'CAPTURED' GROUP BY merchant_name;

**Findings:**
| merchant_name   |   total_captured_gmv |
|:----------------|---------------------:|
| Alpha Mart      |                29985 |
| Beta Stores     |                33431 |
| City Pharma     |                 8640 |
| Delta Travels   |                10300 |

## 3 top 10 merchants gmv
**Logic:** Summing `amount_usd` for 'CAPTURED' transactions.

SELECT merchant_name, SUM(amount_usd) as total_captured_gmv FROM transactions WHERE status = 'CAPTURED' GROUP BY merchant_name ORDER BY total_captured_gmv DESC LIMIT 10;

**Findings:**
| merchant_name   |   total_captured_gmv |
|:----------------|---------------------:|
| Beta Stores     |                33431 |
| Alpha Mart      |                29985 |
| Delta Travels   |                10300 |
| City Pharma     |                 8640 |

## 4 daily gmv and success count
**Logic:** Summing `amount_usd` for 'CAPTURED' transactions.

SELECT transaction_date_standardized, SUM(amount_usd) as daily_gmv, COUNT(*) as successful_transaction_count FROM transactions WHERE status = 'CAPTURED' GROUP BY transac

**Findings:**
| transaction_date_standardized   |   daily_gmv |   successful_transaction_count |
|:--------------------------------|------------:|-------------------------------:|
| 01-03-2026                      |       26382 |                              5 |
| 02-03-2026                      |       11080 |                              3 |
| 03-03-2026                      |       16032 |                              4 |
| 04-03-2026                      |       13920 |                              4 |
| 05-03-2026                      |        6136 |                              1 |
| 06-03-2026                      |        8806 |                              2 |

## 5 high chargeback merchants
**Logic:** Aggregating metrics per merchant/date.

SELECT merchant_name, (CAST(SUM(CASE WHEN status = 'CHARGEBACK' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 as chargeback_ratio FROM transactions GROUP BY merchant_name HAVING chargeback_ratio > 1;

**Findings:**
| merchant_name   |   chargeback_ratio |
|:----------------|-------------------:|
| Alpha Mart      |            9.09091 |
| Beta Stores     |            9.09091 |
| Delta Travels   |           25       |
| Eco Home        |           50       |

## 6 high risk regions
**Logic:** Filtering regions with avg risk > 50 and volume > 20.

SELECT gateway_region, AVG(risk_score) as avg_risk, COUNT(*) as tx_count FROM transactions GROUP BY gateway_region HAVING avg_risk > 50 AND tx_count > 20;

**Findings:**
| gateway_region   |   avg_risk |   tx_count |
|:-----------------|-----------:|-----------:|
| APAC             |    65.4762 |         22 |

## 7 problematic users
**Logic:** Identifying users with 3+ non-captured events in a single day.

SELECT user_id, transaction_date_standardized, COUNT(*) as problematic_tx_count FROM transactions WHERE status IN ('FAILED', 'CHARGEBACK') GROUP BY user_id, transaction_date_standardized HAVING problematic_tx_count >= 3;

**Findings:**
| user_id   | transaction_date_standardized   |   problematic_tx_count |
|:----------|:--------------------------------|-----------------------:|
| U008      | 05-03-2026                      |                      4 |

## 8 chargeback details
**Logic:** Aggregating metrics per merchant/date.

SELECT merchant_name, COUNT(*) as chargeback_count, COUNT(DISTINCT user_id) as unique_users, SUM(amount_usd) as total_chargeback_amount FROM transactions WHERE status = 'CHARGEBACK' GROUP BY merchant_name;

**Findings:**
| merchant_name   |   chargeback_count |   unique_users |   total_chargeback_amount |
|:----------------|-------------------:|---------------:|--------------------------:|
| Alpha Mart      |                  1 |              1 |                      5400 |
| Beta Stores     |                  1 |              1 |                      1711 |
| Delta Travels   |                  1 |              1 |                      2500 |
| Eco Home        |                  1 |              1 |                      6649 |

