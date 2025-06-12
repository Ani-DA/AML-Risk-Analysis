
----									 ## DATA CLEANING  ##

select * from AML_DATASET

---checking for duplicates
select *, count(*) as freq
from 
AML_DATASET
group by
	Time,
	Date,
	Sender_account,
	Receiver_account,
	Amount_in_GBP,
	Payment_currency,
	Received_currency,
	Sender_bank_location,
	Receiver_bank_location,
	Payment_type,
	Is_laundering,
	Laundering_type
having count(*) > 1

---checking for null values
select *
from 
AML_DATASET
where
	Time is null
	or Date is null
	or Sender_account is null
	or Receiver_account is null
	or Amount_in_GBP is null
	or Payment_currency is null
	or Received_currency is null
	or Sender_bank_location is null
	or Receiver_bank_location is null
	or Payment_type is null
	or Is_laundering is null
	or Laundering_type is null

--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
----										   ## DATA ANALYSIS  ##

---Total transactions Statistics
select count(*) as Total_Txn,
count(case when Is_laundering = 1 then 1 end) as No_Laundered_Txn,
round(sum(case when Is_laundering = 1 then Amount_in_GBP end),2) as Total_Laundered_Amount,
count(case when Is_laundering =0 then 1 end) as No_Legit_Txn,
round(sum(case when Is_laundering = 0 then Amount_in_GBP end),2) as Total_Legit_Amount,
round((sum(case when Is_laundering = 1 then Amount_in_GBP end)*100/sum(Amount_in_GBP)),2) as Laundering_Amount_Percent,
round(((count(case when Is_laundering = 1 then 1 end))*100/count(*)),2) as Laundering_Txn_Percentage
from AML_DATASET;


---Avg amount comparison
select
  round(avg(case when Is_laundering = 1 then Amount_in_GBP end),2) as Laundered_Avg_Amount,
  round(avg(case when Is_laundering = 0 then Amount_in_GBP end),2) as Legit_Avg_Amount
from
  AML_DATASET;

----------------------------------------------------------------------------------------------------------------------------
											/*   1. Risk Exposure by Corridor
											Analysing Domestic and International Txns */

---let's see the domestic laundering txns
select Sender_bank_location,
		count(*) freq, 
		round(sum(Amount_in_GBP),2) Amount 
from AML_DATASET
where Sender_bank_location =Receiver_bank_location
and Is_laundering = 1
group by Sender_bank_location,
		Receiver_bank_location
order by freq desc

---let's find out the highly frequented and high amount cross border laundered txns

--- which corridor has the most no of laundering txns
select 
--top 10 
	   concat(Sender_bank_location,' - > ',	Receiver_bank_location) as Corridor,
	   count(*) No_of_Txns, 
	   round(sum(Amount_in_GBP),2) as Amount,
	   round(cast(count(*) as float) /sum(count(*)) over () * 100.0 , 2) as Percent_Txns,
	   round(cast(sum(Amount_in_GBP) as float) /sum(sum(Amount_in_GBP)) over () * 100.0 , 2) as Percent_Amounts
from AML_DATASET
where Is_laundering = 1
group by concat(Sender_bank_location,' - > ',Receiver_bank_location)
order by 
No_of_Txns desc


--- which corridor has the most no of laundering txns, among the overall txns
select 
--top 10
    concat(sender_bank_location, ' - > ', receiver_bank_location) as corridor,
    count(*) as no_of_laundered_txns,
    round(sum(amount_in_gbp), 2) as laundered_amount,
    round(cast(count(*) as float) / total_stats.total_txns * 100.0, 2) as percent_of_all_txns,
    round(cast(sum(amount_in_gbp) as float) / total_stats.total_amount * 100.0, 2) as percent_of_all_amounts
from AML_DATASET as laundered
cross join (
    select 
        count(*) as total_txns,
        sum(amount_in_gbp) as total_amount
    from AML_DATASET
) as total_stats
where laundered.sender_bank_location != laundered.receiver_bank_location
  and laundered.is_laundering = 1
group by concat(sender_bank_location, ' - > ', receiver_bank_location), total_stats.total_txns, total_stats.total_amount
order by no_of_laundered_txns desc;



---which corridor has the highest amount 
select 
--top 10 
	   concat(Sender_bank_location,' - > ',	Receiver_bank_location) as Corridor,
	   count(*) No_of_Txns, 
	   round(sum(Amount_in_GBP),2) as Amount,
	   round(cast(count(*) as float) /sum(count(*)) over () * 100.0 , 2) as Percent_Txns,
	   round(cast(sum(Amount_in_GBP) as float) /sum(sum(Amount_in_GBP)) over () * 100.0 , 2) as Percent_Amounts
from AML_DATASET
where 
--Sender_bank_location !=Receiver_bank_location and 
Is_laundering = 1
group by concat(Sender_bank_location,' - > ',	Receiver_bank_location)
order by
sum(Amount_in_GBP) desc

