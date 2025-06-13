# Sustainability Analysis SQL Project
Advanced SQL Analysis on Global Energy Consumption Data

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

| Column Name                 | Description                                      | Unit                        |
|-----------------------------|--------------------------------------------------|-----------------------------|
| `Country`                   | Country name                                     | Text                        |
| `Year`                      | Year of observation                              | YEAR                        |
| `Total_Energy_Consumption`  | Total energy consumed                            | Terawatt-hours (TWh)        |
| `Per_Capita_Energy_Use`     | Average energy consumed per person               | Kilowatt-hours (kWh)        |
| `Renewable_Energy_Share`    | Share of renewables in energy consumed           | Percentage (%)              |
| `Fossil_Fuel_Dependency`    | Share of fossil fuels in energy consumed         | Percentage (%)              |
| `Industrial_Energy_Use`     | Industry's share in energy consumption           | Percentage (%)              |
| `Household_Energy_Use`      | Household share in energy consumption            | Percentage (%)              |
| `Carbon_Emissions`          | Total CO₂ emissions                              | Million tons                |
| `Energy_Price_Index`        | Change in price compared to base year            | USD per kWh                 |

## Key Metric Definitions

- **Sustainable Choices**: A country is considered to make a sustainable choice if its renewable energy consumption exceeds fossil fuel consumption.  
- **Sustainability Goals Achieved**: A country achieves sustainability goals if it increases per capita energy use and simultaneously decreases total carbon emissions compared to the previous year.

## Project Structure

### 1. Database Setup

- Database creation and table setup using SQL DDL.
- Table `global_energy_data` is used to store energy metrics.

```sql
create database sustainability;

create table global_energy_data
(Country text, 
Year int, 
Total_Energy_Consumption double, 
Per_Capita_Energy_Use double, 
Renewable_Energy_Share double, 
Fossil_Fuel_Dependency double, 
Industrial_Energy_Use double, 
Household_Energy_Use double, 
Carbon_Emissions double, 
Energy_Price_Index double);
````

### 2. Data Cleaning

* Described table structure
* Changed data type of `Year` column to `YEAR`
* Checked null values
* Checked and filtered duplicate records
* Identified outliers using standard deviation-based thresholds

```sql
describe global_energy_data;

alter table global_energy_data
modify column Year Year;

select * from global_energy_data
where Country is null or
Year is null or
Total_Energy_Consumption is null or
Per_Capita_Energy_Use is null or
Renewable_Energy_Share is null or
Fossil_Fuel_Dependency is null or
Industrial_Energy_Use is null or
Household_Energy_Use is null or
Carbon_Emissions is null or
Energy_Price_Index is null;

select * from global_energy_data
group by Country,Year,Total_Energy_Consumption,Per_Capita_Energy_Use,Renewable_Energy_Share,Fossil_Fuel_Dependency,Industrial_Energy_Use,
Household_Energy_Use,Carbon_Emissions,Energy_Price_Index
having count(*)>1;

with average as(select round(avg(Total_Energy_Consumption),2) as avg_Total_Energy_Consumption,round(std(Total_Energy_Consumption),2) as std_Total_Energy_Consumption,round(avg(Per_Capita_Energy_Use),2) as avg_Per_Capita_Energy_Use,round(std(Per_Capita_Energy_Use),2) as std_Per_Capita_Energy_Use,
round(avg(Renewable_Energy_Share),2) as avg_Renewable_Energy_Share,round(std(Renewable_Energy_Share),2) as std_Renewable_Energy_Share,
round(avg(Fossil_Fuel_Dependency),2) as avg_Fossil_Fuel_Dependency,round(std(Fossil_Fuel_Dependency),2) as std_Fossil_Fuel_Dependency,
round(avg(Industrial_Energy_Use),2) as avg_Industrial_Energy_Use,round(std(Industrial_Energy_Use),2) as std_Industrial_Energy_Use,
round(avg(Household_Energy_Use),2) as avg_Household_Energy_Use,round(std(Household_Energy_Use),2) as std_Household_Energy_Use,
round(avg(Carbon_Emissions),2) as avg_Carbon_Emissions,round(std(Carbon_Emissions),2) as std_Carbon_Emissions from global_energy_data)
select * from global_energy_data
where abs(Total_Energy_Consumption-(select avg_Total_Energy_Consumption from average))>3*(select std_Total_Energy_Consumption from average) or
abs(Renewable_Energy_Share-(select avg_Renewable_Energy_Share from average))>3*(select std_Renewable_Energy_Share from average) or
abs(Fossil_Fuel_Dependency-(select avg_Fossil_Fuel_Dependency from average))>3*(select std_Fossil_Fuel_Dependency from average) or
abs(Industrial_Energy_Use-(select avg_Industrial_Energy_Use from average))>3*(select std_Industrial_Energy_Use from average) or
abs(Household_Energy_Use-(select avg_Household_Energy_Use from average))>3*(select std_Household_Energy_Use from average) or
abs(Carbon_Emissions-(select avg_Carbon_Emissions from average))>3*(select std_Carbon_Emissions from average);  
```

### 3. Exploratory Data Analysis

* Counted total records, unique countries, and years
* Checked year-wise data availability for each country

```sql
select count(*) as no_of_records from global_energy_data;

