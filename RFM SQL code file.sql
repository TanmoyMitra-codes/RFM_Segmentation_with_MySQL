-- first we need to Drop database if exists

-- drop database if exists rfm_sales;

-- Create a new database

create database rfm_sales;
use rfm_sales;


-- now, we are importing data (a CSV file) by using table data import wizerd as table name sample_sales_data
-- now we start exploring data

select * from sample_sales_data
limit 10;

select count(*) from sample_sales_data;

select count( distinct ordernumber) from sample_sales_data;

select
	ordernumber,
    orderlinenumber,
    sample_sales_data.*
from sample_sales_data
order by 1,2;

-- year wise aggregation

select 
year_id as year,
month_id as month,
count(distinct ordernumber) as total_order,
round(sum(sales),2) as total_sales,
round(sum(sales)/count(distinct ordernumber),2) as avg_sales_per_order
from sample_sales_data
group by 1,2
order by 1 desc;

-- now, pivoting the result with case when

select 
month_id as month,
count(distinct case when year_id=2003 then ordernumber else null end) as total_order_2003,
count(distinct case when year_id=2004 then ordernumber else null end) as total_order_2004,
count(distinct case when year_id=2005 then ordernumber else null end) as total_order_2005,
round(sum(case when year_id=2003 then sales else 0 end),2) as total_sales_2003,
round(sum(case when year_id=2004 then sales else 0 end),2) as total_sales_2004,
round(sum(case when year_id=2005 then sales else 0 end),2) as total_sales_2005

from sample_sales_data
group by month_id;

-- string to date function 

select min(str_to_date(orderdate, '%d/%m/%y')) as first_business_day from sample_sales_data;
select max(str_to_date(orderdate, '%d/%m/%y')) as last_business_day from sample_sales_data;


-- Now we start to code for RFM segmentation (final code)

 
use rfm_sales;

select * from sample_sales_data limit 10;

create or replace view RFM as -- storing data or view file for further requirement

with customer_summery_table as
(select
	customername,
    datediff((select max(str_to_date(orderdate, '%d/%m/%y')) from sample_sales_data), max(str_to_date(orderdate, '%d/%m/%y'))) as R_value,
    count(distinct ordernumber) as F_value,
	Round(sum(sales),0) as M_value
    
from sample_sales_data
Group by customername),
 
 RFM_score as
(select
	s.*,
	ntile(5) over (order by r_value desc) as R_score,
    ntile(5) over (order by F_value asc) as f_score, -- assending is default, so no need to mention asc
    ntile(5) over (order by M_value asc) as m_score
from customer_summery_table as s),

RFM_combination_score as
(select
	R.*,
    (r_score+F_score+m_score) as Total_score,
    concat(r_score,f_score,m_score) as RFM_combination
from RFM_score as R)

select 
RCS.*,
case
	when RFM_combination in (455,515,542,544,552,553,452,545,551,554,555) then 'Champion'
    when RFM_combination in (344,345,353,354,355,414,415,443,451,342,351,352,441,442,444,445,453,454,541,543) then 'loyal Customer'
    when RFM_combination in (513,413,511,411,512,341,412,343,514) then 'Potential Loyalities'
	when RFM_combination in (214,211,212,213,241,251,312,314,311,313,315,243,245,252,253,255,242,244,254) then 'Promising Customer'
	when RFM_combination in (141,142,143,144,151,152,155,145,153,154,215) then 'Need Attentions'
	when RFM_combination in (113,111,112,114,115) then 'Need Attentions'
    else 'others'
    end as Customer_segemnt
from RFM_combination_score as RCS;

select * from rfm;
    





