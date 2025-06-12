# Sustainability Analysis SQL Project
Advanced SQL Analysis on Global Energy Consumption data 

## Project Overview

- **Project Title**: Sustainability Analysis on Global Energy Consumption  
- **Level**: Advanced  
- **Database Name**: `sustainability`  

This project demonstrates advanced SQL skills used by data analysts to explore, clean, and analyze global energy data from 2000 to 2024. It includes a focused study on the COVID lockdown period (2020–2022) to evaluate how different countries practiced sustainability.

The analysis uses custom metrics such as sustainable choices and sustainability goals to assess environmental progress.

## Objectives

1. Set up a sustainability database with structured global energy data  
2. Clean and validate data by removing nulls, duplicates, and detecting outliers  
3. Explore the dataset to understand country/year coverage and data consistency  
4. Calculate derived metrics for more meaningful analysis  
5. Answer key sustainability questions using advanced SQL techniques

## Dataset Structure and Units

| Column Name                | Description                                | Unit                       |
|----------------------------|---------------------------------------------|-----------------------------|
| `Country`                  | Country name                                | Text                        |
| `Year`                     | Year of observation                         | YEAR                        |
| `Total_Energy_Consumption` | Total energy consumed                       | Terawatt-hours (TWh)        |
| `Per_Capita_Energy_Use`    | Energy consumed per person                  | Kilowatt-hours (kWh)        |
| `Renewable_Energy_Share`   | Share of renewables in energy consumed      | Percentage (%)              |
| `Fossil_Fuel_Dependency`   | Share of fossil fuels in energy consumed    | Percentage (%)              |
| `Industrial_Energy_Use`    | Industry's share in energy consumption      | Percentage (%)              |
| `Household_Energy_Use`     | Household share in energy consumption       | Percentage (%)              |
| `Carbon_Emissions`         | Total CO₂ emissions                         | Million tons                |
| `Energy_Price_Index`       | Average price of energy                     | USD per kWh                 |

## Key Metric Definitions

- **Sustainable Choices**: A country is considered to make a sustainable choice in a year if its renewable energy consumption exceeds fossil fuel consumption.
- **Sustainability Goals Achieved**: A country achieves a sustainability goal in a year if it increases per capita energy use and simultaneously decrease in total carbon emissions compared to the previous year.

## Project Structure

### 1. Database Setup

- Database creation and table setup using SQL DDL.
- Table `global_energy_data` is used to store energy metrics.

```sql
CREATE DATABASE sustainability;

CREATE TABLE global_energy_data (
    Country TEXT,
    Year INT,
    Total_Energy_Consumption DOUBLE,
    Per_Capita_Energy_Use DOUBLE,
    Renewable_Energy_Share DOUBLE,
    Fossil_Fuel_Dependency DOUBLE,
    Industrial_Energy_Use DOUBLE,
    Household_Energy_Use DOUBLE,
    Carbon_Emissions DOUBLE,
    Energy_Price_Index DOUBLE
);
````

### 2. Data Cleaning

* Described table structure
* Changed data type of `Year` column to `YEAR`
* Removed null values
* Checked and filtered duplicate records
* Identified outliers using standard deviation-based thresholds

### 3. Exploratory Data Analysis

* Counted total records, unique countries, and years
* Verified year-wise data availability for each country

### 4. Parameter Calculations

Derived columns:

* `Renewable_Energy`, `Fossil_Fuel`, `Industrial_Energy`, `Household_Energy` in TWh
* Estimated `population` using:
  `population = (Total_Energy_Consumption * 1e9) / Per_Capita_Energy_Use`

These values were added to the main table for further analysis.

### 5. View Creation

Created a view `energy_global` to simplify queries with aggregated and calculated metrics per country per year.

```sql
CREATE VIEW energy_global AS
SELECT 
    Country, Year,
    ROUND(SUM(Total_Energy_Consumption), 2) AS Total_Energy_Consumed,
    ROUND(SUM(Total_Energy_Consumption)*1e9 / SUM(Population), 2) AS Per_Capita_Energy_Use,
    ROUND(SUM(Renewable_Energy), 2) AS Total_RW_Energy,
    ROUND(SUM(Fossil_Fuel), 2) AS Total_FF,
    ROUND(SUM(Industrial_Energy), 2) AS Total_Ind_Energy,
    ROUND(SUM(Household_Energy), 2) AS Total_House_Energy,
    ROUND(SUM(Carbon_Emissions), 2) AS Total_Carbon_Emission
FROM global_energy_data
GROUP BY Country, Year;
```

## Analysis Highlights

### Sustainable Choices

* Count of years each country used more renewable energy than fossil fuel
* Average number of countries making sustainable choices per year
* Special focus on 2020–2022 COVID lockdown period

### Sustainability Goals

* Year-over-year analysis using `LAG()` function
* Count of years each country increased per capita energy use and reduced CO₂ emissions
* Yearly averages and COVID-year comparison

### Emission Contributions

* Comparison between industrial and household energy use
* Emission rankings per year using `DENSE_RANK()`

### Summary Statistics

* Country-wise and global average CO₂ emissions
* Percentage contribution of each country to global emissions
* Emission trends during COVID-19 period

## How to Use This Project

1. Clone or download the repository
2. Run the SQL script in a MySQL-compatible environment
3. Execute queries for analysis
4. Modify queries to suit additional analysis needs

