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


-- Which categories are genuinely premium and which are skewed by outliers?

SELECT
    pt.product_category_name_english AS category,
    ROUND(AVG(oi.price)::numeric,2) AS mean_price,
    ROUND(PERCENTILE_CONT(0.5)WITHIN GROUP (ORDER BY oi.price)::numeric,2) AS median_price,
    ROUND(PERCENTILE_CONT(0.25)WITHIN GROUP (ORDER BY oi.price)::numeric,2) AS q1_price,
    ROUND(PERCENTILE_CONT(0.75)WITHIN GROUP (ORDER BY oi.price)::numeric,2) AS q3_price,
    ROUND(MAX(oi.price)::numeric,2) AS max_price

FROM order_items oi

LEFT JOIN products p
    ON p.product_id = oi.product_id

LEFT JOIN product_category_name_translation pt
    ON pt.product_category_name =
       p.product_category_name

GROUP BY 1
ORDER BY mean_price DESC;

/*

- Categories like computers and small_appliances_home_oven_and_coffee showed genuinely premium 
pricing behavior with mean prices close to median prices, indicating consistently high-priced 
products rather than outlier-driven inflation.

- Categories such as watches_gifts and computers_accessories combined strong monetization with 
broader pricing ranges, suggesting scalable premium/mixed-tech demand across multiple customer 
segments rather than dependence on a few luxury products.

- Stable mass-market categories like bed_bath_table, housewares, and sports_leisure maintained 
lower but more consistent pricing structures, likely acting as recurring-demand and volume-driving 
categories for the marketplace.

*/