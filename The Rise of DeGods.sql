-- 1. Sales Volume + Unique Wallet Purchases in 2022 (Daily)
with fact as (
select sales_amount as sales, purchaser as pur, block_timestamp, mint
from solana.fact_nft_sales
where  marketplace like 'magic%'
and  succeeded='true'
and block_timestamp >= '2022-01-01'
),
dim as(
select distinct mint
from solana.dim_nft_metadata
where contract_name = 'DeGods'
)
select sum(fact.sales) as sales_vol, count(DISTINCT fact.pur) as unique_purchaser , date(fact.block_timestamp) as date_
from fact , dim
where fact.mint=dim.mint
group by date(fact.block_timestamp)
##############################################################################################

-- 2. Swap Volume for DUST daily on Jupiter
SELECT sum(swap_to_amount) as amount, date(block_timestamp)
FROM Solana.swaps
where swap_to_mint like 'DUSTawucrTsGU8hcqRdHDCbuYhCPADMLM2VcCb8VnFnQ' 
  and date(block_timestamp)>= '2022-01-01' 
  and succeeded = 'True'
  and swap_from_amount>0
group by date(block_timestamp)
order by  sum(swap_to_amount)  DESC
##########################################################################################

-- 3. Wallets Swapping for DUST on Jupiter 
SELECT swapper, sum(swap_to_amount) as amount
FROM Solana.swaps
where swap_to_mint like 'DUSTawucrTsGU8hcqRdHDCbuYhCPADMLM2VcCb8VnFnQ' 
  and date(block_timestamp)>= '2022-01-01' 
  and succeeded = 'True'
  and swap_from_amount>0
group by swapper
order by  sum(swap_to_amount)  DESC
limit 10
############################################################################################

-- 4. Trait: Skin Trends
SELECT token_metadata:Skin::varchar as Skin 
  , count(*),  date(saledata.block_timestamp)  
FROM solana.dim_nft_metadata meta 
  join solana.fact_nft_sales saledata on meta.mint = saledata.mint
where contract_name like 'DeGods' 
  and succeeded =  'True'
   and token_metadata:Skin::varchar is not null
  and date(saledata.block_timestamp)>='2022-01-01'
group by meta.token_metadata:Skin::varchar
  , date(saledata.block_timestamp)