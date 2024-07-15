use cryptopunk;

select * from pricedata;

#1. How many sales occured during this time period?

select count(*) as total_sales from pricedata;

#2. Return the top 5 most expensive transactions(by USD price) for this dataset. 
#Return the name, ETH price and USD price, as well as the date. 

select name, eth_price, usd_price, event_date
from pricedata
order by USD_price desc
limit 5;

#3. Return a table with a row for each transaction with an event column, 
# a USD price column and a moving average of USD price that averages the last 50 transactions.

select event_date, usd_price, 
	avg(usd_price) over(order by event_date rows between 49 preceding and current row) as moving_average
from pricedata;

#4. Return all the NFT names and their average sale price in USD. Sort descending. 
# Name the average column as average_price.

select name as NFT_names, avg(usd_price) as average_price from pricedata
group by NFT_names
order by average_price desc;

#5. Return each day of the week and the number of sales that occured on that day of the week,
# as well as the average price in ETH. Order by the count of transactions in ascending order.

select day(event_date) as Day_event, count(usd_price) as sales_count, avg(eth_price) as avg_price, count(transaction_hash) as count_of_transactions
from pricedata
group by Day_event
order by count_of_transactions asc;

#6. Count a column that describes each sale and is called summary. The sentence should include who sold the NFT
# name, who bought the NFT, who sold the NFT, the date, and what price it was sold for in USD rounded to the 
# nearest thousandth.

select concat(name, " was sold for $ ", round(usd_price, 3), " to ", buyer_address, " from ", seller_address, " on ", event_date) 
as summary from pricedata;

#7. Create a view called "1919_purchases" and contains any sales where "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685" was the buyer.

create view 1919_purchases as
	select * from pricedata
    where buyer_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";

#8. Create a histogram of ETH price ranges. Round to the nearest hundred value.

select round((eth_price/100) * 100, -1) as bucket,
count(*) as count,
rpad("", count(*), '*') as bar
from pricedata
group by bucket
order by bucket;

#9. Return a unioned query that contains the highest price each NFT was bought for and a new column called
# status saying "highest" with a query that has the lowest price each NFT was bought for and the status column
# saying "lowest". The table should have a name column, a price column called price, and a status column.
# Order the result set by the name of the NFT, and the status, in ascending order.

(
	select name as NFT_name, max(usd_price) as price, "highest" as status
	from pricedata
	group by name
)
UNION ALL
(
	select name as NFT_name, min(usd_price) as price, "lowest" as status
	from pricedata
	group by name
)
order by NFT_name asc, 
status asc;

#10. What NFT sold the most each month/year combination? Also, what was the name and the price in USD? Order in chronological format.

select month(event_date) as month, year(event_date) as year, name as NFT_name, max(usd_price) as price_in_usd
from pricedata
group by month, year, NFT_name 
order by month asc, year asc;

#11. Return the total volume(sum of all sales), round to the nearest hundred on a monthly basis(month/year).

select date_format(event_date, '%Y-%m') as month_year,
round(sum(usd_price), 2) as total_volume
from pricedata
group by month_year;

#12. Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685" had over this time period.

select count(*) as transaction_count from pricedata where buyer_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";

#13. Create an "estimated average value calculator" that has a representative price of the collection every day based off these criteria:
# - Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
# - Take the daily average of remaining transactions
# Frist create a query that will be used as a subquery. select the event date, the USD price, and the average USD price for each
# day using a window function. Save it as a temporary table.

create temporary table if not exists DailyAveragePrices as
select event_date, usd_price, avg(usd_price) 
over (partition by event_date) as daily_average
from pricedata;

select avg(daily_average) as estimated_average_value
from (
	select event_date, daily_average
    from DailyAveragePrices
    where usd_price >=0.1 * daily_average
) as filtered_data;


























