/*** This sustainability project in this I analyse:
1)On an average how many countries are acheieving sustainability goals or practice sustainability during 2000-2024 and covid lockdown(2020-2022)
2)Each country how many years out of 2000-2024 and covid lockdown(2020-2022) were able to cheieving sustaibility goals or practice sustaibility
***/

#databse creation
create database sustainability;
use sustainability;


/*** Units in which values are present in each column
Total_Energy_Consumption (TWh)
Per Capita Energy Use (kWh)
Renewable Energy Share (%)
Fossil Fuel Dependency (%)
Industrial Energy Use (%)
Household Energy Use (%)
Carbon Emissions (Million Tons)
Energy Price Index (USD/kWh)***/

drop table if exists global_energy_data;

# table creation and import 
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

#datatype of columns in dataset
describe global_energy_data;

#overview of dataset
select * from global_energy_data limit 10;

#change datatype of year column from int to year
alter table global_energy_data
modify column Year Year;

describe global_energy_data;

select * from global_energy_data limit 10;

# null values in dataset
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

# duplicates in dataset
select * from global_energy_data
group by Country,Year,Total_Energy_Consumption,Per_Capita_Energy_Use,Renewable_Energy_Share,Fossil_Fuel_Dependency,Industrial_Energy_Use,
Household_Energy_Use,Carbon_Emissions,Energy_Price_Index
having count(*)>1;

# detection of ouliers in dataset
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

#Exploratory Data Analysis
# Shape of global_energy_data
select count(*) as no_of_records from global_energy_data;

# Number of countries data in global_energy_data
select count(distinct Country) as total_countries from global_energy_data;

# Countries Name 
select distinct Country as countries from global_energy_data;

#Number of year data in global_energy_data
select count(distinct Year) as total_year from global_energy_data;

# Year present in dataset
select distinct Year as years from global_energy_data order by Year;

# Check records available for each year for each country
select Country,count( distinct Year) as years_data_available from global_energy_data 
group by Country;

#Record prsent for each country for each year
select Country,Year,count(*) as record from global_energy_data 
group by Country,Year;
 
#Calculate new parameter
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

#created view to remove uneccessary columns and to do grouping
create view energy_global
as select Country,Year,round(sum(Total_Energy_Consumption),2) as Total_Energy_Consumed,round(sum(Total_Energy_Consumption)*pow(10,9)/sum(population),2) as Per_Capita_Energy_Use,
round(sum(Renewable_Energy),2) as Total_RW_Energy,round(sum(Fossil_Fuel),2) as Total_FF,round(sum(Industrial_Energy),2) as Total_Ind_Energy,
round(sum(Household_Energy),2) as Total_House_Energy,round(sum(Carbon_Emissions),2) as Total_Carbon_Emission 
from global_energy_data 
group by Country,Year
order by Year asc,Country asc;

select * from energy_global;

#analysis

#Sustainable choices
#Analyse that countries making more sustainable choices for how many years and On an average how many countries make sustainable choices 
#sustainable choices meaning relying on more renewable energy than on fossil fuel
#Countries making more sustainable choices every year during period of 2000-2024
with choices as(select Country,Year 
from energy_global 
where Total_RW_Energy>Total_FF)
select Country,count(Year) as no_of_year_of_sustainable_choices 
from choices
group by Country 
order by no_of_year_of_sustainable_choices desc;

#Countries making more sustainable choices during covid lockdown of 2020-2022
with choices as(select Country,Year 
from energy_global 
where Total_RW_Energy>Total_FF and Year>='2020' and Year<='2022')
select Country,count(Year) as no_of_year_of_sustainable_choices 
from choices
group by Country 
order by no_of_year_of_sustainable_choices desc;

#On an average how many countries are making more sustainable choices during period of 2000-2024
with year_choices as(select Country,Year 
from energy_global 
where Total_RW_Energy>Total_FF ),
year_choices_avg as(select Year,count(Country) as no_of_countries_sustainable_choices 
from year_choices
group by Year
order by Year desc)
select round(avg(no_of_countries_sustainable_choices),0) as  avg_no_of_countries_sustainable_choices_2000_2024 
from year_choices_avg;

#On an average how many countries are making more sustainable choices during covid lockdown 2020-2022
with year_choices as(select Country,Year 
from energy_global 
where Total_RW_Energy>Total_FF and Year>='2020' and Year<='2022'),
year_choices_avg as(select Year,count(Country) as no_of_countries_sustainable_choices 
from year_choices
group by Year
order by Year desc)
select round(avg(no_of_countries_sustainable_choices),0) as avg_no_of_countries_sustainable_choices_covid
from year_choices_avg;

