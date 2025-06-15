create database strava_fitness;
use strava_fitness;
select* from dailyactivity_merged;
select* from hourlycalories_merged;
select* from hourlyintensities_merged;
select* from hourlysteps_merged;
select* from sleepday_merged;
select* from weightloginfo_merged;

### Checking unique users in each dataset
select count(distinct Id) as Total_Ids
from dailyactivity_merged;

select count(distinct Id) as Total_Ids
from hourlycalories_merged;

select count(distinct Id) as Total_Ids
from hourlyintensities_merged;

select count(distinct Id) as Total_Ids
from sleepday_merged;

select count(distinct Id) as Total_Ids
from weightloginfo_merged;

# Avg number of days people tracked sleep
Select sum(Days)/24 as average_no_of_days
from(select distinct Id, count(SleepDay) as Days
from sleepday_merged
group by Id) as new_table;

# Avg number of days people logged weight
Select sum(Days)/8 as average_days
from(select distinct Id, count(Date) as Days
from weightloginfo_merged
group by Id) as new_table;

### Average time and distance spent 
select ActivityDate, round(avg(VeryActiveDistance),2), round(avg(ModeratelyActiveDistance),2), round(avg(LightActiveDistance),2), round(avg(VeryActiveMinutes),2), round(avg(FairlyActiveMinutes),2), round(avg(LightlyActiveMinutes),2)
from dailyactivity_merged
group by ActivityDate;

### Activity Distribution
select round(avg(VeryActiveMinutes),2)as very_active_mins,  round(avg(FairlyActiveMinutes),2) as fairly_active_mins, round(avg(LightlyActiveMinutes),2) as lightly_active_mins, round(avg(SedentaryMinutes),2) as sedentary_mins
from dailyactivity_merged;

### Time asleep vs Time on bed
select str_to_date(SleepDay, '%m/%d/%Y') as Dates, round(avg(TotalMinutesAsleep),1) as time_asleep, round(avg(TotalTimeInBed),2) as total_time_in_bed
from sleepday_merged
group by SleepDay order by Dates;

### Average sleep time in day of week
select
Dayname(str_to_date(SleepDay, '%m/%d/%Y')) as Dayname,
round(avg(TotalMinutesAsleep),2) as Avg_Total_Minutes_Asleep
from sleepday_merged
group by Dayname
order by Avg_Total_Minutes_Asleep desc;

###  Highly efficient day of the week
select
Dayname(str_to_date(ActivityDate, '%m/%d/%Y')) as Dayname,
sum(TotalSteps) as Total_Steps,
sum(Calories) as Total_Calories_burned
from dailyactivity_merged
group by Dayname
order by Total_Steps desc, Total_Calories_burned desc;

### Average steps and average calories by hour
SELECT round(avg(hs.StepTotal)) as Avg_Steps, 
round(avg(hc.Calories)) as Avg_Calories,
hc.ActivityHour
from hourlycalories_merged as hc
join hourlysteps_merged as hs 
on hc.ActivityHour = hs.ActivityHour AND hc.Id = hs.Id
group by hc.ActivityHour;

### Total Steps by Hour
SELECT 
ActivityHour,
SUM(StepTotal) AS Total_Steps_By_Hour
FROM hourlySteps_merged
GROUP BY ActivityHour
ORDER BY Total_Steps_By_Hour DESC;

### No of users that used tracker on a specified date
select str_to_date(ActivityDate,'%m/%d/%Y') As Date, count(Id)
from dailyactivity_merged
group by ActivityDate;

### Users who logged full day activity
alter table dailyactivity_merged
add column Total_Minutes int;

update dailyactivity_merged
set Total_Minutes= VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes;

SELECT distinct Id,  DATE_FORMAT(ActivityDate, '%Y') AS year,
    DATE_FORMAT(ActivityDate, '%m') AS month , Total_Minutes
FROM 
	dailyactivity_merged
WHERE
	Calories <> 0 AND
	Total_Minutes = 1440;
    
    ### Users who did not log full day activity
    SELECT distinct Id,  DATE_FORMAT(ActivityDate, '%Y') AS year,
    DATE_FORMAT(ActivityDate, '%m') AS month , Total_Minutes
FROM 
	dailyactivity_merged
WHERE
	Calories <> 0 AND
	Total_Minutes <> 1440;
    
### Average of tracker wearing time per day
select
Dayname(str_to_date(ActivityDate, '%m/%d/%Y')) as Dayname,
avg(Total_Minutes) as Avg_Total_Minutes
from dailyactivity_merged
group by Dayname;

### Average wearing time per user
select distinct Id,
sum(Total_Minutes)/count(ActivityDate) as Avg_wearing_time
from dailyactivity_merged
group by Id;

# User types by total steps
SELECT Id,
avg(TotalSteps) AS Avg_Total_Steps,
CASE
WHEN avg(TotalSteps) < 5000 THEN 'Inactive'
WHEN avg(TotalSteps) BETWEEN 5000 AND 7499 THEN 'Low Active User'
WHEN avg(TotalSteps) BETWEEN 7500 AND 9999 THEN ' Moderately Active User'
WHEN avg(TotalSteps) > 10000 THEN 'Very Active User'
END User_Type
FROM dailyactivity_merged
GROUP BY Id;

# Tracker Usage insights
SELECT Id,
COUNT(Id) AS Total_Id
FROM dailyactivity_merged
GROUP BY Id;

(SELECT Id,
COUNT(Id) AS Total_Logged_Uses,
CASE
WHEN COUNT(Id) BETWEEN 25 AND 31 THEN 'Active User'
WHEN COUNT(Id) BETWEEN 15 and 24 THEN 'Moderate User'
WHEN COUNT(Id) BETWEEN 0 and 14 THEN 'Light User'
END Strava_Usage_Type
FROM dailyactivity_merged
GROUP BY Id);
