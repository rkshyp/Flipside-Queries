-- 1. Cumulative swap fees generated
(SELECT pool_name, day, sum(total_Swap_fees_usd) over (order by day) as fees
FROM thorchain.daily_pool_stats
WHERE pool_name in ('TERRA.UST')
and year(day) >=2021)
union
(SELECT pool_name, day, sum(total_Swap_fees_usd) over (order by day) as fees
FROM thorchain.daily_pool_stats
WHERE pool_name in ('TERRA.LUNA')
and year(day) >=2021)
############################################################################################

-- 2. Pools ranked by total fees generated
SELECT  rank() over ( order by sum(total_Swap_fees_usd) desc) as rank, pool_name as Pool,
  sum(total_Swap_fees_usd) as fees
FROM thorchain.daily_pool_stats
WHERE
  day >='2022-03-24'
group by 2
############################################################################################

-- 3. Unique Sender and Receiver counts for each Pool
SELECT  pool_name, 
(count( distinct(from_address))) AS unique_senders,
(count( distinct(native_to_address))) AS unique_receivers
FROM thorchain.swaps
WHERE
  pool_name in ('TERRA.LUNA', 'TERRA.UST') and
  date(block_timestamp) >='2022-03-24'
group by 1
##########################################################################################

-- 4. Cashflow for each pool
(SELECT  
  case when from_asset like '%LUNA%' then 'outflow' 
  when to_asset like '%LUNA%' then 'inflow' end as cashflow, 
  POOL_NAME,
  sum(from_amount_usd)
FROM THORCHAIN.SWAPS
  WHERE (from_asset like '%LUNA%' OR TO_asset like '%LUNA%')
  AND POOL_NAME IN('TERRA.LUNA', 'TERRA.UST')
  group by 1,2)
UNION
(SELECT  
  case when from_asset like '%UST%' then 'outflow' 
  when to_asset like '%UST%' then 'inflow' end as cashflow, 
  POOL_NAME,
  sum(from_amount_usd)
FROM THORCHAIN.SWAPS
  WHERE (from_asset like '%UST%' OR TO_asset like '%UST%')
  AND POOL_NAME IN('TERRA.LUNA', 'TERRA.UST')
  group by 1,2)


