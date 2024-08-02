USE world_layoffs;

SHOW tables;

SELECT * FROM layoffs;


---- 'Remove Duplicates'
---- 'Standardize The Data'
---- 'Null Values or Blank Values'
---- 'Remove Any Columns or Row'

select * from layoffs where company='cazoo';
WITH CTE AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date', stage , country , funds_raised_millions) as row_num
FROM layoffs
)
SELECT * 
FROM CTE 
WHERE row_num <> 1;

CREATE TABLE `layoffs2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL ,
  row_num tinyint
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs2
SELECT *, ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date', stage , country , funds_raised_millions) as row_num
FROM layoffs;

SELECT * FROM layoffs2;

SELECT * FROM layoffs2 WHERE row_num <> 1;

DELETE FROM layoffs2 WHERE row_num <> 1;

SELECT COMPANY , TRIM(COMPANY) FROM layoffs2;

UPDATE layoffs2
SET Company= TRIM(company);

SELECT DISTINCT industry FROM layoffs2 ORDER BY 1;

SELECT DISTINCT industry FROM layoffs2 WHERE industry LIKE 'crypto%';

UPDATE layoffs2
SET industry ='crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT country FROM layoffs2 ORDER BY 1;

SELECT DISTINCT country FROM layoffs2 WHERE country LIKE 'united%';

UPDATE layoffs2
SET country= TRIM(TRAILING '.' FROM country) ;

SELECT DISTINCT location FROM layoffs2 ORDER BY 1;


DESCRIBE layoffs2;

UPDATE layoffs2
SET date = STR_TO_DATE(DATE , '%m/%d/%Y');

ALTER TABLE layoffs2
MODIFY DATE DATE;

SELECT * FROM layoffs2
WHERE industry IS NULL OR industry = '';

UPDATE layoffs2
SET industry = NULL
WHERE industry = '';

SELECT * FROM layoffs2
WHERE company ='airbnb';

SELECT t1.industry AS A, t2.industry AS B
FROM layoffs2 AS t1
	JOIN layoffs2 AS t2
    ON t1.company=t2.company
    WHERE t1.industry IS NULL
    AND t2.industry IS NOT NULL;


UPDATE layoffs2 AS t1
	JOIN layoffs2 AS t2
    ON t1.company=t2.company
    SET t1.industry=t2.industry
    WHERE t1.industry IS NULL
    AND t2.industry IS NOT NULL;
    
    
SELECT * FROM layoffs2 
WHERE company LIKE 'BALL%';

SELECT * FROM layoffs2 order by 1;

ALTER TABLE layoffs2
DROP COLUMN row_num;

SELECT MAX(total_laid_off) , MAX(percentage_laid_off) 
FROM layoffs2;


SELECT  * 
FROM layoffs2
WHERE percentage_laid_off=1
ORDER BY total_laid_off DESC;

SELECT  * 
FROM layoffs2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;

SELECT  company , SUM(total_laid_off) 
FROM layoffs2
GROUP BY company
ORDER BY 2 DESC;

SELECT  YEAR(DATE), SUM(total_laid_off) 
FROM layoffs2
GROUP BY YEAR(DATE)
ORDER BY 1 ;

SELECT  industry , SUM(total_laid_off) 
FROM layoffs2
GROUP BY industry
ORDER BY 2 DESC;

SELECT  country , SUM(total_laid_off) 
FROM layoffs2
GROUP BY country
ORDER BY 2 DESC;

SELECT  stage  , SUM(total_laid_off)
FROM layoffs2
GROUP BY stage
ORDER BY 2 DESC;


SELECT  stage ,company , SUM(total_laid_off)
FROM layoffs2
GROUP BY stage , company
ORDER BY 1 , 3 DESC;

SELECT * FROM layoffs2;


SELECT YEAR(DATE) AS year ,MONTH(DATE) AS month ,  SUM(total_laid_off) AS laid_off
FROM layoffs2
WHERE YEAR(DATE) IS NOT NULL AND MONTH(DATE) IS NOT NULL
GROUP BY MONTH(DATE) , YEAR(DATE) 
ORDER BY  1, 2;

WITH rolling_total as
(
SELECT YEAR(DATE) AS year ,MONTH(DATE) AS month ,  SUM(total_laid_off) AS laid_off
FROM layoffs2
WHERE YEAR(DATE) IS NOT NULL AND MONTH(DATE) IS NOT NULL
GROUP BY MONTH(DATE) , YEAR(DATE) 
ORDER BY  1, 2
)
SELECT *, SUM(laid_off) OVER(ORDER BY year, month) AS rolling_laid_off
FROM rolling_total;



SELECT company, YEAR(DATE) AS year ,  SUM(total_laid_off) AS laid_off
FROM layoffs2
WHERE YEAR(DATE) IS NOT NULL
GROUP BY company, year
ORDER BY 3 desc;


WITH company_year AS
(
SELECT company, YEAR(DATE) AS year ,  SUM(total_laid_off) AS laid_off
FROM layoffs2
WHERE YEAR(DATE) IS NOT NULL
GROUP BY company, year
ORDER BY 3 desc 
)
SELECT * , dense_