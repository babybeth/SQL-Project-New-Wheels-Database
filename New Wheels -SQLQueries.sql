/*Use vehdb as current database*/ 
USE vehdb;

/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/

SELECT 
	state,
    COUNT(customer_id) AS Num_Customers
FROM customer_t 
GROUP BY state
ORDER BY 2 DESC;
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.*/

WITH CUSTOMER_RATING  AS
(
SELECT 
	quarter_number, 
		    CASE 
            WHEN customer_feedback = 'Very Bad' THEN 1
			WHEN customer_feedback = 'Bad' THEN 2
            WHEN customer_feedback = 'Okay' THEN 3
            WHEN customer_feedback = 'Good' THEN 4
            WHEN customer_feedback = 'Very Good' THEN 5
            END AS rating
	FROM order_t
    ) 
    
SELECT 
	CONCAT('Q',quarter_number) AS Quarter,
	AVG(rating) AS 'Avg. Customer Rating'  
    FROM CUSTOMER_RATING
GROUP BY 1
ORDER BY 2 DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
*/


WITH FEEDBACK AS 
(
SELECT quarter_number,
	SUM(CASE WHEN customer_feedback = 'Very Bad' THEN 1 ELSE 0 END) AS Very_Bad,
    SUM(CASE WHEN customer_feedback = 'Bad' THEN 1 ELSE 0 END) AS Bad,
    SUM(CASE WHEN customer_feedback = 'Okay' THEN 1 ELSE 0 END) AS Okay,
    SUM(CASE WHEN customer_feedback = 'Good' THEN 1 ELSE 0 END) AS Good,
    SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) AS Very_Good,
    COUNT(customer_feedback) AS Total_Feedback
    from order_t
    GROUP BY 1)
    
SELECT CONCAT('Q',quarter_number) AS Quarter,
    Very_Bad/Total_Feedback * 100 AS Perc_Very_Bad,
	Bad/Total_Feedback *100 AS Perc_Bad,
	Okay/Total_Feedback *100 AS Perc_Okay,
	Good/Total_Feedback * 100 aS Perc_Good,
	Very_Good/Total_Feedback *100 AS Perc_Very_Good
FROM FEEDBACK
ORDER BY 1;
-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customers?
Hint: For each vehicle make what is the count of the customers.*/

SELECT
	P.vehicle_maker AS VehicleMaker,
    count(O.customer_id) AS Num_Customers 
FROM product_t P inner join order_t O using (product_id)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

SELECT
 state AS State,
	vehicle_maker AS VehicleMaker,
	Num_customers,
	Rnk FROM
 (
SELECT 
	state,
	vehicle_maker,count(customer_id) AS Num_Customers,
	RANK() over (partition by state order by count(customer_id) desc) as Rnk
FROM order_t O INNER JOIN product_t P using(product_id)
INNER JOIN customer_t C using(customer_id)
GROUP BY state,vehicle_maker
ORDER BY state) as Temp
WHERE Rnk =1;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?
Hint: Count the number of orders for each quarter.*/

SELECT 
	CONCAT('Q',quarter_number) AS Quarter,
    count(order_id) AS 'No: of Orders'
from order_t
GROUP BY 1
ORDER BY 1;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
      WITH QUARTER_REVENUE AS
      (
      SELECT 
		quarter_number,
	    SUM(vehicle_price*quantity*(1-discount/100)) AS total_revenue
      FROM order_t
      GROUP BY 1
      )
      
      SELECT 
		CONCAT('Q',quarter_number) AS Quarter,
		total_revenue AS 'Total_revenue',
        (total_revenue-LAG(total_revenue) over (order by quarter_number))/(LAG(total_revenue) over (order by quarter_number))*100 AS 'Revenue_change(%)'
      FROM QUARTER_REVENUE;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?
Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

SELECT 
	CONCAT('Q',quarter_number) AS Quarter,
    sum(vehicle_price*quantity*(1-discount/100)) AS 'Total_Revenue',
    COUNT(order_id) AS Orders
from order_t 
GROUP BY quarter_number
ORDER BY 1;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/
SELECT 
	credit_card_type AS 'Credit Card Type', 
    AVG(discount) FROM order_t INNER JOIN customer_t USING(customer_id)
GROUP BY 1
ORDER BY 2 desc;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

SELECT 
	CONCAT('Q',quarter_number) As Quarter, 
    AVG(DATEDIFF(ship_date,order_date)) AS 'Avg. Days to Ship'
FROM order_t
GROUP BY 1
ORDER BY 1;
-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



