-- Data cleaning project
 

select *
from world_layoffs.layoffs
where company = 'Airbnb';


-- create a staging table to avoid messing up the raw data table

Create table Layoffs_stagging
like world_layoffs.layoffs;

select *
from world_layoffs.layoffs_stagging;

insert world_layoffs.layoffs_stagging
select *
from world_layoffs.layoffs;


-- Data cleaning, we follow usually few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors 
-- 3. Look at null values and see what
-- 4. remove any rows and colums if they are not necessory


-- 1. Removing duplicates

select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date'
) as row_num
from world_layoffs.layoffs_stagging;

with duplicate_cte as (
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) as row_num
from world_layoffs.layoffs_stagging
)
select * 
from duplicate_cte
where row_num > 1;

select *
from world_layoffs.layoffs_stagging
where company = 'Microsoft';

/* This method of deletion is not gonna work in Mysql */
with duplicate_cte as (
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) as row_num
from world_layoffs.layoffs_stagging
)
delete
from duplicate_cte
where row_num > 1;


CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_stagging2;

insert into world_layoffs.layoffs_stagging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) as row_num
from world_layoffs.layoffs_stagging;

select *
from layoffs_stagging2
where row_num > 1;

/* Here we are gonna delete all the duplicate rows */
DELETE
FROM layoffs_stagging2
WHERE row_num > 1;

/* 
I was keep getting error about disbaling safe mode in order to update or delete. After a good search I found out following query to disable safe mode 
link to discussion
*/
SET SQL_SAFE_UPDATES = 0;

select *
from world_layoffs.layoffs_stagging2;

-- 2. standardizing data 

select company, trim(company)
from layoffs_stagging2;

UPDATE layoffs_stagging2
set company = trim(company);

select distinct industry
from layoffs_stagging2
order by 1;

select *
from layoffs_stagging2
where country like 'united states.%';

Update layoffs_stagging2
set industry = 'Crypto'
where industry LIKE 'Crypto%';

Update layoffs_stagging2
set country = 'United States'
where Country like 'united states.%';

-- other solution for removing '.' at the end of country would be
-- trailing ex TRIM(TRAILING '.' from country)
-- this would go at the end of country name and find '.' adn remove it.

select distinct country
from layoffs_stagging2;

select `date`
-- STR_TO_DATE(`date`, '%m/%d/%Y')
from layoffs_stagging2;

Update layoffs_stagging2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

Alter table layoffs_stagging2
modify column `date` DATE;

select *
from layoffs_stagging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_stagging2
where industry = ''
or industry is null;

select *
from layoffs_stagging2;
-- where company = 'Carvana';

select t1.industry, t2.industry
from layoffs_stagging2 as t1
join layoffs_stagging2 as t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

-- now updating t1 with t2

update layoffs_stagging2 as t1
join layoffs_stagging2 as t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;


-- 3. Look at null values and see what
-- 4. remove any rows and colums if they are not necessory


-- Now we are gonna delete the rows which have Null values in total_laid_off, percentage_laid_off and we can't really fix them.

select *
from layoffs_stagging2
where total_laid_off is null
and percentage_laid_off is null;

DELETE
from layoffs_stagging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_stagging2;

--  Delete column row_num, we don't need them any more

alter table layoffs_stagging2
drop column row_num;