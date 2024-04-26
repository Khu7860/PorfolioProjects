select * 
from PortfolioProject..CovidDeath
Order by 3, 4

--select * 
--from ..CovidVaccination
--Order by 3, 4

--Select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeath

--Select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeath
--order by 3, 4

-- We will start looking Total Cases vs Total Deaths


Select location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%States%'
order by 1, 2

-- Due to the large dataset, we had to change the Datatypes to float so we can work with them.
--ALTER TABLE ..CovidDeath 
--ALTER COLUMN total_deaths float;

-- Looking at total cases vs Population

-- shows what percentage of population got Covid
Select location, date, total_cases, population,  (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeath
where location like '%States%'
order by 1, 2


-- Looking at countries with highest infection rates

Select location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
from PortfolioProject..CovidDeath
-- where location like '%States%'
Group by location, population
order by InfectedPercentage DESC

-- Showing highest death count per population

select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by location
order by TotalDeathCount desc


-- Can also be achieved by this way

select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is null
group by location
order by TotalDeathCount desc

-- Breaking it down by continent
-- Showing continents with the highest death count per population.

select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers / Total death percentage

Select location, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, 
SUM(new_deaths)/NULLIF(SUM(new_cases), 0)*100 as DeathPercentage  
from PortfolioProject..CovidDeath
where continent is not null
group by location
order by 1, 2 desc

-- location for total population vs vaccination

Select DEA.continent, DEA.location, dea.date, dea.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccination as VAC
join PortfolioProject..CovidDeath as DEA
	on VAC.location = DEA.location
	and VAC.date = DEA.date
where DEA.continent is not null
order by 1,2,3

-- USE CTE

WITH PopVSDea (Continent, Location, Date, Population, Vaccinations, RollingPeopleVaccinated)

as

(
Select DEA.continent, DEA.location, dea.date, dea.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccination as VAC
join PortfolioProject..CovidDeath as DEA
	on VAC.location = DEA.location
	and VAC.date = DEA.date
where DEA.continent is not null
--order by 1,2,3
)

Select *, RollingPeopleVaccinated/Population*100
from PopVSDea

--TEMP TABLE
-- adding first line just for altration
DROP Table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccination float,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
Select DEA.continent, DEA.location, dea.date, dea.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccination as VAC
join PortfolioProject..CovidDeath as DEA
	on VAC.location = DEA.location
	and VAC.date = DEA.date
where DEA.continent is not null
--order by 1,2,3

Select *, RollingPeopleVaccinated/Population*100
from #PercentagePopulationVaccinated


-- creating view

Create view PercentagePopulationVaccinated as
Select DEA.continent, DEA.location, dea.date, dea.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccination as VAC
join PortfolioProject..CovidDeath as DEA
	on VAC.location = DEA.location
	and VAC.date = DEA.date
where DEA.continent is not null
