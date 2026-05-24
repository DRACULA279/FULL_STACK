-- Which locations drive the business?

SELECT 
	c.customer_state,
	COUNT(c.customer_unique_id) customers,
	ROUND(COALESCE(SUM(op.payment_value),0)::numeric,2) AS revenue

FROM 
	customers c 
LEFT JOIN 
	orders o
	ON c.customer_id = o.customer_id
LEFT JOIN 
	order_payments op 
	ON op.order_id = o.order_id
	
GROUP BY 1
ORDER BY 3 DESC;

/*

- Revenue was highly concentrated in a few states, with São Paulo (SP) alone contributing ~6M revenue 
and ~43K customers, significantly dominating the marketplace.

- RJ and MG formed the next strongest markets, while most other states contributed relatively small 
customer and revenue shares, indicating uneven geographic penetration.

- Business expansion opportunities likely exist in underpenetrated states, while logistics, seller density,
and customer retention should be prioritized in high-revenue states like SP, RJ, and MG.

*/
