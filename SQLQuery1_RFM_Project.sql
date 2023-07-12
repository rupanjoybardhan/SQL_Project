

--inspecting dataset
 select * from [dbo].[sales_data_sample 2]

-- checking unique values
 select distinct status from [dbo].[sales_data_sample 2]
 select distinct productline from [dbo].[sales_data_sample 2]
 select distinct year_id from [dbo].[sales_data_sample 2]
 select distinct dealsize from [dbo].[sales_data_sample 2]
 select distinct city from [dbo].[sales_data_sample 2]
 select distinct country from [dbo].[sales_data_sample 2]
 select distinct territory from [dbo].[sales_data_sample 2]

 --Analysis
 --lets start by 
 --grouping sales by productline
 select productline as PRODUCTLINE, sum(sales) as REVENUE
 from [dbo].[sales_data_sample 2]
 group by productline
 order by revenue desc

 --grouping sales by year_id to see which year generated highest revenue
 select year_id as YEAR,round(sum(sales),2) as REVENUE
 from [dbo].[sales_data_sample 2]
 group by year_id
 order by 2 desc

 --checking distinct months in all 3 years
 --the output suggests that the company operated for only 5 months i.e around half a year in 2005 consequently generating lowest of the revenues and operated full months in year 2004 and 2003
 select distinct month_id
 from [dbo].[sales_data_sample 2]
 where year_id=2005

 select distinct month_id
 from [dbo].[sales_data_sample 2]
 where year_id=2004

 select distinct month_id
 from [dbo].[sales_data_sample 2]
 where year_id=2003

 --grouping sales by dealsize
 select dealsize as DEALSIZE, sum(sales) as REVENUE
 from [dbo].[sales_data_sample 2]
 group by DEALSIZE
 order by 2 desc

 --which are best selling months in a specific year? how much was earned that month?
 select month_id as MONTH,round(sum(sales),2) as REVENUE,count(ordernumber) as FREQUENCY
 from [dbo].[sales_data_sample 2]
 where year_id=2003    --can change year_id value and check for each
 group by month_id
 order by 2 desc

--november seems to be the exceptional month for the company,what product do they sell in november?
select year_id as YEAR,month_id as MONTH,productline as PRODUCTLINE,sum(sales) as REVENUE,count(ordernumber) as FREQUENCY
from [dbo].[sales_data_sample 2]
where year_id=2004 and month_id=11
group by year_id,month_id,productline
order by 4 desc
--clearly classic cars is the best selling productline in november month for both 2004 and 2003

--who are our best customers? this can be best answered using RFM Analysis

drop table if exists #rfm;
with rfm as(
		select customername,
			   max(orderdate) as Last_Order_Date,
			   (select max(orderdate) as Max_Order_Date from [dbo].[sales_data_sample 2]) as Max_Order_Date,
			   datediff(DD,max(orderdate),(select max(orderdate) as Max_Order_Date from [dbo].[sales_data_sample 2])) as Recency,
			   sum(sales) as Monetary_value,
			   avg(sales) as Avg_Monetary_value,
			   count(ordernumber) as Frequency
		from   [dbo].[sales_data_sample 2]
		group by customername
) ,
rfm_calc as(
		select r.*,
			   NTILE(4) over(order by Recency desc) as RFM_Recency_Score,
			   NTILE(4) over(order by Frequency) as RFM_Frequency_Score,
			   NTILE(4) over(order by Monetary_value) as RFM_Monetary_Score
		from rfm r
)
select c.*,
	  (RFM_Recency_Score+RFM_Frequency_Score+RFM_Monetary_Score) as RFM_Score,
	  cast(RFM_Recency_Score as varchar)+cast(RFM_Recency_Score as varchar)+cast(RFM_Monetary_Score as varchar) as RFM_String
into  #rfm     -- creates a temp table as the query is run
from rfm_calc c

select CUSTOMERNAME,RFM_Recency_Score,RFM_Frequency_Score,RFM_Monetary_Score,
	   case
	        when RFM_String in (111, 112 , 121, 122, 123, 132,211, 212, 114, 141) then 'lost_customers'  --lost customers
			when RFM_String in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
			when RFM_String in (311, 411,421, 331) then 'new customers'
			when RFM_String in (222, 223, 233, 322) then 'potential churners'
			when RFM_String in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
			when RFM_String in (433, 434, 443, 444) then 'loyal'
	end rfm_segment
from #rfm



--city wise sales in specific country
select country, city,sum(sales) as Revenue
from [sales_data_sample 2]
where country='USA'
group by country,city
order by Revenue desc

--best selling product in specific country in a specific year
select country,year_id,productline,sum(sales) as revenue
from [sales_data_sample 2]
where year_id=2004 and country='USA'
group by country,year_id,productline order by revenue desc



