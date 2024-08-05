Select *
from CovidDeaths
order by 3,4
-- here 3 and for refere to the column number 3 & 4

Select *
from CovidVaccinations
order by 3,4

-- here select the Data 
select location,date, total_cases,new_cases,total_deaths,population
from CovidDeaths
order by location,date -- could replace with column number   1,2


-- show percent of death for total cases in egypt
-- Shows likelihood of dying if you contract covid in your country
select location,date ,population, total_cases,total_deaths,(total_deaths/total_cases)*100 as deaths_of_total_cases_per
from CovidDeaths
where location like 'Egypt'
order by  1,2

-- show percent of cases for population in USA
-- Shows what percentage of population infected with Covid
select location,date ,population, total_cases,total_deaths,(total_cases/population)*100 as deathspopulationPercentage
from CovidDeaths
where location like '%States%'
order by  1,2


-- Show the highest Percentage of Death

select location ,population,max(total_deaths) as MaxNumOfDeath,max(total_deaths/population)*100 as deathspopulationPercentage
from CovidDeaths
group by location,population 
order by  deathspopulationPercentage desc


-- Show the highest Percentage of Infected

select location ,population,max(total_cases) as MaxNumOfinfected,max(total_cases/population)*100 as deathspopulationPercentage
from CovidDeaths
group by location,population 
order by  deathspopulationPercentage desc


-- show the Highest number of death cases   for each country


select location ,population,max(cast(total_deaths as int)) as MaxNumOfinfected
from CovidDeaths
where continent is not null
group by location,population 
order by  MaxNumOfinfected desc



-- Show the continents numbers

  --  number of infected people and dead people in each continent
select location,Max(cast(total_cases as int)) as Totalcases ,max(cast(total_deaths as int)) as totaldeaths
from CovidDeaths
WHERE continent IS NULL 
group by  location
order by totaldeaths desc


-- Show the Global numbers

  --  number of infected people and dead people the whole world by date

select date,sum(new_cases) as total_new_case ,sum(cast(new_deaths as int)) as Total_new_death
,sum(cast(new_deaths as int)) / sum(new_cases) *100 as Death_Rate
from CovidDeaths
WHERE continent IS not NULL 
group by  date
order by 1,2 desc


-- to calc all cases overall
select sum(new_cases) as total_new_case ,sum(cast(new_deaths as int)) as Total_new_death
,sum(cast(new_deaths as int)) / sum(new_cases) *100 as Death_Rate
from CovidDeaths
WHERE continent IS not NULL 
order by 1,2 desc



-- Looking to population and  vaccinations

select deathh.continent,deathh.location,deathh.date,deathh.population,vacc.new_vaccinations
,sum(CONVERT(int,vacc.new_vaccinations)) OVER(partition by deathh.location 
order by deathh.location,deathh.date) as peopleVacc
from CovidDeaths as deathh
join CovidVaccinations as vacc
on deathh.location=vacc.location and deathh.date = vacc.date
where deathh.continent is not null
order by 2,3


--Using CTE

with popvacc(continent,location ,date ,population , new_vaccinations, peopleVacc)
as 
(
select deathh.continent,deathh.location,deathh.date,deathh.population,vacc.new_vaccinations
,sum(CONVERT(int,vacc.new_vaccinations)) OVER(partition by deathh.location 
order by deathh.location,deathh.date) as peopleVacc
from CovidDeaths as deathh
join CovidVaccinations as vacc
	on deathh.location=vacc.location and deathh.date = vacc.date
where deathh.continent is not null
)
select *,(peopleVacc / population) *100 as Vaccrate
from popvacc





-- Temporary Table


drop table if exists #percentage_of_vaccinated_population
create table #percentage_of_vaccinated_population
(
continent nvarchar(225),
location nvarchar(225),
Data datetime,
population numeric,
new_vacc numeric,
peopleVacc numeric
)

insert into #percentage_of_vaccinated_population
select deathh.continent,deathh.location,deathh.date,deathh.population,vacc.new_vaccinations
,sum(CONVERT(int,vacc.new_vaccinations)) OVER(partition by deathh.location 
order by deathh.location,deathh.date) as peopleVacc
from CovidDeaths as deathh
join CovidVaccinations as vacc
	on deathh.location=vacc.location and deathh.date = vacc.date



select *,(peopleVacc / population) *100 as Vaccrate
from #percentage_of_vaccinated_population




--Creating View to store data for visualization

create view percentPopulationVaccinated as 
select deathh.continent,deathh.location,deathh.date,deathh.population,vacc.new_vaccinations
,sum(CONVERT(int,vacc.new_vaccinations)) OVER(partition by deathh.location 
order by deathh.location,deathh.date) as peopleVacc
from CovidDeaths as deathh
join CovidVaccinations as vacc
	on deathh.location=vacc.location and deathh.date = vacc.date
where deathh.continent is not null


select *
from percentPopulationVaccinated
