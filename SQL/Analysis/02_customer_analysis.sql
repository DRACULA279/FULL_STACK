

----------------------------------------CUSTOMER ANALYSIS---------------------------------------------


-- Is Olist driven more by new customers or repeat customers? 

WITH customer_orders AS 
(

    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders

    FROM customers c

    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
		
    GROUP BY 1
)

SELECT

    COUNT(*) AS total_customers,
    COUNT(CASE WHEN total_orders = 1 THEN 1 END) AS one_time_customers,
    COUNT(CASE WHEN total_orders > 1 THEN 1 END) AS repeat_customers,
    ROUND(100.0 * COUNT(CASE WHEN total_orders > 1 THEN 1 END)
        /
        COUNT(*),2) ||'%' AS repeat_customer_percentage

FROM customer_orders; 

/*

- Olist was heavily acquisition-driven, with only ~3% repeat customers.

- Customer retention appeared weak, indicating growth depended more on acquiring new customers 
than retaining existing ones.

- Improving retention and repeat purchasing could significantly increase customer lifetime value 
and reduce acquisition dependency.

*/


-- How valuable are customers over time?

WITH customer_revenue AS 
(

	SELECT 
		c.customer_unique_id,
		ROUND(COALESCE(SUM(op.payment_value),0)::numeric,2) AS ltv
	FROM 
		customers c 
		
	LEFT JOIN 
		orders o 
		ON c.customer_id = o.customer_id

	LEFT JOIN
		order_payments op 
		ON o.order_id = op.order_id

	GROUP BY 1
	
)

SELECT 
	ROUND(AVG(ltv)::numeric,2) AS avg_cltv,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY ltv)::numeric,2) AS median_cltv,
	ROUND(MAX(ltv)::numeric, 2) AS max_cltv

FROM 
	customer_revenue;

/*

- Average CLTV(Customer Life Time Value) was significantly higher than median CLTV, indicating 
revenue was skewed toward a small group of high-spending customers.

- Most customers generated relatively low lifetime revenue, while a few customers contributed 
disproportionately to total revenue.

- Retaining high-value customers through targeted engagement and personalized marketing could 
improve overall profitability.

*/


-- Which locations drive the business(More customers)?

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    ROUND(COALESCE(SUM(op.payment_value),0)::numeric,2) AS revenue

FROM customers c

LEFT JOIN orders o
    ON c.customer_id = o.customer_id

LEFT JOIN order_payments op
    ON op.order_id = o.order_id

GROUP BY 1

ORDER BY revenue DESC;


/*

- São Paulo (SP) dominated the marketplace in both customers and revenue, showing strong 
geographic concentration.

- RJ and MG formed the next strongest markets, while most states contributed relatively smaller
customer and revenue shares.

- Business expansion opportunities likely exist in underpenetrated regions, while logistics and 
retention efforts should prioritize high-revenue states.

*/

-- How is the customer base growing over time?

--- Monthly new customers

SELECT
    TO_CHAR(DATE_TRUNC('month',first_purchase_date),'MM YYYY') AS month,
    COUNT(*) AS new_customers

FROM
(
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
		
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id

    WHERE
        o.order_purchase_timestamp < '2018-09-02'

    GROUP BY 1

) t

GROUP BY 1
ORDER BY
    MIN(first_purchase_date);
	

--- Monthly active customers

SELECT
    TO_CHAR(DATE_TRUNC('month',o.order_purchase_timestamp),'MM YYYY') AS month,
    COUNT(DISTINCT c.customer_unique_id)AS active_customers

FROM orders o

LEFT JOIN customers c
    ON c.customer_id = o.customer_id

WHERE
    o.order_purchase_timestamp < '2018-09-02'

GROUP BY 1

ORDER BY
    MIN(DATE_TRUNC('month',o.order_purchase_timestamp));


/*

Monthly active customers and new customers followed almost identical trends, showing that 
platform growth was driven primarily by new customer acquisition rather than repeat engagement.


Extremely low repeat behavior (~3% repeat customers) indicates most customers purchased once and 
did not return, revealing weak long-term retention.


Olist’s growth model depended heavily on continuously acquiring new users; improving retention and 
repeat purchasing could significantly improve customer lifetime value and acquisition efficiency.

*/


--- No scope for purchase frequency

-- How fast are customers dissapearing? Are they ever returning? 

SELECT

    c.customer_unique_id,
    DATE_TRUNC('month',MIN(o.order_purchase_timestamp)) AS cohort_month,
    DATE_TRUNC('month',o.order_purchase_timestamp) AS purchase_month

FROM customers c

LEFT JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY c.customer_unique_id,purchase_month

ORDER BY cohort_month, purchase_month;  -- It's getting cmplicated, moving to python -->cohort_analysis.ipynb