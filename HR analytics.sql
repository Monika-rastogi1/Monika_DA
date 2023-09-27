create database HR;
use HR;
select*from hr_1;
select*from hr_2;
drop table hr_2;

###KPI 1
select a.Department, concat(format(avg(a.attrition_y)*100,2),'%') as Attrition_Rate
from  
( select department,attrition,
case when attrition='Yes'
then 1
Else 0
End as attrition_y from hr_1 ) as a
group by department;

####KPI 2
select avg(HourlyRate)as average_hourly_rate, JobRole, Gender from hr_1
where JobRole='Research Scientist' and Gender='Male';

###KPI 3
select a.department, concat(format(avg(a.attrition_rate)*100,2),'%') as Average_attrition,format(avg(b.monthlyincome),2) as Average_Monthly_Income
from ( select department,attrition,EmployeeNumber,
case when attrition = 'yes' then 1
else 0
end as attrition_rate from hr_1) as a
inner join hr_2 as b on b.EmployeeID = a.EmployeeNumber
group by a.department;


####KPI 4
select a.department, avg(b.TotalWorkingYears) as average_working_years
from hr_1 as a 
inner join hr_2 as b on b.EmployeeID=a.EmployeeNumber
group by a.department;

###KPI 5
select a.JobRole,
sum(case when performancerating = 1 then 1 else 0 end) as 1st_Rating_Total,
sum(case when performancerating = 2 then 1 else 0 end) as 2nd_Rating_Total,
sum(case when performancerating = 3 then 1 else 0 end) as 3rd_Rating_Total,
sum(case when performancerating = 4 then 1 else 0 end) as 4th_Rating_Total, 
count(b.performancerating) as Total_Employee, format(avg(b.WorkLifeBalance),2) as Average_WorkLifeBalance_Rating
from hr_1 as a
inner join hr_2 as b on b.EmployeeID = a.EmployeeNumber
group by a.jobrole;

###KPI 6
select a.JobRole,concat(format(avg(a.attrition_rate)*100,2),'%') as Average_Attrition_Rate,
format(avg(b.YearsSinceLastPromotion),2) as Average_YearsSinceLastPromotion
from ( select JobRole,attrition,EmployeeNumber,
case when attrition = 'yes' then 1
else 0
end as attrition_rate from hr_1) as a
inner join hr_2 as b on b.EmployeeID = a.EmployeeNumber
group by a.JobRole;

