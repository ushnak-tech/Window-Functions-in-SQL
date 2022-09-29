use products;
SELECT 
    *
FROM
    product;
    
desc product;

-- WINDOW FUNCTIONS-- 
-- write a query to display most expensive product under each categroy

-- FIRST_VALUE()

select *, first_value(product_name) over(partition by product_category
order by price desc) as most_exp_prod
from product;

-- display the least expensive product

-- LAST_VALUE()

select *, last_value(product_name) over(partition by product_category order by price desc) as least_exp_prod
from product;

-- WHAT IS A FRAME ?
-- A FRAME IS A SUBSET OF A PARTITION
-- by default sql uses following frame -> range between unbounded preceeding and current row
-- The above query did not fetch results upto our expectations because of the default frame it considered

select *, last_value(product_name) over(partition by product_category order by price desc
range between unbounded preceding and current row) as least_exp_prod
from product;

-- EXPLAINATION --> UNBOUNDED PRECEEDING MEANS THE FIRST ROW OF THE PARTITION AND CURRENT ROW IS THE CURRENT ROW SQL IS ON 
-- FOR EXAMPLE IN THE FOURTH ROW OF THE EARPHONE PARTITION THE UNBOUNDED PRECEEDING IS THE FIRST ROW AND THE CURRENT ROW IS THE FOURTH ROW SO THE RANGE BECOMES 1-4 ROW,SO FOR THE 4TH ROW IT WILL PRINT THE PRODUCT WHERE PRICE IS LEAST.

 -- UNBPUNDED PRECEEDING MEANS ALL THE ROWS PRIO TO THE CURRENT ROW
 
 select *, last_value(product_name) over(partition by product_category order by price desc
range between unbounded preceding and UNBOUNDED following) as least_exp_prod
from product;

select *, last_value(product_name) over(partition by product_category order by price desc
rows between unbounded preceding and current row) as least_exp_prod
from (select *,count(*) over(partition by product_category) total_products from product
limit 20) info;
-- THE DIFFERENCE BETWEEN ROWS AND RANGE IS THAT THE ROWS CLAUSE CONSIDER THE EXACT CURRENT ROW AS THE CURRENT ROW WHILE IN RANGE  WHEN THE PRICE WERE DUPLICATE FOR THE PHONE CATEGORY THE CURRENT ROW DID NOT ACTUALLY ACTED AS THE CURRENT ROW RATHER IT TOOK ALL THE PRODUCTS WITH SAME PRICE RANGE IN ITS ACCOUNT

-- SIMILARLY

 select *, last_value(product_name) over(partition by product_category order by price desc
range between 2 preceding and 3 following) as least_exp_prod
from product;

-- ALTERNATE WAY FOR WRITING WINDOW FUNCTION QUERY

SELECT *, first_value(product_name) over(partition by product_category order by price desc) as most_exp_prod, last_value(product_name) over(partition by product_category order by price desc range between unbounded preceding and unbounded following) as least_exp_prod FROM product;

-- RE-WRITING THIS QUERY-->

SELECT *, 
first_value(product_name) over W as most_exp_prod, 
last_value(product_name) over W as least_exp_prod
FROM product
window W AS 
(partition by product_category order by price desc range between unbounded preceding and unbounded following);


-- WRITE A QUERY TO FETCH THE SECOND EXPENSIVE PRODUCT UNDER EACH CATEGORY

SELECT *,
 nth_value(product_name,2) over (partition by product_category order by price desc range between unbounded preceding and unbounded following) as secondd_most_exp
 from product;
 
 -- WRITE A QUERY TO SEGGREGATE ALL THE EXPENSIVE PHONES, MID RANGE PHONES AND CHEAP PHONES
 -- NTILE()
 
 sELECT product_name, case
 when buckets_= 1 then 'Expensive'
 when buckets_=2 then 'Mid-Range'
 else 'Cheaper'
 end as price_category 
 from (
 SELECT *, NTILE(3) over(order by price desc) as buckets_
 from product 
 where product_category='Phone') as phone_info;
 

 -- NTILE WILL SPLIT THE PRICE COLUMN INTO ALMOST THREE EQUAL BUCKETS 
 
  -- DISPLAY ALL PRODUCTS WHICH CONSTITUTE THE FIRST 30% OF ALL THE VALUES IN TERMS OF PRICE
 -- CUM_DIST()
 
 select product_name, concat(distribution_perc,'%') as percentage
 from(
 SELECT *, 
 cume_dist() over(order by price desc) as distribution,
 round(cume_dist() over(order by price desc)*100,2) as distribution_perc  
 from product) as cume_prod 
 where distribution_perc < 31;
 
 -- PERCENT_RANK()
 
 -- HOW EXPENSIVE IS 'GALAXY Z FOLD 3' COMPAED TO OTHER products
 
 select product_name, _round_percent
 from (
 SELECT *, percent_rank() OVER(ORDER BY price) as percent_,
 round(percent_rank() OVER(ORDER BY price)*100,2) as _round_percent
 from product) x
 where product_name='Galaxy Z Fold 3';
 
 -- example -> iphone 12 pro is 65% costlier than any other item in the table
 
 
 --                               END                             --