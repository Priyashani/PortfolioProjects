-- Exploring Covid 19 dataset
-- Changing data types, Joins, CTE's, Temp tables, Windows functions, Aggregate functions, Creating Views


select * from Portfolio.dbo.CovidDeaths 
Where continent is not null
order by 3,4

select * from Portfolio..CovidVaccinations
order by 3,4

-- Looking at data to be analysed in CovidDeaths table

select location,date,total_cases,new_cases,total_deaths,population 
from Portfolio..CovidDeaths
Where continent is not null -- To remove the summary records
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where location like '%Canada%' 
order by 1,2

-- Looking at the total cases vs population
-- Percentage of pupulation infected with covid

Select location,date,total_cases,population, (total_cases/population)*100 as CasePercentage
From Portfolio..CovidDeaths
Where continent is not null
--Where location like '%Canada%' 
order by 1,2


-- Looking at Countries with highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases/population))*100 as CasePercentage
From Portfolio..CovidDeaths
--Where location like '%Canada%' 
Where continent is not null
Group by location,population
order by CasePercentage desc

-- Showing countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null
Group by Location
Order By TotalDeathCount desc

-- BY CONTINENT --

-- Showing the continents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is null -- To get the records for the continents
Group by location
Order By TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where continent is not null
--Group By date
Order By 1,2


-- Looking at total population vs vaccination
-- Percentage of population that received at least one Covid vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by  dea.Location 
	order by dea.location,dea.date) as RollingPeopleVaccinted
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE to perform calculation on partition by in previous query

With PopvsVac(continent, location, date, population, newVaccinations, rollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by  dea.Location 
	order by dea.location,dea.date) as RollingPeopleVaccinted
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (rollingPeopleVaccinated/population)*100
from PopvsVac
order by 2,3

-- Doing the same with TEMP Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date Datetime,
population numeric,
newVaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by  dea.Location 
	order by dea.location,dea.date) as RollingPeopleVaccinted
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (rollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
order by 2,3