#Sustainability goals
#Analysing Countries and number of years achieving sustainability goals and on an average how many countries achieve sustainability goals
#sustainability goals means by increasing in per capita energy use and decreasing carbon emission year on year 
#Countries and number of years achieving sustainability goals during 2000-2024 
with yoy as(select Country,Year,round((ifnull(lag(Per_Capita_Energy_Use) over(partition by Country order by Year asc),0)-Per_Capita_Energy_Use)*100/Per_Capita_Energy_Use,2) as yoy_Per_Capita_Energy_Use,
round((ifnull(lag(Total_Carbon_Emission) over(partition by Country order by Year asc),0)-Total_Carbon_Emission)*100/Total_Carbon_Emission,2) as yoy_Carbon_Emission
from energy_global)
select Country,count(Year) as No_of_years_achieving_sustainability_goals
from yoy 
where yoy_Per_Capita_Energy_Use>0 and yoy_Carbon_Emission<0
group by Country
order by No_of_years_achieving_sustainability_goals desc;

#Countries and number of years achieving sustainability goals during covid lockdown 2020-2022 
with yoy as(select Country,Year,round((ifnull(lag(Per_Capita_Energy_Use) over(partition by Country order by Year asc),0)-Per_Capita_Energy_Use)*100/Per_Capita_Energy_Use,2) as yoy_Per_Capita_Energy_Use,
round((ifnull(lag(Total_Carbon_Emission) over(partition by Country order by Year asc),0)-Total_Carbon_Emission)*100/Total_Carbon_Emission,2) as yoy_Carbon_Emission
from energy_global)
select Country,count(Year) as No_of_years_achieving_sustainability_goals
from yoy 
where yoy_Per_Capita_Energy_Use>0 and yoy_Carbon_Emission<0 and Year>='2020' and Year<='2022'
group by Country
order by No_of_years_achieving_sustainability_goals desc;

#On an average how many countries are achieving sustainability goals during 2000-2024
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

#On an average how many countries are achieving sustainability during covid lockdown 2020-2022
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

#Insdustry contribution to carbon emission 
#Country and no of years where insdustries have contributed more than household in carbon emissions over period of 2000-2024
select Country,count(Year) as no_of_years_industries_carbon_emission 
from energy_global
where Total_Ind_Energy>Total_House_Energy
group by Country
order by no_of_years_industries_carbon_emission asc;

#Ranking in carbon emission
#Number of times a country has lowest carbon emission each year in the period of 2000-2024
with ranking as(select Country,year,Total_Carbon_Emission,dense_rank() over(partition by Year order by Total_Carbon_Emission asc) as ranking 
from energy_global)
select Country,count(*) as no_times_lowest_ranking_carbon_emission 
from ranking
where ranking=1
group by Country
order by no_times_lowest_ranking_carbon_emission desc;

#Number of times a country has lowest carbon emission each year during covid lockdown 2020-2022
with ranking as(select Country,year,Total_Carbon_Emission,dense_rank() over(partition by Year order by Total_Carbon_Emission asc) as ranking 
from energy_global
where Year>='2020' and Year<='2022')
select Country,count(*) as no_times_lowest_ranking_carbon_emission 
from ranking
where ranking=1
group by Country
order by no_times_lowest_ranking_carbon_emission desc;

#Average carbon emission
#Average amount of carbon emission done all the countries over period of 2000-2024
select round(avg(Total_Carbon_Emission),2) as Avg_Carbon_Emission_2000_2024
from energy_global;

#Average amount of carbon emission by each country over period of 2000-2024 and its percentage contribution
with avg_emissions as(select Country,round(avg(Total_Carbon_Emission),2) as avg_carbon_emissions
from energy_global 
group by Country)
select Country,avg_carbon_emissions,round(avg_carbon_emissions*100/(select sum(avg_carbon_emissions) from avg_emissions),2) as contribution
from avg_emissions
order by contribution asc;

#Average amount of carbon emission done all the countries during covid lockdown(2020-2022)
select round(avg(Total_Carbon_Emission),2) as Avg_Carbon_Emission_covid
from energy_global
where Year>='2020' and Year<='2022';

#Average amount of carbon emission by each country during covid lockdown(2020-2022)
with avg_emissions as(select Country,round(avg(Total_Carbon_Emission),2) as avg_carbon_emissions
from energy_global 
where Year>='2020' and Year<='2022'
group by Country)
select Country,avg_carbon_emissions,round(avg_carbon_emissions*100/(select sum(avg_carbon_emissions) from avg_emissions),2) as contribution
from avg_emissions
order by contribution asc;


