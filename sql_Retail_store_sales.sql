/* 1. Which customer segments (by age group and gender) generate the highest value for the business? */

SELECT
	CASE
    	WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 then '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 and 70 THEN '60-70'
        ELSE 'unknown_age' END AS age_ranges ,
        gender,
	ROUND(SUM(amount), 2) AS total_revenue,
    COUNT(*) AS total_order,
    ROUND((SUM(amount) / COUNT(*)), 2) AS AOV
FROM cleaned_data
GROUP BY 1,2 ORDER BY 3 DESC;

/*--------------------------------------------------------------------------------------------------------------*/

/* 2. Which product categories and items perform best in each season? */

WITH season_sales AS (
SELECT
	season,
    category,
    itempurchased AS item,
    SUM(amount) AS total_revenue,
    COUNT(*) AS total_order,
    ROUND((SUM(amount) / COUNT(*)), 2) AS AOV,
    ROW_NUMBER() OVER(
      PARTITION BY season ORDER BY SUM(amount) DESC
      ) AS item_rank
FROM cleaned_data
GROUP BY 1, 2
  )

SELECT
	season,
    category,
    item,
    total_revenue,
    total_order,
    AOV
FROM season_sales
WHERE item_rank = 1;

/*--------------------------------------------------------------------------------------------------------------*/

/* 3. How do different age segments differ in purchase behavior and satisfaction, and which segment should we prioritize? */

WITH review_age_ranges AS (
SELECT
	CASE
    	WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 then '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 and 70 THEN '60-70'
        ELSE 'unknown_age' END AS age_range,
	ROUND(SUM(amount), 2) AS total_revenue,
    COUNT(*) AS total_order,
    ROUND((SUM(amount) / COUNT(*)), 2) AS AOV,
    ROUND(AVG(itemrating), 2) AS average_rating
FROM cleaned_data
GROUP BY 1
  )
  
SELECT
	age_range,
    total_revenue,
    total_order,
    AOV,
    average_rating
FROM review_age_ranges
ORDER BY 1 ;

/*--------------------------------------------------------------------------------------------------------------*/

/* 4. Which gender has the highest purchase frequency and customer value? */

SELECT
	gender,
    SUM(amount) AS total_revenue,
    COUNT(*) AS total_order,
    ROUND((SUM(amount) / COUNT(*)), 2) AS AOV,
	(SUM(previouspurchase) + 1) AS frequency
FROM cleaned_data
GROUP BY 1 ORDER BY 2 DESC;

/*--------------------------------------------------------------------------------------------------------------*/

/* 5. Which categories or items have high purchase volume but low customer ratings and need service improvement? */

SELECT
	category,
    itempurchased AS item,
    ROUND(SUM(amount), 2)  AS total_revenue,
    ROUND(COUNT(*)) AS total_order,
    ROUND(AVG(itemrating), 2) AS average_rating_item
FROM cleaned_data
GROUP BY 1, 2 
HAVING AVG(itemrating) < 4
ORDER BY 4 DESC;

/*--------------------------------------------------------------------------------------------------------------*/

/* 	6. What level of discount is most effective in increasing customer purchases? */

WITH discount_ranges AS (
SELECT
	CASE
    	when discountapplied BETWEEN 0 and 12 THEN '0-12 %'
        WHEN discountapplied BETWEEN 13 AND 24 THEN '13-24 %'
        WHEN discountapplied BETWEEN 25 and 36 then '25-36 %'
        ELSE 'unknown_discount' END AS discount_range_percent,
	ROUND(SUM(amount), 2) AS total_revenue,
    COUNT(*) AS total_order,
    ROUND((SUM(amount) / COUNT(*)), 2) AS AOV
FROM cleaned_data
GROUP BY 1 ORDER BY 2 DESC
  )

SELECT
	discount_range_percent,
    total_revenue,
    total_order,
    AOV
FROM discount_ranges
ORDER BY 2 DESC limit 1;

/*--------------------------------------------------------------------------------------------------------------*/

/* 7. Which payment method is associated with the highest customer satisfaction? */

SELECT
	paymentmethod AS payment_method,
    ROUND(AVG(itemrating), 2) AS average_rating_method
FROM cleaned_data
GROUP BY 1 ORDER BY 2 DESC;
    
/*--------------------------------------------------------------------------------------------------------------*/

/* 8. Which season generates the highest business performance and deserves more investment? */

SELECT
	season,
    SUM(amount) AS total_revenue,
    COUNT(*) AS total_order,
    ROUND((SUM(amount) / COUNT(*)), 2) AS AOV
FROM cleaned_data
GROUP BY 1 ORDER BY 2 DESC LIMIT 1;
