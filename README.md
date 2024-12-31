World Life Expectancy Data Cleaning and EDA

Project Overview
This project focuses on cleaning and exploring a dataset that contains life expectancy data for various countries over several years. The dataset requires several data cleaning steps, such as identifying and removing duplicates, handling missing values, and ensuring data consistency across columns. Following the cleaning process, exploratory data analysis (EDA) was performed to derive insights and trends related to life expectancy across countries.

Data Cleaning Process
1. Identifying Duplicates
The first step in the data cleaning process involved identifying duplicates based on a combination of Country and Year. This was done by using the following SQL query:

sql
Copy code
SELECT Country, Year, CONCAT(Country, '', Year), COUNT(CONCAT(Country, '', Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, '', Year)
HAVING COUNT(CONCAT(Country, '', Year)) > 1;
2. Removing Duplicates
Once the duplicates were identified, we used ROW_NUMBER() with a PARTITION BY clause to assign a unique row number for each duplicate record. We then deleted the duplicates using the Row_ID to ensure only one instance of each duplicate was kept:

sql
Copy code
DELETE FROM world_life_expectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT Row_ID, CONCAT(Country, Year), 
        ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
        FROM world_life_expectancy
    ) AS Row_table
    WHERE Row_Num > 1
);
3. Handling Missing Values
Updating Status Column
Missing values in the Status column were populated by joining the dataset on Country and using existing values for consistency:

sql
Copy code
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = '' AND t2.Status <> '' AND t2.Status = 'Developing';

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = '' AND t2.Status <> '' AND t2.Status = 'Developed';
Updating Life Expectancy Column
Missing values in the Life Expectancy column were filled with the average of the previous two years' values:

sql
Copy code
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
    ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
    ON t1.Country = t3.Country AND t1.Year = t3.Year - 1
SET t1.`Life Expectancy` = ROUND((t2.`Life Expectancy` + t3.`Life Expectancy`) / 2, 1)
WHERE t1.`Life Expectancy` = '';
4. Checking Updates
After the missing value updates, the following queries were used to verify the updates:

sql
Copy code
SELECT * FROM world_life_expectancy WHERE Status IS NULL;
SELECT * FROM world_life_expectancy WHERE `Life Expectancy` = '';
Exploratory Data Analysis (EDA)
1. Life Expectancy Trends Over 15 Years
To identify the trends in life expectancy over the past 15 years, I calculated the highest and lowest life expectancy for each country:

sql
Copy code
SELECT Country, MIN(`Life Expectancy`), MAX(`Life Expectancy`), 
    ROUND(MAX(`Life Expectancy`) - MIN(`Life Expectancy`), 1) AS Lif_increase_over_15_years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life Expectancy`) <> 0 AND MAX(`Life Expectancy`) <> 0
ORDER BY Lif_increase_over_15_years DESC;
2. Average Life Expectancy by Year
The average life expectancy for each year was calculated as follows:

sql
Copy code
SELECT Year, ROUND(AVG(`Life Expectancy`), 2)
FROM world_life_expectancy
WHERE `Life Expectancy` <> 0
GROUP BY Year
ORDER BY Year;
3. Correlation Between Life Expectancy and GDP
To analyze the correlation between Life Expectancy and GDP, the following query was used:

sql
Copy code
SELECT Country, ROUND(AVG(`Life Expectancy`), 1) AS Life_Exp, ROUND(AVG(GDP), 1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 AND GDP > 0
ORDER BY GDP DESC;
4. High and Low GDP Correlation with Life Expectancy
We also categorized countries into high and low GDP brackets and compared the average life expectancy for each group:

sql
Copy code
SELECT 
    SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_GDP_Count,
    ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life Expectancy` ELSE NULL END), 2) AS High_GDP_Life_Expectancy
FROM world_life_expectancy;

SELECT 
    SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS Low_GDP_Count,
    AVG(CASE WHEN GDP <= 1500 THEN `Life Expectancy` ELSE NULL END) AS Low_GDP_Life_Expectancy
FROM world_life_expectancy;
5. Comparing Life Expectancy by Status
To understand the differences in life expectancy based on the Status column (Developed vs Developing), I performed the following analysis:

sql
Copy code
SELECT Status, ROUND(AVG(`Life Expectancy`), 1)
FROM world_life_expectancy
GROUP BY Status;
6. Comparing BMI Against Life Expectancy
Lastly, I analyzed the relationship between BMI and Life Expectancy for each country:

sql
Copy code
SELECT Country, ROUND(AVG(`Life Expectancy`), 1) AS Life_Exp, ROUND(AVG(BMI), 1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 AND BMI > 0
ORDER BY BMI ASC;
7. Adult Mortality vs Life Expectancy
To understand how adult mortality affects life expectancy, I calculated the rolling total of adult mortality for countries with the name "United":

sql
Copy code
SELECT Country, Year, `Life Expectancy`, `Adult Mortality`, 
    SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
WHERE Country LIKE 'United%';
Conclusion
This project demonstrates how to clean and analyze large datasets using SQL. The cleaned dataset provides valuable insights into global life expectancy trends, the impact of GDP and BMI, and the correlation between life expectancy and adult mortality.