---which corridor has the higher average amount of laundering txns
select 
--top 10 
	   concat(Sender_bank_location,' - > ',	Receiver_bank_location) as Corridor,
	   count(*) No_of_Txns, 
	   round(avg(Amount_in_GBP),2) as Amount,
	   round(cast(count(*) as float) /sum(count(*)) over () * 100.0 , 2) as Percent_Txns,
	   round(cast(sum(Amount_in_GBP) as float) /sum(sum(Amount_in_GBP)) over () * 100.0 , 2) as Percent_Amounts
from AML_DATASET
where 
--Sender_bank_location !=Receiver_bank_location and
Is_laundering = 1
group by concat(Sender_bank_location,' - > ',	Receiver_bank_location)
order by 
Amount desc


--------------------------------------------------------------------------------------------------------------------------
									/*               Time-Based Laundering Trends
									   Analysing Date and Hours when Laundering may be frequented   */

---date when laundering txns occurs more
select 
DATEPART(dd,Date)as date,
count(*) as No_of_Laundering_Txns
from AML_DATASET
where Is_laundering = 1
group by DATEPART(dd,Date)
order by No_of_Laundering_Txns desc;

---date when legit_txn occurs more
select 
DATEPART(dd,Date)as date,
count(*) as No_of_Legit_Txns
from AML_DATASET
where Is_laundering = 0
group by DATEPART(dd,Date)
order by No_of_Legit_Txns desc


--- time of day when laundering txns occurs more
select 
DATEPART(HOUR,Time) as Hour_of_the_Day,
count(*) as No_of_Laundering_Txns
from AML_DATASET
where Is_laundering = 1
group by DATEPART(HOUR,Time)
order by No_of_Laundering_Txns desc

--- time of day when legit txns occurs more
select 
DATEPART(HOUR,Time) as Hour_of_the_Day,
count(*) as No_of_Legit_Txns
from AML_DATASET
where Is_laundering = 0
group by DATEPART(HOUR,Time)
order by No_of_Legit_Txns desc


-------------------------------------------------------------------------------------------------------------------------
													/*   Transaction Type Red Flags
														comparing Payment Types   */

---let's see the common payment types and their % in the laundered txns
select 
		Payment_type, 
		count(*) as No_of_Laundering_Txns, 
		round(sum(Amount_in_GBP),2) as Amount_Laundered,
		round((count(*)*100.0/sum(count(*)) over() ),2) as Percnt_Txns,
		round((sum(Amount_in_GBP)*100.0/sum(sum(Amount_in_GBP)) over()),2) as Percnt_Amount
from AML_DATASET
where Is_laundering =1
group by Payment_type
order by No_of_Laundering_Txns desc 


-------------------------------------------------------------------------------------------------------------------
-------------Laundering type Analysis

---let's see the most common laundering types
select 
	Laundering_type, 
	count(*) as No_of_Laundered_Txns,  
	round(sum(Amount_in_GBP),2) Laundered_Amount,
	round((count(*)*100.0/sum(count(*)) over() ),2) as Percnt_Txns,
	round((sum(Amount_in_GBP)*100.0/sum(sum(Amount_in_GBP)) over()),2) as Percnt_Amount
from AML_DATASET
where Is_laundering =1
group by Laundering_type
order by No_of_Laundered_Txns desc;


-------------------------------------------------------------------------------------------------------------------------
--------Laundering Amount Thresholds Analysis

----comparing average amount for Laundered and Legit Transactions
select 
	Laundering_type,
	round(avg((case when Is_laundering = 1 then Amount_in_GBP end)),2) as Laundered_Avg_Amount,
	round(avg((case when Is_laundering = 0 then Amount_in_GBP end)),2) as Legit_Avg_Amount
from AML_DATASET
group by Laundering_type
order by Laundered_Avg_Amount desc


------------------------------------------------------------------------------------------------------------------------
---checking if sender is sending money multiple times to receiver or others

---checking if the sender is sending money to the same account multiple times
select
	Sender_account,
	Receiver_account,
	count(*) as freq
from AML_DATASET
group by 
Sender_account,
Receiver_account
having count(*) >1


---checking if the sender is sending money to the same account multiple times
select
		Sender_account,
		count(distinct Receiver_account) as Unique_receiver,
		count(*) as Total_Txns,
		sum(Amount_in_GBP) as Total_Amount		
from AML_DATASET
group by Sender_account
having count(distinct Receiver_account) > 1

---checking if circulation of money happening where the receiver in turn is sending money
select *
from AML_DATASET
where Sender_account = Receiver_account

 
------------------------------------------------------------------------------------------------------------------------
--which sender and reciver currecy duo has the highest laundering txn
select 
	concat(Payment_currency,' - > ',Received_currency) as Cross_Currency,
	count(*) as Total_txns,
	round(sum(Amount_in_GBP),2) as Total_Txns_Amount,
	round((count(*) * 100.0)/(select count(*) from AML_DATASET) , 2)as Txn_percent
from AML_DATASET
where Is_laundering = 1
group by
	concat(Payment_currency,' - > ',Received_currency)
