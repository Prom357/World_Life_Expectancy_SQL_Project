World Life Expectancy Project (Data Cleaning)
This project focuses on cleaning and analyzing a dataset containing global life expectancy information. The tasks include identifying and removing duplicates, handling missing values, and performing exploratory data analysis (EDA) to uncover insights.

Table of Contents
Project Overview
Technologies Used
Data Cleaning Steps
Exploratory Data Analysis (EDA)
Conclusion
Project Overview
The world_life_expectancy dataset is cleaned and analyzed using SQL. This project ensures data integrity and highlights trends in life expectancy over time.

Technologies Used
Database: MySQL
Tools: SQL Queries for Data Cleaning and Analysis
Data Cleaning Steps
Step 1: Identify and Remove Duplicates
Query to find duplicates:
sql
Copy code
SELECT Country, Year, COUNT(*)
FROM world_life_expectancy
GROUP BY Country, Year
HAVING COUNT(*) > 1;
Query to delete duplicates:
sql
Copy code
DELETE FROM world_life_expectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM (
        SELECT Row_ID, ROW_NUMBER() OVER (PARTITION BY Country, Year) AS Row_Num
        FROM world_life_expectancy
    ) AS Temp
    WHERE Row_Num > 1
);
Step 2: Handle Missing Values
Fill missing Status:
sql
Copy code
UPDATE world_life_expectancy
SET Status = 'Developing'
WHERE Status = '';
Fill missing Life Expectancy:
sql
Copy code
UPDATE world_life_expectancy t1
SET t1.`Life Expectancy` = (
    SELECT ROUND(AVG(t2.`Life Expectancy`), 1)
    FROM world_life_expectancy t2
    WHERE t2.Country = t1.Country AND t2.Year BETWEEN t1.Year - 1 AND t1.Year + 1
)
WHERE t1.`Life Expectancy` = '';
Exploratory Data Analysis (EDA)
Life Expectancy Trends:

sql
Copy code
SELECT Country, MIN(`Life Expectancy`), MAX(`Life Expectancy`)
FROM world_life_expectancy
GROUP BY Country;
Average Life Expectancy by Year:

sql
Copy code
SELECT Year, AVG(`Life Expectancy`) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Year;
Correlation Between GDP and Life Expectancy:

sql
Copy code
SELECT Country, AVG(GDP) AS Avg_GDP, AVG(`Life Expectancy`) AS Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Country;
Conclusion
This project demonstrates effective data cleaning and analysis using SQL, highlighting trends and insights in global life expectancy. It serves as a foundation for more advanced analytics.

