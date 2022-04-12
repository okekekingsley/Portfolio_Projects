SELECT *
FROM..CovidDeaths
ORDER BY 3,4,5;

--SELECT *
--FROM..CovidVaccinations
--ORDER BY 3,4,5;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM..CovidDeaths
ORDER BY 1,2

--Looking at Total_Cases VS Total_Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid_Deaths
WHERE location LIKE '%states%'
and continent is not null
ORDER BY 1, 2


--Looking at Total Cases VS Population 
--Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage  
FROM..Covid_Deaths
WHERE location LIKE '%states%'
order 1,2

--Looking at countries with Highest Infected Rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population))*100 as Infected_Population_Percentage  
FROM..Covid_Deaths
--WHERE location LIKE '%states%'
GROUP BY Location, population
ORDER BY Infected_Population_Percentage DESC

--LET'S BREAK THINGS DOWN BY CONTINENT'S

--Showing continent with Highest Death Count per population 

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC


--GlOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST
(new_cases as int))/SUM(CAST(new_deaths as int))*100 AS DeathPercentage
FROM Covid_Deaths
--WHERE location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

--Looking at Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM..Covid_Deaths dea
JOIN Covid_Vaccinations vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
  ORDER BY 2, 3

  --USE CTE

  With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollinPeopleVaccinated)
  as
  (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM..Covid_Deaths dea
JOIN Covid_Vaccinations vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)



--Tem Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingsPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM..Covid_Deaths dea
JOIN Covid_Vaccinations vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
 --WHERE dea.continent IS NOT NULL
  --ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated 

--creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.Location ORDER BY dea.location,
dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM..Covid_Deaths dea
JOIN Covid_Vaccinations vac
  ON dea.location = vac.location 
  AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
  --ORDER BY 2, 3

  SELECT *
  FROM PercentPopulationVaccinated