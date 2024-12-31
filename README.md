World Life Expectancy Project (Data Cleaning and Analysis)
This project focuses on cleaning and analyzing the World Life Expectancy dataset. The key tasks performed include identifying and removing duplicates, filling in missing values, and performing exploratory data analysis (EDA) to uncover insights about life expectancy trends and correlations.

Table of Contents
Data Cleaning Steps
Identifying Duplicates
Removing Duplicates
Handling Missing Values
Exploratory Data Analysis (EDA)
Life Expectancy Trends
Correlations
Country Status Analysis
BMI and Adult Mortality
Data Cleaning Steps
Identifying Duplicates
To begin cleaning the data, duplicates were identified by comparing country and year values using the following query:

sql
Copy code
SELECT Country, Year, CONCAT(country, '', year), COUNT(CONCAT(country, '', year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(country, '', year)
HAVING COUNT(CONCAT(country, '', year)) > 1;
Removing Duplicates
Once duplicates were identified, they were removed by using the unique Row_ID for each row. This was done using ROW_NUMBER() and PARTITION BY:

sql
Copy code
SELECT*
FROM (
    SELECT Row_ID, CONCAT(Country, Year), 
           ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
    FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1;
The duplicate rows were then deleted:

sql
Copy code
DELETE FROM world_life_expectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT Row_ID, CONCAT(Country, Year), 
               ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
        FROM world_life_expectancy
    ) AS Row_table
    WHERE Row_Num > 1
);
Handling Missing Values
Cleaning the "Status" Column
Blank rows in the 'Status' column were populated with the existing string values ('Developing' or 'Developed'):

sql
Copy code
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = '' AND t2.Status <> '' AND t2.Status = 'Developing';

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = '' AND t2.Status <> '' AND t2.Status = 'Developed';
Handling Missing 'Life Expectancy' Values
For missing values in the 'Life Expectancy' column, the missing rows were filled with the average of the previous two years:

sql
Copy code
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3 ON t1.Country = t3.Country AND t1.Year = t3.Year - 1
SET t1.`Life Expectancy` = ROUND((t2.`Life Expectancy` + t3.`Life Expectancy`) / 2, 1)
WHERE t1.`Life Expectancy` = '';
Exploratory Data Analysis (EDA)
Life Expectancy Trends
An analysis was done to observe how life expectancy has evolved for each country over the past 15 years. The highest and lowest life expectancy values were tracked:

sql
Copy code
SELECT Country, MIN(`Life Expectancy`), MAX(`Life Expectancy`), 
       ROUND(MAX(`Life Expectancy`) - MIN(`Life Expectancy`), 1) AS Lif_increase_over_15_years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life Expectancy`) <> 0 AND MAX(`Life Expectancy`) <> 0
ORDER BY Lif_increase_over_15_years DESC;
Correlations
Life Expectancy and GDP
A correlation analysis was done between Life Expectancy and GDP to understand how they relate:

sql
Copy code
SELECT Country, ROUND(AVG(`Life Expectancy`), 1) AS Life_Exp, 
       ROUND(AVG(GDP), 1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 AND GDP > 0
ORDER BY GDP DESC;
High vs Low GDP and Life Expectancy
A case statement was used to analyze life expectancy in countries with high and low GDP:

sql
Copy code
SELECT SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_GDP_Count,
       ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life Expectancy` ELSE NULL END), 2) AS High_GDP_Life_Expectancy
FROM world_life_expectancy;

SELECT SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS Low_GDP_Count,
       AVG(CASE WHEN GDP <= 1500 THEN `Life Expectancy` ELSE NULL END) AS Low_GDP_Life_Expectancy
FROM world_life_expectancy;
Country Status Analysis
Analysis was performed on the life expectancy by 'Status' (Developed vs. Developing countries):

sql
Copy code
SELECT Status, ROUND(AVG(`Life Expectancy`), 1)
FROM world_life_expectancy
GROUP BY Status;
BMI and Adult Mortality Analysis
BMI vs Life Expectancy by Country
A comparison of average life expectancy against BMI across countries was performed:

sql
Copy code
SELECT Country, ROUND(AVG(`Life Expectancy`), 1) AS Life_Exp, 
       ROUND(AVG(BMI), 1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 AND BMI > 0
ORDER BY BMI ASC;
Adult Mortality vs Life Expectancy
A running total of adult mortality was calculated for countries with high mortality rates, correlated with life expectancy:

sql
Copy code
SELECT Country, Year, `Life Expectancy`, `Adult Mortality`,
       SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
WHERE Country LIKE 'United%';
Conclusion
This project demonstrates the steps involved in cleaning and analyzing life expectancy data, providing valuable insights into global health trends. By handling missing values, identifying correlations with factors like GDP and BMI, and analyzing country-specific data, we can better understand the key factors influencing life expectancy worldwide.
