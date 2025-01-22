create database world_layoffs;
use world_layoffs;
select * from layoffs;

### CLEANING DATA
### CREATING A COPY OF RAW DATA

create table layoffs_staging
like layoffs;
select* from layoffs_staging;

insert layoffs_staging
select * from
layoffs;

### REMOVING DUPLICATES
select *,
row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from
layoffs_staging;

with duplicate_cte as
(select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from
layoffs_staging)
select * 
from duplicate_cte
where row_num>1;

select* from layoffs_staging
where company ='Casper';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select* from layoffs_staging2
where row_num>1;

insert into layoffs_staging2
select *,
row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from
layoffs_staging;

delete
from layoffs_staging2
where row_num>1;

### STANDARDIZING DATA

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company= trim(company);

select distinct industry
from layoffs_staging2;

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country=  trim(trailing '.' from country)
where country like 'United States%';

update layoffs_staging2
set industry= 'Crypto'
where industry like 'Crypto%';

### CHANGING DATE FORMAT
select *
from layoffs_staging2;

update layoffs_staging2
set `date`= str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;


### REMOVING NULL OR BLANK VALUES
select *
from layoffs_staging2
where industry is null
or industry= '';

select *
from layoffs_staging2
where company = 'Airbnb';

update layoffs_staging2
set industry= null
where industry='';

select t1.industry, t2.industry 
from layoffs_staging2 t1
join layoffs_staging2 t2
 on t1.company= t2.company
where (t1.industry is null or t1.industry= '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company= t2.company
set t1.industry = t2.industry 
where t1.industry is null
and t2.industry is not null;

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

### DROPPING A COLUMN
alter table layoffs_staging2
drop column row_num;

### EXPLORATORY DATA ANALYSIS

### Highest total lay offs
select max(percentage_laid_off), max(total_laid_off)
from  layoffs_staging2;

### Arranging in dec order to see which company had the highest total lay off 
select * 
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off DESC;

select * from layoffs_staging2
where percentage_laid_off=1
order by funds_raised_millions desc;

### Total layoffs company wise
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;


### Time period of layoffs
select max(`date`), min(`date`)
from layoffs_staging2;

### which industry had the most layoffs
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

### country wise layoffs
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

### year which had the maximum layoffs
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

### by stage 
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

### Rolling total of layoffs by month
select substring(`date`,1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1;

with rolling_total as
(select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_layoffs
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1)
select `month`, total_layoffs,
sum(total_layoffs) over(order by `month`) as rolling_sum
from rolling_total;


### Company laying off per year
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

### Top 5 companies in order of highest layoffs each year
with company_years (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), company_rank_year as
(
select *, 
dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_years
where years is not null)
select * 
from company_rank_year
where ranking<=5;

