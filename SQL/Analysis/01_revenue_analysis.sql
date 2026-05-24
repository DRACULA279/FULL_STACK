
-----------------------------REVENUE GROWTH ANALYSIS--------------------------------------

-- How is revenue changing over time?

SELECT
    TO_CHAR(o.order_purchase_timestamp,'MM YYYY') AS order_month,
    ROUND(COALESCE(SUM(op.payment_value),0)::numeric,2) AS revenue

FROM orders o

LEFT JOIN order_payments op
    ON o.order_id = op.order_id

WHERE
    o.order_purchase_timestamp < '2018-09-02'

GROUP BY 1
ORDER BY MIN(o.order_purchase_timestamp);

/*

- Olist experienced strong revenue growth initially, shifting from a hypergrowth phase (2016–2017) 
toward a more mature and stable growth phase during 2018.

- Seasonal events significantly impacted revenue, with a major spike observed in Nov 2017, likely 
driven by Black Friday and holiday shopping demand.

- Revenue stabilized during 2018; Sep/Oct 2018 were excluded due to incomplete transactional data. 
Business should prepare inventory/logistics before seasonal campaigns and focus more on 
retention + operational efficiency as growth matures.

*/


--What products/categories structurally drive revenue?

SELECT
	pt.product_category_name_english AS category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(COALESCE(SUM(oi.price),0)::numeric,2) AS revenue
	
FROM orders o

LEFT JOIN order_items oi
    ON oi.order_id = o.order_id

LEFT JOIN products p
    ON p.product_id = oi.product_id

LEFT JOIN product_category_name_translation pt
    ON pt.product_category_name = p.product_category_name

WHERE
    o.order_purchase_timestamp < '2018-09-02'

GROUP BY 1

ORDER BY revenue DESC;


/*

- watches_gifts, bed_bath_table, health_beauty, and sports_leisure emerged as major revenue-driving 
categories.

- Revenue was diversified across both premium and recurring-demand categories rather than relying on 
a single product segment.

- High-order categories likely acted as customer acquisition and recurring-demand drivers for the marketplace.

*/



-- Which categories structurally drive the business — stable core, premium scalable, or seasonal?

WITH category_metrics AS 
(
    SELECT
        pt.product_category_name_english AS category,
        DATE_TRUNC('month',o.order_purchase_timestamp) AS order_month,
        COUNT(DISTINCT o.order_id) AS total_orders,
		ROUND(COALESCE(SUM(oi.price),0)::numeric,2) AS revenue

    FROM orders o

    LEFT JOIN order_items oi
        ON oi.order_id = o.order_id

    LEFT JOIN products p
        ON p.product_id = oi.product_id

    LEFT JOIN product_category_name_translation pt
        ON pt.product_category_name = p.product_category_name
		
    WHERE
        o.order_purchase_timestamp < '2018-09-02'
    GROUP BY 1,2
)

SELECT
    category,
    ROUND(AVG(revenue)::numeric,2) AS avg_monthly_revenue,
	ROUND(STDDEV(revenue)::numeric,2) AS revenue_volatility,
    ROUND(AVG(revenue / NULLIF(total_orders,0))::numeric,2) AS avg_order_value,
    COUNT(order_month) AS active_months
FROM category_metrics
GROUP BY 1
ORDER BY avg_monthly_revenue DESC;


/*

- bed_bath_table, sports_leisure, and health_beauty acted as stable recurring-demand categories 
with consistent monthly revenue.

- watches_gifts combined high revenue, high AOV, and strong activity, making it the strongest premium-scalable
category.

- Volatile categories depended more on seasonal/campaign demand, requiring better inventory and logistics 
planning.

*/

--------------------------------------------------------------------------------------------------------------

/*

SKU clustering
inventory analytics
catalog optimization
assortment strategy
merchandising science

DEEPER ANALYSIS IN FUTURE. 

*/



	
	