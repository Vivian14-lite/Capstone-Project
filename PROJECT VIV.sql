CREATE TABLE customers ( 
	customer_id VARCHAR (20) PRIMARY KEY,
	company_name VARCHAR (100),
	contact_name VARCHAR (100),
	contact_title VARCHAR (50),
	city VARCHAR(50),
	country VARCHAR (50)
	);

	CREATE TABLE products (
		product_id INT PRIMARY KEY,
		product_name VARCHAR (50),
		quantity_perunit VARCHAR(100),
		unit_price NUMERIC (10,2),
		discontinued INT,
		category_id NUMERIC (10,2)
	);

	CREATE TABLE categories (
		category_id INT PRIMARY KEY,
		category_name VARCHAR (20),
		description VARCHAR (200)
	);

	CREATE TABLE employees (
		employee_id INT PRIMARY KEY,
		employee_name VARCHAR (20),
		title VARCHAR (30),
		city VARCHAR (20),
		country VARCHAR (10),
		report_To INT
	);

	CREATE TABLE shippers (
		shipper_id INT PRIMARY KEY,
		company_name VARCHAR (100)
	);

	CREATE TABLE orders (
		order_id INT PRIMARY KEY,
		customer_id VARCHAR (20) REFERENCES customers(customer_id),
		employee_id INT REFERENCES employees (employee_id),
		order_date DATE,
		requried_date DATE,
		shipped_date DATE,
		shipper_id INT REFERENCES shippers (shipper_id),
		freight NUMERIC (10,2)
	);

	CREATE TABLE orders_details (
		order_id INT REFERENCES orders (order_id),
		product_id INT REFERENCES products(product_id),
		quantity INT,
		discount NUMERIC(10,2)
);

ALTER TABLE public.shippers
ALTER COLUMN company_name TYPE VARCHAR (100);

ALTER TABLE products
ALTER COLUMN quantity_perunit TYPE VARCHAR(100);


1./*How have total orders and revenue changed over time,
and are there any noticeable sales trends?*/

SELECT
COUNT(DISTINCT o.order_id) AS total_orders,
SUM(quantity * unit_price) AS total_revenue,
EXTRACT(YEAR FROM order_date) AS sales_year,
EXTRACT(MONTH FROM order_date) AS sales_month
FROM orders AS o
INNER JOIN orders_details AS od
	ON o.order_id = od.order_id
INNER JOIN products AS p
	ON p.product_id = od.product_id
GROUP BY EXTRACT(YEAR FROM order_date),  
		EXTRACT(MONTH FROM order_date) 
ORDER BY sales_year,
		sales_month ASC
	
2. --Which products are the best-selling and worst-selling based on sales quantity?

SELECT 
  p.product_name,
SUM(quantity) AS total_quantity_sold
FROM products AS p
INNER JOIN orders_details AS od
    ON p.product_id = od.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC;

3.--Which customers generate the highest number of orders and contribute the most revenue?

SELECT 
contact_name,
MAX(DISTINCT o.order_id) AS highest_orders,
SUM (quantity * unit_price) AS revenue
FROM customers AS c
INNER JOIN orders AS o
	ON c.customer_id = o.customer_id
INNER JOIN orders_details AS od
	ON o.order_id = od.order_id
INNER JOIN products AS p
	ON p.product_id = od.product_id
GROUP BY contact_name,
		o.order_id
ORDER BY highest_orders DESC

4. --Are shipping costs consistent across different shipping providers?
SELECT

SELECT
company_name,
    AVG(freight) AS average_shipping_cost,
    MIN(freight) AS lowest_shipping_cost,
    MAX(freight) AS highest_shipping_cost
FROM orders AS o
INNER JOIN shippers AS s
	ON o.shipper_id = s.shipper_id
GROUP BY (company_name)
ORDER BY average_shipping_cost DESC;


5. /*How efficient is the delivery process, and how many orders are delivered 
on time versus late?*/

SELECT
    order_id,
    requried_date,
    shipped_date,
    CASE
        WHEN shipped_date <= requried_date THEN 'On Time'
        WHEN shipped_date > requried_date THEN 'Late'
        ELSE 'Not Shipped'
    END AS delivery_status
FROM orders;
	