order by Txn_percent desc

--------------------------------------------------------------------------------------------------------------------------
------- Time Analysis
select 
	DATEPART(YEAR,Date) as Year,
	count(*) as No_of_Laundered_Txns,
	round(sum(Amount_in_GBP),2) as Total_Laundered_Amount
from AML_DATASET
where Is_laundering = 1
group by DATEPART(YEAR,Date)
order by DATEPART(YEAR,Date) asc

---checking which corridors and payment types are responsible
select 
	DATEPART(YEAR,Date) as Year,
	count(*) as No_of_Txns,
	round(sum(Amount_in_GBP),2) as Total_Amount,
	concat(Sender_bank_location,' - > ',	Receiver_bank_location) as Corridor,
	Laundering_type
from AML_DATASET
where Is_laundering = 1
group by 
	DATEPART(YEAR,Date),
	concat(Sender_bank_location,' - > ',	Receiver_bank_location),
	Laundering_type
order by 
	DATEPART(YEAR,Date) asc,
	No_of_Txns desc
			

---since year 2022 saw increase in laundered transactions, checking to see which corridor has the highest
select 
	DATEPART(YEAR,Date) as Year,
	count(*) as No_of_Txns,
	round(sum(Amount_in_GBP),2) as Total_Amount,
	concat(Sender_bank_location,' - > ',	Receiver_bank_location) as Corridor
from AML_DATASET
where Is_laundering = 1 and DATEPART(YEAR,Date) = 2022
group by 
	DATEPART(YEAR,Date),
	concat(Sender_bank_location,' - > ',	Receiver_bank_location)
order by count(*) desc



---payment type over the years
select 
	DATEPART(YEAR,Date) as Year,
	Payment_type,
	round(sum(Amount_in_GBP),2) as Total_Amount
from AML_DATASET
group by 
	DATEPART(YEAR,Date),
	Payment_type 
order by 
	DATEPART(YEAR,Date) asc,
	Total_Amount desc
	

---laundering type over the years
select 
	DATEPART(YEAR,Date) as Year,
	Laundering_type,
	round(sum(Amount_in_GBP),2) as Total_Amount
from AML_DATASET
group by 
	DATEPART(YEAR,Date),
	Laundering_type 
order by 
	DATEPART(YEAR,Date) asc,
	Total_Amount desc

-------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
-----   ## FEATURE ENGINEERING : CREATING RISK LABELS  ##

-- Create a view with risk scores
create view v_txn_risk_scores as
select 
    *,                       
    case															    -- cross border score	
        when Sender_bank_location != Receiver_bank_location then 20				
        else 0 
    end as cross_border_score,   
    case																--amount score
        when Amount_in_GBP > 10000 then 25
        when Amount_in_GBP > 5000 then 15 
        when Amount_in_GBP > 1000 then 5
        else 0
    end as amount_score, 
    case																--currency score
        when Payment_currency != Received_currency then 15 
        else 0 
    end as currency_score,
    case Payment_type													-- payment type score
        when 'Cash Deposit' then 10
        when 'Cross-border' then 15
        when 'Cheque' then 8
        else 5
    end as payment_type_score, 
	case when sender_bank_location in ('UAE', 'Panama','Cayman Islands') then 15  
		 when Receiver_bank_location in ('UAE', 'Panama','Cayman Islands') then 15 	
		 when Sender_bank_location in('Singapore','UK') then 10
		 when Receiver_bank_location in('Singapore','UK') then 10
         when sender_bank_location != receiver_bank_location then 5
             else 0 
        end as geography_score,									-- geography risk by specifying some high risk countries
 	case when exists (
                select 1 from AML_DATASET t2 
                where t2.sender_account = t.sender_account
                and t2.receiver_account = t.receiver_account
                and cast(t2.date as date) = cast(t.date as date)  -- same day
                and t2.time <> t.time  -- different time
            ) then 12  -- multiple transactions between same accounts in one day
            else 0 
        end as temporal_score,  
	case when amount_in_gbp between 9000 and 10000 then 8  -- potential structuring
            else 0
        end as amount_pattern_score						-- amount pattern risk
from AML_DATASET t
where Is_laundering = 0;


 select *,
	(cross_border_score + amount_score +currency_score +
		payment_type_score + geography_score + temporal_score + amount_pattern_score) 
	 as Total_Risk_Score,
	case when (cross_border_score + amount_score +currency_score +
				payment_type_score + geography_score + temporal_score + amount_pattern_score) >=70
		 then 'High' 
		 when (cross_border_score + amount_score +currency_score +
				payment_type_score + geography_score + temporal_score + amount_pattern_score) >=40
		 then 'Medium'
		 else 'Low'
	end as risk_category,

	case 
        when Amount_in_GBP > 8000 AND Sender_bank_location != Receiver_bank_location then 1
        when Payment_currency != Received_currency AND Amount_in_GBP > 5000 then 1
        else 0
    end as priority_review_flag	  
 from v_txn_risk_scores;

