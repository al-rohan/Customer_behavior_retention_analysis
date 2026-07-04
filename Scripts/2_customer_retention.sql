WITH row_num AS (
	SELECT
		customer_id ,
		to_char( date_trunc('quarter' , first_purchase_date ), 'YYYY-"Q"Q') AS cohort_quarter,
		first_purchase_date ,
		last_purchase_date ,
		ROW_NUMBER() OVER (PARTITION BY customer_id  ORDER BY last_purchase_date   DESC) as rn
	
	FROM customer_transaction_view
) , cstmr_status AS (
SELECT 
	customer_id,
	cohort_quarter ,
	last_purchase_date ,
	CASE 
		WHEN last_purchase_date  < (SELECT max(last_purchase_date) FROM customer_transaction_view )- INTERVAL '90 days' THEN 'Churned'
		ELSE 'Active'
	END AS customer_status
	
FROM row_num
WHERE rn = 1 AND 
	first_purchase_date < (SELECT max(last_purchase_date) FROM customer_transaction_view ) - INTERVAL '90 days'
)
SELECT 
    cohort_quarter,
    customer_status ,
    COUNT(customer_id) AS total_customers,
    ROUND(100.0 * COUNT(customer_id) / SUM(COUNT(customer_id)) OVER (PARTITION BY cohort_quarter), 2) AS pct_of_cohort
FROM cstmr_status 
GROUP BY cohort_quarter, customer_status 
ORDER BY cohort_quarter DESC, customer_status ;