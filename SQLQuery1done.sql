-- Viewing the CovidDeaths table

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Viewing the CovidVaccinations table

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select Data that we're going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths  in the U.S
-- Shows the likelihood of dying if you contract the virus in the U.S  

SELECT location, date, (total_cases), (total_deaths), (cast(total_deaths as int)/cast(total_cases as int))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of the population has got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS ContractedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_infection_count, MAX(total_cases/population)*100 AS ContractedPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Showing Countries with Highest Death Count by Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
-- WHERE country = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count by population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

-- GLOBAL NUMBERS
-- percentage of people's death per day 

select date,sum(cast(new_cases as int)) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(CAST(new_cases as int))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Now let's join our tables

SELECT *
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
  ON cd.location = cv.location
  AND cd.date = cv.date

-- Looking at Total Population vs Vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

-- Looking at Total Population vs Vaccination by country

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) 
sum_vaccination
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, sum_vaccination) as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) 
sum_vaccination
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (sum_vaccination/population)*100 percentage_vaccinated
FROM PopVsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
sum_vaccination numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
sum_vaccination
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
  ON cd.location = cv.location
  AND cd.date =cv.date
-- WHERE cd.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (sum_vaccination/population)*100 AS percentage_vaccinated
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) 
sum_vaccination
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
  ON cd.location = cv.location
  AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY 2,3

--to view the newly created table

select *
from PercentPopulationVaccinated