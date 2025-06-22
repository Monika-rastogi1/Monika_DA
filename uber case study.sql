create database case_study;
use case_study;
select * from uber;

### overall supply demand and gap
SELECT
  COUNT(*) AS demand,
  SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS supply,
  COUNT(*) - SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS gap
FROM uber;

### Supply-Demand-Gap at the City Vs. Airport
SELECT
  `Pickup point`,
  COUNT(*) AS demand,
  SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS supply,
  COUNT(*) - SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS gap
FROM uber
GROUP BY `Pickup point`;

### Percentage of unmet demands at the city Vs Airport
SELECT
  `pickup point`,
  demand,
  supply,
  gap,
  ROUND(100.0 * gap / demand, 1) AS unmet_pt
FROM (
  SELECT
    `pickup point`,
    COUNT(*) AS demand,
    SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS supply,
    COUNT(*) - SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS gap
  FROM uber
  GROUP BY `pickup point`
) t
ORDER BY unmet_pt DESC;


### Supply-Demand-gap Hour wise
SELECT
  HOUR(STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s')) AS hour,
  COUNT(*) AS demand,
  SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS supply,
  COUNT(*) - SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS gap
FROM uber
WHERE STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s') IS NOT NULL
GROUP BY hour
ORDER BY hour;

### Supply-Demand-Gap by 
SELECT
  CASE
    WHEN HOUR(STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s')) BETWEEN 0 AND 3   THEN 'Late Night'
    WHEN HOUR(STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s')) BETWEEN 4 AND 5   THEN 'Early Morning'
    WHEN HOUR(STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s')) BETWEEN 6 AND 11  THEN 'Morning'
    WHEN HOUR(STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s')) BETWEEN 12 AND 16 THEN 'Afternoon'
    WHEN HOUR(STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s')) BETWEEN 17 AND 19 THEN 'Evening'
    WHEN HOUR(STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s')) BETWEEN 20 AND 23 THEN 'Night'
  END AS day_part,
   `pickup point`, COUNT(*) AS demand,
  SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS supply,
  COUNT(*) - SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS gap
FROM uber
WHERE STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s') IS NOT NULL
GROUP BY day_part, `pickup point`
ORDER BY day_part DESC;

### Status of cabs at City Vs Airport
SELECT
  `Pickup point`,
  status,
  COUNT(*) AS cnt
FROM uber
GROUP BY `pickup point`, status
ORDER BY `pickup point`, status;

### Supply-Demand-Gap day wise
SELECT
 dayname(STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s')) AS day_of_week,
 COUNT(*) AS demand,
  SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS supply,
  COUNT(*) - SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS gap
FROM uber
WHERE dayname(STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s')) IS NOT NULL
GROUP BY day_of_week
ORDER BY day_of_week DESC;

### Top 10 routes with the highest unmet demands
WITH hourly_stats AS (
  SELECT
    `pickup point`,
    HOUR(STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s')) AS hour,
    COUNT(*) AS demand,
    SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS supply,
    COUNT(*) - SUM(CASE WHEN status = 'Trip Completed' THEN 1 ELSE 0 END) AS gap
  FROM uber
  WHERE STR_TO_DATE(`request timestamp`, '%d-%m-%Y %H:%i:%s') IS NOT NULL
  GROUP BY `pickup point`, hour
)
SELECT *
FROM hourly_stats
ORDER BY gap DESC
LIMIT 10;