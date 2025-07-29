# World-Layoffs-Data Analysis using SQL

![Layoffs Logo](https://raw.githubusercontent.com/atharvN8/World-Layoffs-Sql-Project/refs/heads/main/Layoffs%20Logo.jfif)

## Overview
This SQL project focuses on data cleaning and preparation, transforming raw, potentially
"dirty" data into a clean, standardized, and usable format for analysis or other applications. 

## Objective
1. Improve data quality and accuracy
2. Enhance data consistency
3. Ensure data completeness
4. Optimize the dataset for analysis and efficiency
5. Support reliable decision-making and operational efficiency

## DataSet

The data for this project is sourced from the Kaggle dataset:

## Dataset Link :[Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)


## Cleaning Procedure

## 1. check for duplicates and remove any
 
	SELECT   *
	FROM    layoffs;
	
	CREATE	TABLE	layoffs_staging
	LIKE		layoffs;-- Data	Cleaning
	
	
	INSERT	layoffs_staging
	SELECT	*	
	FROM	layoffs;

	SELECT	*	
	FROM	layoffs_staging;
	
	
	SELECT	*,
		ROW_NUMBER()	OVER(PARTITION	BY	
			company,industry,total_laid_off,percentage_laid_off,'date')AS row_num
	FROM	layoffs_staging;


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
	
	
	DELETE
	FROM	layoffs_staging2
	WHERE	row_num>1;
	
	SELECT*
	FROM	layoffs_staging2
	WHERE	row_num>1;
	
	SELECT*
	FROM	layoffs_staging2;
	
	
	

## 2. standardize data and fix errors

	SELECT	COMPANY,(TRIM(company))
	FROM	layoffs_staging2;
	
	UPDATE layoffs_staging2
	SET	COMPANY=TRIM(company);
	
	SELECT	*
	FROM	layoffs_staging2
	WHERE	industry LIKE	'Crypto%';
	
	
	UPDATE	layoffs_staging2
	SET	industry='Crypto'
	where	industry	like	'Crypto%';
	
	
	SELECT	country
	from	layoffs_staging2
	WHERE	country	LIKE	'United States%';
	
	SELECT	DISTINCT	country,	TRIM(TRAILING	'.'	FROM	COUNTRY)
	FROM	layoffs_staging2
	ORDER BY	1;
	
	UPDATE	layoffs_staging2
	SET	country=TRIM(TRAILING	'.'	FROM	COUNTRY)
	WHERE	country	LIKE	'Unitied States%';
	
	
	SELECT	`date`,
					STR_TO_DATE(`DATE`,	'%m/%d/%Y')
	FROM	layoffs_staging2;
	
	UPDATE	layoffs_staging2
	SET	`DATE`=	STR_TO_DATE(`DATE`,	'%m/%d/%Y');
	
	SELECT	`DATE`
	from	layoffs_staging2;
	
	ALTER	TABLE	layoffs_staging2
	MODIFY	COLUMN	`DATE`	DATE;
	
	
	SELECT	*
	from	layoffs_staging2;
	
	
	SELECT	DISTINCT	INDUSTRY
	FROM	layoffs_staging2;
	
	SELECT	*
	FROM	layoffs_staging2
	WHERE	industry	IS	NULL	
			OR	industry	='';
	
	UPDATE	layoffs_staging2
	SET	industry=NULL
	WHERE	industry='';  
	    
	SELECT	*
	FROM	layoffs_staging2
	WHERE	company	='Airbnb'; 
	
	

## 3. Look at null values and blank values

	SELECT	l1.industry,l2.industry
	FROM	layoffs_staging2	l1
	JOIN	layoffs_staging2	l2
	ON	l1.company=l2.company
	WHERE	(l1.industry	is	NULL	OR	l1.industry	='')
					AND	l2.industry	is	NOT	NULL;
	
	
	UPDATE	layoffs_staging2	l1
	JOIN	layoffs_staging2	l2
	ON	l1.company=l2.company
	SET	l1.industry=l2.industry
	WHERE	l1.industry	is	NULL	
					AND	l2.industry	is	NOT	NULL;
	
	SELECT	*
	FROM	layoffs_staging2
	WHERE	company	='Airbnb'; 
	
	
	SELECT	*	
	FROM	layoffs_staging2
	WHERE	total_laid_off	IS	NULL
	AND	percentage_laid_off	IS	NULL;
	
	
	DELETE
	FROM	layoffs_staging2
	WHERE	total_laid_off	IS	NULL
	AND	percentage_laid_off	IS	NULL;
	
	SELECT	*
	FROM	layoffs_staging2;
	
	
	
 ## 4. remove any columns and rows that are not necessary
 
	ALTER TABLE layoffs_staging2
	DROP COLUMN row_num;
	
	
	SELECT * 
	FROM layoffs_staging2;







