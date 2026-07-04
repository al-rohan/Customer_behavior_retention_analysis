WITH rfm_base AS (
	SELECT 
		customer_id,
		(DATE '2011-12-09' - MAX(invoice_date)) AS recency_days,
	    COUNT(DISTINCT invoice_no) AS frequency,
	    SUM(total_revenue) AS monetary
	FROM customer_transaction_view 
	GROUP BY customer_id 
),
rfm_scores AS (
    SELECT 
        customer_id,
        NTILE(4) OVER (ORDER BY recency_days ASC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary DESC) AS m_score
    FROM rfm_base
)
SELECT 
	s.customer_id ,
	s.r_score ,
	s.f_score ,
	s.m_score ,
	b.monetary AS total_ltv,
	
	CASE 
		WHEN s.r_score IN (3, 4) AND (s.f_score IN (3, 4) OR s.m_score IN (3, 4)) THEN 'VIP'
        WHEN s.r_score IN (1, 2) AND (s.f_score IN (3, 4) OR s.m_score IN (3, 4)) THEN 'At-Risk'
        WHEN s.r_score IN (3, 4) AND (s.f_score IN (1, 2) AND s.m_score IN (1, 2)) THEN 'Potential'
        WHEN s.r_score IN (1, 2) AND (s.f_score IN (1, 2) AND s.m_score IN (1, 2)) THEN 'Lost'
        ELSE 'Other'
	END AS segment
	
FROM rfm_scores s 
JOIN rfm_base b ON s.customer_id = b.customer_id
ORDER BY r_score DESC, f_score DESC, m_score DESC ;