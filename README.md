# World Life Expectancy Project (Data Cleaning and Analysis)

This project focuses on cleaning and analyzing world life expectancy data using SQL. The primary goal is to explore trends, handle missing values, and identify correlations between life expectancy and other variables such as GDP, BMI, and adult mortality.

## Table of Contents
- [Project Overview](#project-overview)
- [Files](#files)
- [Installation](#installation)
- [Insights](#insights)
- [SQL Queries](#sql-queries)

## Project Overview
The project includes the following steps:

### 1. Data Cleaning
   - **Identifying and Removing Duplicates**: Using SQL queries to identify and remove duplicate rows from the dataset based on the `Country` and `Year` columns.
   - **Handling Missing Values**: Filling missing values in columns like `Status` and `Life Expectancy` using values from other rows or calculated averages.
   - **SQL Techniques Used**: Partitioning, row numbering, and aggregate functions.

### 2. Exploratory Data Analysis (EDA)
   - **Trends in Life Expectancy**: Analyzing the highest and lowest life expectancy each country has had over the past 15 years.
   - **Correlations**: Identifying correlations between life expectancy and other factors like GDP, BMI, and adult mortality.
   - **Country Status Analysis**: Comparing life expectancy across countries categorized as developed and developing.

### 3. SQL Queries
   - SQL queries used for data cleaning and analysis are included in the project. These queries utilize window functions, aggregation, and joins to clean and analyze the data.

## Files
- `data_cleaning.sql`: SQL script for cleaning the dataset (removes duplicates, fills missing values in the `Status` and `Life Expectancy` columns).
- `eda_analysis.sql`: SQL script for exploratory data analysis (life expectancy trends, correlations with GDP, BMI, and adult mortality).
- `README.md`: This file.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/USERNAME/World_Life_Expectancy_Project.git
