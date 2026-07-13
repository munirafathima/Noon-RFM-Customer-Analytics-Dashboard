select count(*) as total_records from online_retail;

select count(distinct customerid) as total_customers from online_retail;

select round(sum(quantity*unitprice),2)as total_revenue from online_retail where quantity>0 and unitprice>0;

select count(*) as champions from customer_final where segment='champions';

select count(*) as at_risk_customers from customer_final where segment='At Risk';

select customerid,round(sum(quantity*unitprice),2)as customer_revenue from online_retail where customerid is not null
and quantity >0 and unitprice>0 group by customerid order by customer_revenue desc limit 10;

select segment,count(*)as total_customers from customer_final
group by segment order by total_customers desc;

select country,round(sum(quantity*unitprice),2) as total_revenue from online_retail where quantity>0 and unitprice>0 
group by country order by total_revenue desc limit 5;

select year(invoicedate) as year,
month(invoicedate)as month,
round(sum(quantity * unitprice),2)as monthly_revenue from online_retail 
where quantity>0 and unitprice>0 
group by year(invoicedate),month(invoicedate)
order by year(invoicedate),month(invoicedate);

select customerid,
datediff(
(select max(invoicedate) from online_retail),
max(invoicedate))as recency,
count(distinct invoiceno) as frequency,
round(sum(quantity*unitprice),2)as monetary
from online_retail
where customerid is not null
and quantity>0
and unitprice>0
group by customerid;

with rfm as(
select customerid,
datediff(
(select max(invoicedate) from online_retail),
max(invoicedate))as recency,
count(distinct invoiceno) as frequency,
round(sum(quantity*unitprice),2)as monetary
from online_retail
where customerid is not null
and quantity>0
and unitprice>0
group by customerid)
select customerid,recency,frequency,monetary,
6 - ntile(5)over(order by recency asc)as R_score,
ntile(5)over(order by frequency asc)as F_score,
ntile(5)over(order by monetary asc)as M_score
from rfm;

with rfm as(
select customerid,
datediff(
(select max(invoicedate) from online_retail),
max(invoicedate))as recency,
count(distinct invoiceno) as frequency,
round(sum(quantity*unitprice),2)as monetary
from online_retail
where customerid is not null
and quantity>0
and unitprice>0
group by customerid),
rfm_scores as(
select customerid,recency,frequency,monetary,
6 - ntile(5)over(order by recency asc)as R_score,
ntile(5)over(order by frequency asc)as F_score,
ntile(5)over(order by monetary asc)as M_score
from rfm)
select customerid,recency,frequency,monetary,R_score,F_score,M_score,
case
when R_score>=4 and F_score>=4 and M_score>=4 then 'champions'
when R_score>=3 and F_score>=3 then 'Loyal Customers'
when R_score>=4 and F_score<=3 then 'potental loyalist'
when R_score<=2 and F_score>=3 then 'At Risk'
when R_score=1 and F_score<=2 then 'Lost Customers'
else 'Others'
end as segment
from rfm_scores;


select customerid,
round(sum(quantity*unitprice),2)as total_revenue,
dense_rank()over(order by sum(quantity * unitprice)desc)as revenue_rank
from online_retail
where customerid is not null
and quantity>0
and unitprice>0
group by customerid;




