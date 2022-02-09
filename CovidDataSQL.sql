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