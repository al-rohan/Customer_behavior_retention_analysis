CREATE VIEW customer_transaction_view AS 
	SELECT 
	    "CustomerID" AS customer_id,
	    "InvoiceNo" AS invoice_no,
	    TO_TIMESTAMP("InvoiceDate", 'MM/DD/YYYY HH24:MI'):: date AS invoice_date,
	    MIN(TO_TIMESTAMP("InvoiceDate", 'MM/DD/YYYY HH24:MI'):: date) OVER(PARTITION BY "CustomerID") AS first_purchase_date,
	    MAX(TO_TIMESTAMP("InvoiceDate", 'MM/DD/YYYY HH24:MI')::date) OVER(PARTITION BY "CustomerID") AS last_purchase_date,
	    "Quantity" AS quantity,
	    "UnitPrice" AS unitprice,
	    ROUND(("Quantity" * "UnitPrice")::numeric, 2) AS total_revenue
	FROM "data" 
	WHERE "CustomerID" IS NOT NULL 
	  AND "Quantity" > 0
	 ORDER BY invoice_date ,customer_id