select count(distinct Country) as total_countries from global_energy_data;

select count(distinct Year) as total_year from global_energy_data;

select Country,count( distinct Year) as years_data_available from global_energy_data 
group by Country;

select Country,Year,count(*) as record from global_energy_data 
group by Country,Year;
```

### 4. Parameter Calculations

Derived columns:

* `Renewable_Energy`, `Fossil_Fuel`, `Industrial_Energy`, `Household_Energy` in TWh
* Estimated `population` using:
  `population = (Total_Energy_Consumption * 1e9) / Per_Capita_Energy_Use`
  
These values were added to the main table for further analysis.

```sql
alter table global_energy_data
add Renewable_Energy double,
add Fossil_Fuel double,
add Industrial_Energy double,
add Household_Energy double,
add population bigint;

update global_energy_data
set Renewable_Energy=round(Renewable_Energy_Share*Total_Energy_Consumption*0.01,2),
Fossil_Fuel=round(Fossil_Fuel_Dependency*Total_Energy_Consumption*0.01,2),
Industrial_Energy=round(Industrial_Energy_Use*Total_Energy_Consumption*0.01,2),
Household_Energy=round(Household_Energy_Use*Total_Energy_Consumption*0.01,2),
population=round((Total_Energy_Consumption*pow(10,9)/Per_Capita_Energy_Use),0);
```

### 5. View Creation

Created a view `energy_global` to simplify queries with aggregated and calculated metrics per country per year.

```sql
create view energy_global
as select Country,Year,round(sum(Total_Energy_Consumption),2) as Total_Energy_Consumed,round(sum(Total_Energy_Consumption)*pow(10,9)/sum(population),2) as Per_Capita_Energy_Use,
round(sum(Renewable_Energy),2) as Total_RW_Energy,round(sum(Fossil_Fuel),2) as Total_FF,round(sum(Industrial_Energy),2) as Total_Ind_Energy,
round(sum(Household_Energy),2) as Total_House_Energy,round(sum(Carbon_Emissions),2) as Total_Carbon_Emission 
from global_energy_data 
group by Country,Year
order by Year asc,Country asc;
```

### 6. Analysis

The following SQL queries were developed to answer specific sustainability questions

### Sustainable Choices

* Count of years for each country used more renewable energy than fossil fuel for both period of 2000-2024 and COVID lockdown 2020-2022
* Average number of countries making sustainable choices per year both period of 2000-2024 and COVID lockdown 2020-2022

```sql
with choices as(select Country,Year 
from energy_global 
where Total_RW_Energy>Total_FF)
select Country,count(Year) as no_of_year_of_sustainable_choices 
from choices
group by Country 
order by no_of_year_of_sustainable_choices desc;

with choices as(select Country,Year 
from energy_global 
where Total_RW_Energy>Total_FF and Year>='2020' and Year<='2022')
select Country,count(Year) as no_of_year_of_sustainable_choices 
from choices
group by Country 
order by no_of_year_of_sustainable_choices desc;

with year_choices as(select Country,Year 
from energy_global 
where Total_RW_Energy>Total_FF ),
year_choices_avg as(select Year,count(Country) as no_of_countries_sustainable_choices 
from year_choices
group by Year
order by Year desc)
select round(avg(no_of_countries_sustainable_choices),0) as  avg_no_of_countries_sustainable_choices_2000_2024 
from year_choices_avg;

