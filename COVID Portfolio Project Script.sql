---31 Jan 2020 - 30 April 2021 ---
--- View Covid Deaths Data-----
SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4


---View Covid Vaccination Data---
--SELECT *
--FROM PortfolioProjects..CovidVaccinations
--ORDER BY 3, 4


--- Select the Data that we are going to be using---
SELECT location, date,total_cases, new_cases,total_deaths, population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1, 2

---Looking at the Total Cases vs Total Deaths---
--- Shows the likelihood of dying if you contract covid in your country.---
---United States 1.75-2% DeathPercentage (chance of dying from Covid)
SELECT location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%state%' and continent is not null
ORDER BY 1, 2

---United Kingdom 2.8-3% DeathPercentage (chance of dying from Covid)
SELECT location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location like '%kingdom%' and continent is not null
ORDER BY 1, 2


---Looking at the Total Cases vs The Population-----
--- Shows what percentage of population got Covid
--- United States 9.77-10% PercentPopulationInfected
SELECT location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
WHERE location like '%state%'
ORDER BY 1, 2


---United Kingdom 6.5% PercentPopulationInfected
SELECT location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
WHERE location like '%kingdom%'
ORDER BY 1, 2


--- Looking Countries with Highest Infection Rate compared to Population
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--- LET'S BREAK THINGS DOWN BY CONTINENT
--- Showing continents with the highest death coun per population
SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

---This gives us the best overall view of Total Death Count by Continent (includes World, and International)
SELECT location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states'
WHERE continent is null
GROUP BY location
ORDER BY
--------------------------------------------

--- Showing Countries with the Highest Death Count per Population----
----Notes: Because Total Deaths was being read as VARCHAR data type it is converted into an integer using CAST as int
SELECT location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc


---- GLOBAL NUMBERS by date
SELECT date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/
	SUM(new_cases) *100 as DeathPercentage 
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%state%' 
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--- GLOBAL NUMBERS TOTAL (remove date and GROUP BY DATE for Total)
-- Total Cases: 150,574,977, Total Deaths: 318,0206, Death Percentage 2.11%
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/
	SUM(new_cases) *100 as DeathPercentage 
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%state%' 
WHERE continent is not null
---GROUP BY date
ORDER BY 1, 2



-----Covid Vaccinations Data----
SELECT *
FROM PortfolioProjects..CovidVaccinations

--- Join the tables together----
SELECT *
FROM PortfolioProjects..CovidDeaths dea ---alias--
JOIN PortfolioProjects..CovidVaccinations vac --alias--
 ON dea.location = vac.location
 and dea.date = vac.date

 ---Looking at Total Population vs Vaccinations
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 FROM PortfolioProjects..CovidDeaths dea ---alias--
JOIN PortfolioProjects..CovidVaccinations vac --alias--
 ON dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 2, 3

 --- Looking at Total Population vs. Vaccinations
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
 FROM PortfolioProjects..CovidDeaths dea ---alias--
JOIN PortfolioProjects..CovidVaccinations vac --alias--
 ON dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 2, 3

 --- CTE with the above Code with edits
 --------------------------------------------------------
 ---USE CTE
 WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER by dea.location, dea.date) 
	as RollingPeopleVaccinated
 FROM PortfolioProjects..CovidDeaths dea ---alias--
JOIN PortfolioProjects..CovidVaccinations vac --alias--
 ON dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null
 )
 SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM PopvsVac

 ----- END CTE--------





--- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated  ---how to delete the table--
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
 FROM PortfolioProjects..CovidDeaths dea ---alias--
JOIN PortfolioProjects..CovidVaccinations vac --alias--
 ON dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null

  SELECT *, (RollingPeopleVaccinated/Population) *100
 FROM  #PercentPopulationVaccinated



 -------------------------
 --Creating View to Store Data for Later Visualizations
 CREATE VIEW PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
 FROM PortfolioProjects..CovidDeaths dea ---alias--
JOIN PortfolioProjects..CovidVaccinations vac --alias--
 ON dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null


