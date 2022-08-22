SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4
--SELECT *
--FROM PortfolioProject..CovidVaccines
--ORDER BY 3,4
--Select Data that will be used
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER By 1,2

--Observing total cases vs total deaths
-- Shows Covid-19 infection related mortality rate
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER By 1,2

--Looking at Total Cases vs Population
--Shows what percentage of the population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS CovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER By 1,2

--Looking at countries with Highest Infection rate compared to population

SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
GROUP BY Location, population
ORDER By PercentPopulationInfected DESC

--Showing Countries with the Highest Death count vs population.

SELECT Location, MAX(cast(total_deaths as int)) AS HighestDeathCount, population, MAX((total_deaths/population))*100 AS PercentPopulationDeathByCovid
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY Location, population
ORDER By HighestDeathCount DESC


--Showing Continent Death Count vs Population
SELECT Location, MAX(cast(total_deaths as int)) AS HighestDeathCount, MAX((total_deaths/population))*100 AS PercentPopulationDeathByCovid
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is null
GROUP BY Location
ORDER By HighestDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(Cast(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
WHERE continent is not null
--GROUP BY Date
ORDER By 1,2

--Looking at total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition By dea.location ORDER By dea.location, dea.date) AS TotalPeopleVaccinated
--, (TotalPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent is not null
	 ORDER BY 2,3

--USE CTE

WITH popvsvac (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition By dea.location ORDER By dea.location, dea.date) AS TotalPeopleVaccinated
--, (TotalPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent is not null
	 --ORDER BY 2,3
	 )

SELECT *, (TotalPeopleVaccinated/Population)*100
FROM popvsvac



--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition By dea.location ORDER By dea.location, dea.date) AS TotalPeopleVaccinated
--, (TotalPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent is not null
	 --ORDER BY 2,3
	 

SELECT *, (TotalPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating Views to store data for later visualisations

Create View PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition By dea.location ORDER By dea.location, dea.date) AS TotalPeopleVaccinated
--, (TotalPeopleVaccinated/population)*100

FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent is not null
	 --ORDER BY 2,3
	 


SELECT *
FROM PercentPopulationVaccinated
