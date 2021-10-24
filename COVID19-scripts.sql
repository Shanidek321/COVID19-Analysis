select *
from CovidDeaths$
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not null
order by 1,2

-- looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in Israel
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%israel%'
and where continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from CovidDeaths$
where continent is not null
-- where location like '%israel%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths$
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

--Showing continent with Highest Death Count per Population
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers
select date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
from CovidDeaths$
where continent is not null
Group by date
order by 1,2

select SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
from CovidDeaths$
where continent is not null
order by 1,2

-- Looking at Total Population vs Vaccinations

-- USE CTE

with PopvsVacc(continent, Location,Date, Population,New_Vaccinations,
RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location order by dea.location, dea.date)
as  RollingPeopleVaccinated
from CovidVaccinations$ vac join CovidDeaths$ dea
on vac.location = dea.location and vac.date = dea.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/Population)*100
From PopvsVacc

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location order by dea.location, dea.date)
as  RollingPeopleVaccinated
from CovidVaccinations$ vac join CovidDeaths$ dea
on vac.location = dea.location and vac.date = dea.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location order by dea.location, dea.date)
as  RollingPeopleVaccinated
from CovidVaccinations$ vac join CovidDeaths$ dea
on vac.location = dea.location and vac.date = dea.date
where dea.continent is not null
-- order by 2,3
