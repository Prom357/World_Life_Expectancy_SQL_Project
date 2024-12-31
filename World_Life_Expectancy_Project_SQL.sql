-- ## World Life Expectancy Project (Data Cleaning) ##

-- ## Step 1: Identify duplicates ##
SELECT Country, Year, CONCAT(country, '', year), COUNT(CONCAT(country, '', year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(country, '', year)
HAVING COUNT(CONCAT(country, '', year)) > 1;

-- ## Step 2: Remove duplicates using unique Row_ID ##
SELECT *
FROM (
    SELECT Row_ID,
           CONCAT(Country, Year), 
           ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
    FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1;

-- ## Delete duplicates ##
DELETE FROM world_life_expectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT Row_ID,
               CONCAT(Country, Year), 
               ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
        FROM world_life_expectancy
    ) AS Row_table
    WHERE Row_Num > 1
);

-- ## Step 3: Identify and clean missing values in the 'Status' column ##
SELECT * 
FROM world_life_expectancy
WHERE Status = '';

-- Populate missing 'Status' values with existing strings
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
  AND t2.Status = 'Developing';

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
  AND t2.Status = 'Developed';

-- ## Step 4: Identify and clean missing values in 'Life Expectancy' column ##
SELECT * 
FROM world_life_expectancy
WHERE `Life Expectancy` = '';

-- Populate missing 'Life Expectancy' values with the average
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country AND t1.Year = t3.Year - 1
SET t1.`Life Expectancy` = ROUND((t2.`Life Expectancy` + t3.`Life Expectancy`) / 2, 1)
WHERE t1.`Life Expectancy` = '';

-- ## Exploratory Data Analysis (EDA) ##
-- Analyze life expectancy trends over the past 15 years
SELECT Country, 
       MIN(`Life Expectancy`) AS Min_Life_Expectancy,
       MAX(`Life Expectancy`) AS Max_Life_Expectancy,
       ROUND(MAX(`Life Expectancy`) - MIN(`Life Expectancy`), 1) AS Life_Exp_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING Min_Life_Expectancy <> 0 AND Max_Life_Expectancy <> 0
ORDER BY Life_Exp_Increase_15_Years DESC;

-- Calculate average life expectancy by year
SELECT Year, ROUND(AVG(`Life Expectancy`), 2) AS Avg_Life_Expectancy
FROM world_life_expectancy
WHERE `Life Expectancy` <> 0
GROUP BY Year
ORDER BY Year;

-- Correlation between 'GDP' and 'Life Expectancy'
SELECT Country, 
       ROUND(AVG(`Life Expectancy`), 1) AS Avg_Life_Expectancy, 
       ROUND(AVG(GDP), 1) AS Avg_GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Avg_Life_Expectancy > 0 AND Avg_GDP > 0
ORDER BY Avg_GDP DESC;

-- Explore life expectancy based on 'Status'
SELECT Status, ROUND(AVG(`Life Expectancy`), 1) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Status;

-- Analyze BMI in relation to life expectancy
SELECT Country, 
       ROUND(AVG(`Life Expectancy`), 1) AS Avg_Life_Expectancy, 
       ROUND(AVG(BMI), 1) AS Avg_BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Avg_Life_Expectancy > 0 AND Avg_BMI > 0
ORDER BY Avg_BMI ASC;

-- Adult mortality analysis
SELECT Country, Year,
       `Life Expectancy`,
       `Adult Mortality`,
       SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
WHERE Country LIKE 'United%';
