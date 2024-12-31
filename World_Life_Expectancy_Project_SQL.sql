#### World Life Expectancy Project (Data Cleaning)##

#### First step in data cleaning is identifying duplicates ###

SELECT Country, Year, CONCAT(country, '', year), COUNT(CONCAT(country, '', year))
 FROM 
world_life_expectancy
GROUP BY Country, Year, CONCAT(country, '', year)
HAVING COUNT(CONCAT(country, '', year)) > 1;

### Next is removing duplicates (by identifying the unique row id)
### I  used partition by and row_number
## What this means is that after using the code above to identify the duplicate, 
## I then reomved the dupliate with the code below but we must use their id to 
## remove the specific row id  ####

SELECT*
FROM(
SELECT Row_ID,
CONCAT(Country, Year), 
ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year)
ORDER BY CONCAT(Country, Year)) AS Row_Num
FROM world_life_expectancy
) AS Row_table
WHERE Row_Num > 1
;

##Delecting the duplicate after identifying with the row number

DELETE FROM world_life_expectancy
WHERE 
Row_ID IN(
SELECT Row_ID
FROM(
	SELECT Row_ID,
	CONCAT(Country, Year), 
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year)
	ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
	) AS Row_table
WHERE Row_Num > 1)
;

### Next step in data cleaning is identify missing values from the rows
### Clean the 'Status' column by identify blank rows and populating with the alrady existing string

SELECT status 
FROM world_life_expectancy
;

SELECT * 
FROM world_life_expectancy
WHERE  Status = '';

SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <>'';

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing';

#### Then populating with the alrady existing string


UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status =''
AND t2.Status <> ''
AND t2.Status = 'Developing';


UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status =''
AND t2.Status <> ''
AND t2.Status = 'Developed';

###Check table if it updated

SELECT * 
FROM world_life_expectancy
WHERE  Country = 'United States of America';

SELECT * 
FROM world_life_expectancy
WHERE  Status IS NULL;

###The next thing i did was to identify other column with similar issued to pupolate for example 'life expectancy' column

SELECT * 
FROM world_life_expectancy
WHERE `Life Expectancy`= ''
;
### i pupolated the blank row of the 'life expectancy' column with average

SELECT t1.Country, t1.Year, t1.`Life Expectancy`,
t2.Country, t2.Year, t2.`Life Expectancy`,
t3.Country, t3.Year, t3.`Life Expectancy`,
ROUND((t2.`Life Expectancy` + t3.`Life Expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year -1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year -1
WHERE t1.`Life Expectancy` =''
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year -1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year -1
SET t1.`Life Expectancy` = 
ROUND
((t2.`Life Expectancy` + t3.`Life Expectancy`)/2,1)
WHERE t1.`Life Expectancy` =''
;

#Check if it was updated

SELECT Country, Year, `Life Expectancy`
FROM world_life_expectancy
#WHERE `Life Expectancy`= ''
;

SELECT * 
FROM world_life_expectancy;

##Typically you need to change column name but not in this data

###### Next in the EDA is to find insighs and trend that can be use in the future- using widow function

# The first thing that was done was to see how each country has done in the past 15 years with their life expectancy
## Bascially lookng at the heighest and lowest life expectancy each country has had over the past 15 years
## To take a look at which country have done well with increasing their life expectancy


SELECT Country, MIN(`Life Expectancy`),
MAX(`Life Expectancy`),
ROUND(MAX(`Life Expectancy`)-MIN(`Life Expectancy`),1) 
AS Lif_increase_over_15_years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life Expectancy`)<>0
AND MAX(`Life Expectancy`)<>0
ORDER BY Lif_increase_over_15_years DESC 
;


### I also looked at the average year of life expectancy

SELECT Year, ROUND(AVG(`Life Expectancy`),2)
FROM world_life_expectancy
WHERE `Life Expectancy`<>0
AND `Life Expectancy`<>0
GROUP BY Year
ORDER BY Year
;

#### Corrolation between 'life expectancy' and other column.

#### Corrolation between 'life expectancy and 'GDP'

SELECT Country, ROUND(AVG(`Life Expectancy`),1)
AS Life_Exp, 
ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp >0
AND GDP > 0
ORDER BY GDP DESC
;


### Case statment after corrolation

### High GDP corrolation with the life expectancy

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END)
    High_GPD_Count,
ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life Expectancy` 
ELSE NULL END),2) High_GDP_Life_Expectancy
From world_life_expectancy
;

### Lowest GDP corrolation with the life expectancy and High

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END)
    High_GPD_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life Expectancy` 
ELSE NULL END) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END)
    Low_GPD_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life Expectancy` 
ELSE NULL END) Low_GDP_Life_Expectancy
From world_life_expectancy
;



###### Working with Status column

### With the status column i did EDA to see the average life expectancy between the status

##Group on status VS the average life expectancy

SELECT Status, ROUND(AVG(`Life Expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;

## Thw first code above shows that the number was skewed quite a bite in favour for the developed Countries cus there's few of them

####  Then i did another code have balancing the data


SELECT Status, COUNT(DISTINCT Country)
FROM world_life_expectancy
GROUP BY Status
;

SELECT Status, COUNT(DISTINCT Country),
ROUND(AVG(`Life Expectancy`),1)
FROM world_life_expectancy
GROUP BY Status;

### Next i looked at the BMI column

### Compare BMI based on each Country against Life expectancy. 
### Each Country is going to have their own BMI standards and numbers


SELECT Country, ROUND(AVG(`Life Expectancy`),1)
AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp >0
AND BMI >0
ORDER BY BMI ASC
;


### Next i looked at the Adult mortality

### How many peoaple are dying each year in a country and is that a lot comapre to their life expectancy 

SELECT Country, Year,
`Life Expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) 
OVER (PARTITION BY Country ORDER BY Year) AS Rooling_Total
FROM world_life_expectancy
WHERE Country LIKE 'United%'
;


