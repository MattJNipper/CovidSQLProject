--Select *
--From CovidDataProject..CovidDeaths
--order by 3,4

--Select *
--From CovidDataProject..CovidVaccinations
--order by 3,4

-- Select Data

--Select location, date, total_cases, new_cases, total_deaths, population
--From CovidDataProject..CovidDeaths
--order by 3,4

-- Total Cases vs Total Deaths

--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentDeath
--From CovidDataProject..CovidDeaths
--order by 1,2

-- Total Cases vs Total Deaths in the US

--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentDeath
--From CovidDataProject..CovidDeaths
--Where location like '%states%'
--order by 1,2

-- Total Cases vs Population in the US
-- What percentage actually contracts covid?

--Select location, date, population, total_cases, (total_cases/population)*100 as PercentContractedCovid
--From CovidDataProject..CovidDeaths
--Where location like '%states%'
--order by 1,2

--Country Infection Rate Compared With Population

Select location, date, population, total_cases, (total_cases/population)*100 as PercentContractedCovid
From CovidDataProject..CovidDeaths
Where location like '%states%'
order by 1,2