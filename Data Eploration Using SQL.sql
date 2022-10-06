
-- SQL PROJECT TO QUERY COVID-19 DATA SET FROM KAGGLE


--Select all data from the Covid Death Data Set
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


--SPECIFIC DATA FROM THE COVID-19 DATA SET FOR QUERY

SELECT Location, Date, Total_cases, New_cases, Total_deaths, Population
FROM PortfolioProject..CovidDeaths
ORDER by 1,2

--Looking at Total cases vs Total Deaths In The Covid-19 Data Set
--Shows the Probability of Dying if you get Covid in Nigeria
SELECT Location, Date, Total_cases, Total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%nigeria%'
ORDER by 1,2


-- Comparing Total Cases vs the Population In Nigeria
-- Shows what Percentage Population got Covid in Nigeria

SELECT Location, Date, Population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location like '%nigeria%'
and continent is not null
ORDER by 1,2

-- Checking Out Countries with Highest Infection Rate as compared Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationinfected
FROM PortfolioProject..CovidDeaths
-- where location like '%nigeria%'
GROUP by Location, Population, continent
ORDER by PercentagePopulationinfected desc

-- Displaying Countries with the Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%nigeria%'
WHERE continent is not null
GROUP by Location
ORDER by TotalDeathCount desc


--LET'S DETERMINE THE GROUPING BY CONTINENT

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%nigeria%'
WHERE continent is null
GROUP by location
ORDER by TotalDeathCount desc


-- Displaying Continents with the Highest Death Count per Population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- where location like '%nigeria%'
WHERE continent is not null
GROUP by continent
ORDER by TotalDeathCount desc


-- DISPLAYING GLOBAL NUMBERS

SELECT Date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) /SUM(New_Cases)*100 as DeaathPercentage
FROM PortfolioProject..CovidDeaths
-- where location like '%nigeria%'
WHERE continent is not null
GROUP by date
ORDER by 1,2

-- OVERALL CASSES ACROSS THE WORLD

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) /SUM(New_Cases)*100 as DeaathPercentage
FROM PortfolioProject..CovidDeaths
-- where location like '%nigeria%'
WHERE continent is not null
-- Group by date
ORDER by 1,2


--DATA EXPLORATION FROM THE COVID VACCINATION TABLE

SELECT *
FROM PortfolioProject.. CovidVaccinations

--JOINING BOTH THE VACCINATION TABLE AND THE DEATH TABLE FROM THE COVID-19 DATA SET

SELECT *
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- CONSIDERING THE TOTAL POPULATION AND VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3

--- USE CTE TO CREATE A TABLE
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3
)
SELECT *, (RollingPeopleVaccinated/population) *100
FROM PopvsVac



--USING TEMP TO CREATE A TABLE 

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population) *100
FROM #PercentPopulationVaccinated


-- Creating View to Store Data for Later Visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3

SELECT *
FROM PercentPopulationVaccinated