
/*

Data Exploration in SQL

*/



select *
from CovidDeaths
order by 3,4


-- Data that we are going to be starting with

select location, date, total_cases,new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2


--Shows the likelihood of dying if someone contract covid in India

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'India'
order by 1,2


--Shows percentage of population infected with covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location = 'India'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc


--Countries with Highest Death Count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

--Continents with Highest Infection Rate compared to Population

select continent, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null
group by continent
order by PercentPopulationInfected desc


--Showing continents with the Highest Death Count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent 
order by TotalDeathCount desc


--GLOBAL NUMBERS

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


--Shows the Population that has recieved Covid Vaccine

select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
sum(convert(int,cvac.new_vaccinations)) over (partition by cdea.location order by cdea.location, cdea.date) as RollingpeopleVaccinated
from CovidDeaths cdea
join CovidVaccinations cvac
  on cdea.location = cvac.location
  and cdea.date = cvac.date
where cdea.continent is not null
order by 2,3


--Using CTE and Temp table to perform calculation on Partition by in previous query

--Using CTE to show Percentage of Population that recieved Vaccination

with PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
sum(convert(int,cvac.new_vaccinations)) over (partition by cdea.location order by cdea.location, cdea.date) as RollingpeopleVaccinated
from CovidDeaths cdea
join CovidVaccinations cvac
  on cdea.location = cvac.location
  and cdea.date = cvac.date
where cdea.continent is not null
)
select*, (RollingPeopleVaccinated/Population)*100 as PercentPopVaccinated
from PopvsVac


--Using Temp Table to show Percentade of Population that recieved Vaccination

drop table if exists  #PopulationVaccinated
create table #PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PopulationVaccinated
select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
sum(convert(int,cvac.new_vaccinations)) over (partition by cdea.location order by cdea.location, cdea.date) as RollingpeopleVaccinated
from CovidDeaths cdea
join CovidVaccinations cvac
  on cdea.location = cvac.location
  and cdea.date = cvac.date

select *, ( RollingPeopleVaccinated/Population)*100 as PercentPopVaccinated
from  #PopulationVaccinated
order by 2,3



-- Creating View for future Visualization

create view PopulationVaccinated as 
select cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations,
sum(convert(int,cvac.new_vaccinations)) over (partition by cdea.location order by cdea.location, cdea.date) as RollingpeopleVaccinated
from CovidDeaths cdea
join CovidVaccinations cvac
  on cdea.location = cvac.location
  and cdea.date = cvac.date
where cdea.continent is not null
