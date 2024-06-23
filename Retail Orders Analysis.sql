use retail_orders_db;

show tables;

select * from orders_df;

-- Changing the data type of order_date column from datetime to date
alter table orders_df 
modify column order_date date;

-- 1. Finding the top 10 highest revenue generating products

select product_id, sum(sale_price) as sales
from orders_df
group by product_id
order by sales desc
limit 10;

-- 2. Finding the top 10 highest profit generating products

select product_id, sum(profit) as profit
from orders_df
group by product_id
order by profit desc
limit 10;

-- 3. Finding top 5 highest selling products in each region

with cte as (
    select region, product_id, sum(sale_price) as sales
	from orders_df
	group by region, product_id
    )
	select * from 
		(select *, row_number() over(partition by region order by sales desc) as rn
		from cte) A 
	where rn <= 5;
            
-- 4. Finding month over month growth comparison for 2022 and 2023 sales. eg - Jan 2022 vs Jan 2023

with cte as (
	select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales
	from orders_df
	group by year(order_date), month(order_date)
	)
select order_month, 
	sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
    sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- 5. For each category which month had the highest sales

with cte as (
	select category, date_format(order_date, "%Y %M") as order_year_month, sum(sale_price) as sales 
	from orders_df
	group by category, order_year_month
	)
    select * from 
		(select *, row_number() over (partition by category order by sales desc) as rn
		from cte) a
	where rn = 1;
    
-- 6. Which sub-category had the highest growth by profit in 2023 compared to 2022?
    
with cte as (
	select sub_category, year(order_date) as order_year, sum(sale_price) as sales
	from orders_df
	group by sub_category, year(order_date)
	)
    
	, cte2 as (
	select sub_category, 
		sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
		sum(case when order_year = 2023 then sales else 0 end) as sales_2023
	from cte
	group by sub_category
	)
    
select *, (sales_2023 - sales_2022)*100 / sales_2022 as growth_percentage
from cte2
order by growth_percentage desc
limit 1;