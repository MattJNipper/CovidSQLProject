Select *
From CovidDataProject..CovidDeaths
order by 3,4

Select *
From CovidDataProject..CovidVaccinations
order by 3,4

 --Looking at all the relevant Data

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDataProject..CovidDeaths
order by 3,4

 --Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentDeath
From CovidDataProject..CovidDeaths
order by 1,2

 --Total Cases vs Total Deaths in the US

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentDeath
From CovidDataProject..CovidDeaths
order by 1,2

 --Total Cases vs Population in the US
 --What percentage actually contracts covid?

Select location, date, population, total_cases, (total_cases/population)*100 as PercentContractedCovid
From CovidDataProject..CovidDeaths
--Where location like '%United States%' -- Use this to see just the U.S.
order by 1,2

--Country Infection Rate vs Population

Select location, population, MAX(total_cases) as InfectionPeak, (Max(total_cases)/population)*100 as PeakPercentContractedCovid
From CovidDataProject..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PeakPercentContractedCovid desc

 --Total Covid death count vs population - Group by Country

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDataProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

 --Total Covid death count vs population - Group by Continent

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From CovidDataProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

-- Global info --

-- Covid Mortality rate  time

Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDataProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Covid Mortality rate  time

Select SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDataProject..CovidDeaths
where continent is not null
order by 1,2

-- Vaccine info --

Select *
From CovidDataProject..CovidDeaths dea
Join CovidDataProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Total pop vs total vaccines over time

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidDataProject..CovidDeaths dea
Join CovidDataProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- Totaling vaccines over time for a rolling total # vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaxed
From CovidDataProject..CovidDeaths dea
Join CovidDataProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CTEs --

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
-- Totaling vaccines over time for a rolling total # vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaxed
From CovidDataProject..CovidDeaths dea
Join CovidDataProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100 as RollingVaxVSPopulation
From PopvsVac

-- Same thing but with Temp Table --

DROP TABLE IF EXISTS CovidDataProject..#PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaxed
From CovidDataProject..CovidDeaths dea
Join CovidDataProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as RollingVaxVSPopulation
From #PercentPopVaccinated

-- Creating views for use in Tableau --

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingTotalVaxed
From CovidDataProject..CovidDeaths dea
Join CovidDataProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null