with year_choices as(select Country,Year 
from energy_global 
where Total_RW_Energy>Total_FF and Year>='2020' and Year<='2022'),
year_choices_avg as(select Year,count(Country) as no_of_countries_sustainable_choices 
from year_choices
group by Year
order by Year desc)
select round(avg(no_of_countries_sustainable_choices),0) as avg_no_of_countries_sustainable_choices_covid
from year_choices_avg;
```

### Sustainability Goals

* Count of years for each country achieving sustainabilty goals for both period of 2000-2024 and COVID lockdown 2020-2022
* Average number of countries achieving sustainabilty goals for both period of 2000-2024 and COVID lockdown 2020-2022

```sql
with yoy as(select Country,Year,round((ifnull(lag(Per_Capita_Energy_Use) over(partition by Country order by Year asc),0)-Per_Capita_Energy_Use)*100/Per_Capita_Energy_Use,2) as yoy_Per_Capita_Energy_Use,
round((ifnull(lag(Total_Carbon_Emission) over(partition by Country order by Year asc),0)-Total_Carbon_Emission)*100/Total_Carbon_Emission,2) as yoy_Carbon_Emission
from energy_global)
select Country,count(Year) as No_of_years_achieving_sustainability_goals
from yoy 
where yoy_Per_Capita_Energy_Use>0 and yoy_Carbon_Emission<0
group by Country
order by No_of_years_achieving_sustainability_goals desc;


with yoy as(select Country,Year,round((ifnull(lag(Per_Capita_Energy_Use) over(partition by Country order by Year asc),0)-Per_Capita_Energy_Use)*100/Per_Capita_Energy_Use,2) as yoy_Per_Capita_Energy_Use,
round((ifnull(lag(Total_Carbon_Emission) over(partition by Country order by Year asc),0)-Total_Carbon_Emission)*100/Total_Carbon_Emission,2) as yoy_Carbon_Emission
from energy_global)
select Country,count(Year) as No_of_years_achieving_sustainability_goals
from yoy 
where yoy_Per_Capita_Energy_Use>0 and yoy_Carbon_Emission<0 and Year>='2020' and Year<='2022'
group by Country
order by No_of_years_achieving_sustainability_goals desc;


with yoy_country as(select Country,Year,round((ifnull(lag(Per_Capita_Energy_Use) over(partition by Country order by Year asc),0)-Per_Capita_Energy_Use)*100/Per_Capita_Energy_Use,2) as yoy_Per_Capita_Energy_Use,
round((ifnull(lag(Total_Carbon_Emission) over(partition by Country order by Year asc),0)-Total_Carbon_Emission)*100/Total_Carbon_Emission,2) as yoy_Carbon_Emission
from energy_global),
yoy_country_avg as(select Year,count(Country) as Country_achieving_sustainability_goals
from yoy_country 
where yoy_Per_Capita_Energy_Use>0 and yoy_Carbon_Emission<0
group by Year
order by Year desc)
select round(avg(Country_achieving_sustainability_goals),0) as avg_no_of_country_achieving_sustainability_goals_2000_2024
from yoy_country_avg;


with yoy_country as(select Country,Year,round((ifnull(lag(Per_Capita_Energy_Use) over(partition by Country order by Year asc),0)-Per_Capita_Energy_Use)*100/Per_Capita_Energy_Use,2) as yoy_Per_Capita_Energy_Use,
round((ifnull(lag(Total_Carbon_Emission) over(partition by Country order by Year asc),0)-Total_Carbon_Emission)*100/Total_Carbon_Emission,2) as yoy_Carbon_Emission
from energy_global),
yoy_country_avg as(select Year,count(Country) as Country_achieving_sustainability_goals
from yoy_country 
where yoy_Per_Capita_Energy_Use>0 and yoy_Carbon_Emission<0 and Year>='2020' and Year<='2022'
group by Year
order by Year desc)
select round(avg(Country_achieving_sustainability_goals),0) as avg_no_of_country_achieving_sustainability_goals_covid
from yoy_country_avg;
```

### Emission Contributions

* Comparison between industrial and household energy use
* Emission rankings per year and count number of years for each country has received lowest ranking in emission
* Ranking is done for period of 2000-2024 and COVID lockdown 2020-2022 

```sql
select Country,count(Year) as no_of_years_industries_carbon_emission 
from energy_global
where Total_Ind_Energy>Total_House_Energy
group by Country
order by no_of_years_industries_carbon_emission asc;

