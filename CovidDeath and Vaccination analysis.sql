--Covid Death around the Globe

SELECT * 
FROM CovidProject..CovidDeath
Where continent is not null
order by 3,4

SELECT Location, date, total_cases, total_deaths, population
FROM CovidProject..CovidDeath
Where continent is not null
order by 1,2

--Total cases VS total Deaths
--reporting dying of Covid

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeath
Where continent is not null
and location like '%state%'
order by 1,2

--Total cases VS Population
--Number of confirmed cases of covid

SELECT Location, date, total_cases, Population, (total_cases/Population)*100 as CovidPercentage
FROM CovidProject..CovidDeath
Where location like '%state%'
and continent is not null
order by 1,2

--Countries with Highest Infection rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/Population)*100 as PercentagePopulationInfected
FROM CovidProject..CovidDeath
Where continent is not null
Group by Location, Population
order by PercentagePopulationInfected desc

--Countries with Highest Death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject..CovidDeath
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Analyzing through Continent
--Continent with highest death count per population

SELECT Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject..CovidDeath
Where continent is not null
Group by Continent
order by TotalDeathCount desc

--Global Analyzation

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
FROM CovidProject..CovidDeath
Where continent is not null
order by 1,2

--Covid Vaccination around the Globe
--Total Population VS Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.Location, dea.Date) AS RollingPeopleVaccinate
FROM CovidProject..CovidDeath dea
join CovidProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--PopvsVac over the continent  

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinate)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.Location, dea.Date) AS RollingPeopleVaccinate
FROM CovidProject..CovidDeath dea
join CovidProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinate/Population)*100
FROM PopvsVac

--Creating Temp Table

DROP Table if exists #PercentPopulationVAccinated
CREATE TABLE #PercentPopulationVAccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinate numeric
)
INSERT INTO #PercentPopulationVAccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.Location, dea.Date) AS RollingPeopleVaccinate
FROM CovidProject..CovidDeath dea
join CovidProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

SELECT *, (RollingPeopleVaccinate/Population)*100
FROM #PercentPopulationVAccinated


--Create view to store data for later visualization 

Create View PercentPopulationVAccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.Location, dea.Date) AS RollingPeopleVaccinate
FROM CovidProject..CovidDeath dea
join CovidProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

SELECT *
FROM PercentPopulationVAccinated