 --Looking at all the relevant Covid Death Data

SELECT	location
	,date
	,total_cases
	,new_cases
	,total_deaths
	,population
FROM CovidDataProject..CovidDeaths

ORDER BY 3,4


 --Total Cases vs Total Deaths

SELECT	location
	,date
	,total_cases
	,total_deaths
	,(total_deaths/total_cases)*100 AS percent_death
FROM CovidDataProject..CovidDeaths

ORDER BY 1,2


 --Total Cases vs Total Deaths in the US

SELECT	location
	,date
	,total_cases
	,total_deaths
	,(total_deaths/total_cases)*100 AS percent_death
FROM CovidDataProject..CovidDeaths

WHERE location like '%United States%'
ORDER BY 1,2


 --Total Cases vs Population in the US
 --What percentage actually contracts covid?

SELECT	location
	,date
	,population
	,total_cases
	,(total_cases/population)*100 AS percent_contracted_covid
FROM CovidDataProject..CovidDeaths

WHERE location like '%United States%' -- Use this to see just the U.S.
ORDER BY 1,2


--Country Infection Rate vs Population

SELECT	location
	,population
	,MAX(total_cases)					AS infection_peak
	,(Max(total_cases)/population)*100	AS peak_percent_contracted_covid
FROM CovidDataProject..CovidDeaths

GROUP BY location, population
ORDER BY peak_percent_contracted_covid desc


 --Total Covid death count vs population - GROUP BY Country

SELECT	location
	,Max(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidDataProject..CovidDeaths

WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count desc


 --Total Covid death count vs population - GROUP BY Continent

SELECT	location
	,Max(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidDataProject..CovidDeaths

WHERE continent is null
GROUP BY location
ORDER BY total_death_count desc


-- Global info --

-- Covid Mortality rate  time

SELECT	date
	,SUM(new_cases)
	,SUM(CAST(new_deaths AS INT))
	,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM CovidDataProject..CovidDeaths

WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Covid Mortality rate  time

SELECT	SUM(new_cases)
	,SUM(CAST(new_deaths AS INT))
	,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM CovidDataProject..CovidDeaths

WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total pop vs total vaccines over time

SELECT	dea.continent
	,dea.location
	,dea.date, dea.population
	,vac.new_vaccinations
FROM CovidDataProject..CovidDeaths dea
JOIN CovidDataProject..CovidVaccinations vac
	On	dea.location = vac.location
		AND dea.date = vac.date

WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3


-- Totaling vaccines over time for a rolling total # of vaccinated

SELECT	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaxed
FROM CovidDataProject..CovidDeaths dea
JOIN CovidDataProject..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date

WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- CTEs --

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_people_vaxed) AS
(
	SELECT	dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaxed
	FROM CovidDataProject..CovidDeaths dea
	JOIN CovidDataProject..CovidVaccinations vac
		On	dea.location = vac.location
			AND dea.date = vac.date

	WHERE dea.continent IS NOT NULL
)

SELECT	*
		,(rolling_people_vaxed/Population)*100 AS rolling_vax_vs_population
FROM PopvsVac


-- Same thing but with Temp Table --

DROP TABLE IF EXISTS CovidDataProject..#PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaxed numeric
)

INSERT INTO #PercentPopVaccinated
SELECT	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaxed
FROM CovidDataProject..CovidDeaths dea
JOIN CovidDataProject..CovidVaccinations vac
	ON	dea.location = vac.location
		AND dea.date = vac.date

WHERE dea.continent IS NOT NULL

SELECT	*
		,(rolling_people_vaxed/Population)*100 AS RollingVaxVSPopulation
FROM #PercentPopVaccinated


-- Creating views for use in Tableau --

Create view PercentPopulationVaccinated as
SELECT	dea.continent
	,dea.location
	,dea.date, dea.population
	,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaxed
FROM CovidDataProject..CovidDeaths dea
JOIN CovidDataProject..CovidVaccinations vac
	ON	dea.location = vac.location
		AND dea.date = vac.date

WHERE dea.continent IS NOT NULL


/*Queries used for Tableau Project*/

-- 1. 

SELECT	SUM(new_cases) AS total_cases
	,SUM(CAST(new_deaths AS INT)) AS total_deaths
	,SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDataProject..CovidDeaths

WHERE continent IS NOT NULL 
ORDER BY 1,2


-- 2. 

SELECT	location
	,SUM(CAST(new_deaths AS INT)) AS total_death_count
FROM CovidDataProject..CovidDeaths
WHERE	continent is null 
		AND location not in ('World', 'European Union', 'International')

GROUP BY location
ORDER BY total_death_count desc


-- 3.

SELECT	location
	,population
	,MAX(total_cases) AS highest_infection_count
	,Max((total_cases/population))*100 AS percent_population_infected
FROM CovidDataProject..CovidDeaths
GROUP BY location, population
ORDER BY percent_population_infected desc


-- 4.

SELECT	Location
	,population
	,date
	,MAX(total_cases) AS highest_infection_count
	,Max((total_cases/population))*100 AS percent_population_infected
FROM CovidDataProject..CovidDeaths

GROUP BY Location, Population, date
ORDER BY percent_population_infected desc