with ranking as(select Country,year,Total_Carbon_Emission,dense_rank() over(partition by Year order by Total_Carbon_Emission asc) as ranking 
from energy_global)
select Country,count(*) as no_times_lowest_ranking_carbon_emission 
from ranking
where ranking=1
group by Country
order by no_times_lowest_ranking_carbon_emission desc;

with ranking as(select Country,year,Total_Carbon_Emission,dense_rank() over(partition by Year order by Total_Carbon_Emission asc) as ranking 
from energy_global
where Year>='2020' and Year<='2022')
select Country,count(*) as no_times_lowest_ranking_carbon_emission 
from ranking
where ranking=1
group by Country
order by no_times_lowest_ranking_carbon_emission desc;
```

### Carbon emission Statistics

* Country-wise average CO₂ emissions
* Percentage contribution of each country to global emissions
* Average Carbon emission during period of 2000-2024 and covid lockdown
* Percentage change in Carbon emission in covid lock down compared to  period of 2000-2024

```sql
with avg_2024 as(select round(avg(Total_Carbon_Emission),2) as Avg_Carbon_Emission_2000_2024
from energy_global),
avg_covid as(select round(avg(Total_Carbon_Emission),2) as Avg_Carbon_Emission_covid
from energy_global
where Year>='2020' and Year<='2022')
select g.Avg_Carbon_Emission_2000_2024,c.Avg_Carbon_Emission_covid,
round((c.Avg_Carbon_Emission_covid-g.Avg_Carbon_Emission_2000_2024)*100/g.Avg_Carbon_Emission_2000_2024,2) as percentage_chnage
from avg_2024 g
cross join avg_covid c;

with avg_emissions as(select Country,round(avg(Total_Carbon_Emission),2) as avg_carbon_emissions
from energy_global 
group by Country)
select Country,avg_carbon_emissions,round(avg_carbon_emissions*100/(select sum(avg_carbon_emissions) from avg_emissions),2) as contribution
from avg_emissions
order by contribution asc;

with avg_emissions as(select Country,round(avg(Total_Carbon_Emission),2) as avg_carbon_emissions
from energy_global 
where Year>='2020' and Year<='2022'
group by Country)
select Country,avg_carbon_emissions,round(avg_carbon_emissions*100/(select sum(avg_carbon_emissions) from avg_emissions),2) as contribution
from avg_emissions
order by contribution asc;
```
## Findings
  
***Sustainability Choices** — Australia, Canada, and Russia made sustainable choices for 18 years each between 2000 and 2024, the highest among all countries. During the COVID-19 lockdown (2020–2022), Canada and India led with 3 sustainable years each. On average, 6 countries per year made sustainable choices from 2000 to 2024, while this average rose to 7 during the lockdown period.

***Sustainability Goals** — China achieved sustainability goals by increasing per capita energy use and decreasing emissions in 9 out of 25 years between 2000 and 2024, the highest among all countries. During the COVID period, 7 out of 10 countries achieved the goal for 1 year of the 3 years. On average, 3 countries per year met sustainability goals from 2000 to 2024.

***Carbon Emissions** — From 2000 to 2024, Russia contributed the lowest share of total emissions at 9.5%, while the USA contributed the highest at 10.42%. During the COVID lockdown, Japan had the lowest contribution at 7.15% and the USA the highest at 11.78%. The average annual carbon emissions were 101,445.92 million tons from 2000 to 2024, compared to 106,052.46 million tons during the lockdown, reflecting a 4.5% increase in carbon emission during COVID.

## Conclusion

This project demonstrates advanced SQL for data cleaning, EDA, and sustainability analysis on global energy data. It provides insights on renewable energy use, emissions trends, and sustainability goals across countries. The analysis can support companies and governments in tracking and improving sustainability performance.

## How to Use This Project

1. Clone or download the repository  
2. Run the SQL script in a MySQL-compatible environment  
3. Execute queries for analysis  

## Author

**Jayatri Pati**  

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

Email: jayatripati02@gmail.com




