select * from loan_data

--Total Loan Applications
select count(*) as total_applications
from loan_data

--Total Loan Applications month over month
select DATENAME(month,issue_date) as month, count(*) as MoM_total_applications, cast(round(100.0*(count(*)-lag(count(*)) over(order by MONTH(issue_date)))/count(*),2) as decimal(8,2)) as percent_change
from loan_data
group by MONTH(issue_date), DATENAME(month,issue_date)

--Total Funded Amount
select sum(loan_amount) as total_funded
from loan_data

--Total Funded Amount month over month
select DATENAME(month,issue_date) as month, sum(loan_amount) as MoM_total_funded, 
					cast(round(100.0*(sum(loan_amount)-lag(sum(loan_amount)) over(order by MONTH(issue_date)))/sum(loan_amount),2) as decimal(8,2)) as percent_change
from loan_data
group by MONTH(issue_date), DATENAME(month,issue_date)

--Total Funded Recieved
select sum(total_payment) as total_recieved
from loan_data

--Total Recieved Amount month over month
select DATENAME(month,last_payment_date) as month, sum(total_payment) as MoM_total_recieved, 
					cast(round(100.0*(sum(total_payment)-lag(sum(total_payment)) over(order by MONTH(last_payment_date)))/sum(total_payment),2) as decimal(8,2)) as percent_change
from loan_data
group by MONTH(last_payment_date), DATENAME(month,last_payment_date)

--Average Interest Rate
select round(avg(int_rate)*100,2) as average_interest_rate
from loan_data

--Average interest Rate month over month
select DATENAME(month,issue_date) as month, round(avg(int_rate)*100,2) as MoM_avg_interest_rate, 
					round(100*(avg(int_rate)-lag(avg(int_rate)) over(order by MONTH(issue_date)))/avg(int_rate),2) as percent_change
from loan_data
group by MONTH(issue_date), DATENAME(month,issue_date)

--Average Debt-to-Income(DTI) Ratio
select round(avg(dti)*100,2) as average_dti
from loan_data

--Average interest Rate month over month
select DATENAME(month,issue_date) as month, round(avg(dti)*100,2) as MoM_avg_interest_rate, 
					round(100*(avg(dti)-lag(avg(dti)) over(order by MONTH(issue_date)))/avg(dti),2) as percent_change
from loan_data
group by MONTH(issue_date), DATENAME(month,issue_date)

-- Good Loan Issued
select count(*) as good_loan_issued
from loan_data
where loan_status in ('Fully Paid','Current')

--Good Loan Issued Percentage
select cast(round(sum(case when loan_status in ('Fully Paid','Current') then 100.00 else 0 end)/count(*),2) as decimal(8,2)) as good_loan_percent
from loan_data

--Good Loan Funded Amount
select sum(loan_amount) as good_loan_funded
from loan_data
where loan_status in ('Fully Paid','Current')

--Good Loan Total Received Amount
select sum(total_payment) as good_loan_recieved
from loan_data
where loan_status in ('Fully Paid','Current')

-- Bad Loan Issued
select count(*) as bad_loan_issued
from loan_data
where loan_status = 'Charged off'

--Bad Loan Issued Percentage
select cast(round(sum(case when loan_status = 'Charged off' then 100.00 else 0 end)/count(*),2) as decimal(8,2)) as bad_loan_percent
from loan_data

--Bad Loan Funded Amount
select sum(loan_amount) as bad_loan_funded
from loan_data
where loan_status = 'Charged off'

--Bad Loan Total Received Amount
select sum(total_payment) as bad_loan_recieved
from loan_data
where loan_status = 'Charged off'

--Loan Status 
with cte as(
select loan_status, sum(loan_amount) as mtd_total_funded, sum(total_payment) as mtd_total_recieved
from loan_data
where month(issue_date)= (select max(cast(month(issue_date) as int)) from loan_data) and year(issue_date)= (select max(cast(year(issue_date) as int)) from loan_data)
group by loan_status),
cte2 as(
select loan_status, count(1) as total_loan_application, sum(loan_amount) as total_funded, sum(total_payment) as total_recieved, round(avg(int_rate*100),2) as avg_interest_rate, round(avg(dti*100),2) as avg_dti
from loan_data 
group by loan_status)

select a.*,b.mtd_total_funded,b.mtd_total_funded from cte2 a inner join cte b on a.loan_status=b.loan_status

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--*Loan Report*

--By Month
select month(issue_date) as month_num, DATENAME(month,issue_date) as month, count(*) as total_application, sum(loan_amount) as total_funded, sum(total_payment) as total_recieved
from loan_data
group by month(issue_date), DATENAME(month,issue_date)
order by month(issue_date)

--By Region
select address_state, count(*) as total_application, sum(loan_amount) as total_funded, sum(total_payment) as total_recieved
from loan_data
group by address_state
order by address_state

--By Loan Term
select term as loan_term, count(*) as total_application, sum(loan_amount) as total_funded, sum(total_payment) as total_recieved
from loan_data
group by term
order by term

--By Employement Length
select emp_length, count(*) as total_application, sum(loan_amount) as total_funded, sum(total_payment) as total_recieved
from loan_data
group by emp_length
order by total_funded

--By Loan Purpose
select purpose, count(*) as total_application, sum(loan_amount) as total_funded, sum(total_payment) as total_recieved
from loan_data
group by purpose
order by total_funded

--By Home Ownership Status
select home_ownership as home_ownership_status, count(*) as total_application, sum(loan_amount) as total_funded, sum(total_payment) as total_recieved
from loan_data
group by home_ownership
order by total_funded