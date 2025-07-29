-- SQL Project - Data Cleaning


SELECT   *
FROM    layoffs;

-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens


CREATE	TABLE	layoffs_staging
LIKE		layoffs;

INSERT	layoffs_staging
SELECT	*		
FROM	layoffs;

SELECT	*	
FROM	layoffs_staging;

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways




-- 1. Remove Duplicates

# First let's check for duplicates

	
-- it looks like these are all legitimate entries and shouldn't be deleted We need to really look at every single row to be accurate

-- these are our real duplicates 
SELECT	*,
	ROW_NUMBER()	OVER(PARTITION	BY	
		company,industry,total_laid_off,percentage_laid_off,'date')AS row_num
FROM	layoffs_staging;	


	
-- these are the ones we want to delete where the row number is > 1 or 2or greater essentially

-- now you may want to write it like this:

	
WITH	duplicate_cte	as
(
SELECT	*,
	ROW_NUMBER()	OVER(PARTITION	BY	
    company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions)AS row_num
FROM	layoffs_staging
)

SELECT *
FROM	duplicate_cte
WHERE	row_num>1;

-- one solution, which I think is a good one. Is to create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column
-- so let's do it!!


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
  `row_num` int	
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT	*
FROM	layoffs_staging2;

INSERT	INTO	layoffs_staging2
SELECT	*,
	ROW_NUMBER()	OVER(PARTITION	BY	
    company,location,industry,total_laid_off,percentage_laid_off,
    'date',stage,country,funds_raised_millions)AS row_num
FROM	layoffs_staging;

-- now that we have this we can delete rows were row_num is greater than 1

DELETE
FROM	layoffs_staging2
WHERE	row_num>1;

SELECT*
FROM	layoffs_staging2
WHERE	row_num>1;

SELECT*
FROM	layoffs_staging2;





-- 2. Standardize Data


SELECT	COMPANY,(TRIM(company))
FROM	layoffs_staging2;

UPDATE layoffs_staging2
SET	COMPANY=TRIM(company);

-- I also noticed the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto

SELECT	*
FROM	layoffs_staging2
WHERE	industry LIKE	'Crypto%';

-- now that's taken care of:

UPDATE	layoffs_staging2
SET	industry='Crypto'
where	industry	like	'Crypto%';

-- everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.

SELECT	country
from	layoffs_staging2
WHERE	country	LIKE	'United States%';

SELECT	DISTINCT	country,	TRIM(TRAILING	'.'	FROM	COUNTRY)
FROM	layoffs_staging2
ORDER BY	1;

UPDATE	layoffs_staging2
SET	country=TRIM(TRAILING	'.'	FROM	COUNTRY)
WHERE	country	LIKE	'Unitied States%';

-- now if we run this again it is fixed

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;

-- Let's also fix the date columns:

SELECT	`date`,
STR_TO_DATE(`DATE`,	'%m/%d/%Y')
FROM	layoffs_staging2;

-- we can use str to date to update this field

UPDATE	layoffs_staging2
SET	`DATE`=	STR_TO_DATE(`DATE`,	'%m/%d/%Y');

SELECT	`DATE`
from	layoffs_staging2;

-- now we can convert the data type properly

ALTER	TABLE	layoffs_staging2
MODIFY	COLUMN	`DATE`	DATE;


SELECT	*
from	layoffs_staging2;


SELECT	*	
FROM	layoffs_staging2
WHERE	total_laid_off	IS	NULL
AND	percentage_laid_off	IS	NULL;

-- if we look at industry it looks like we have some null and empty rows, let's take a look at these

SELECT	DISTINCT	INDUSTRY
FROM	layoffs_staging2;


SELECT	*
FROM	layoffs_staging2
WHERE	industry	IS	NULL	
		OR	industry	='';


-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- we should set the blanks to nulls since those are typically easier to work with


UPDATE	layoffs_staging2
SET	industry=NULL
WHERE	industry='';  

-- now if we check those are all null

    
SELECT	*
FROM	layoffs_staging2
WHERE	company	='Airbnb'; 

SELECT	l1.industry,l2.industry
FROM	layoffs_staging2	l1
JOIN	layoffs_staging2	l2
ON	l1.company=l2.company
WHERE	(l1.industry	is	NULL	OR	l1.industry	='')
				AND	l2.industry	is	NOT	NULL;

-- now we need to populate those nulls if possible

UPDATE	layoffs_staging2	l1
JOIN	layoffs_staging2	l2
ON	l1.company=l2.company
SET	l1.industry=l2.industry
WHERE	l1.industry	is	NULL	
				AND	l2.industry	is	NOT	NULL;

-- and if we check it looks like Bally's was the only one without a populated row to populate this null values

SELECT	*
FROM	layoffs_staging2
WHERE	company	='Airbnb'; 



-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values

SELECT	*	
FROM	layoffs_staging2
WHERE	total_laid_off	IS	NULL
AND	percentage_laid_off	IS	NULL;

-- Delete Useless data we can't really use

DELETE
FROM	layoffs_staging2
WHERE	total_laid_off	IS	NULL
AND	percentage_laid_off	IS	NULL;

SELECT	*
FROM	layoffs_staging2;


-- 4. remove any columns and rows we need to


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT	*
FROM	layoffs_staging2;



