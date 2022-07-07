SELECT * FROM
Projects..CovidDeaths
ORDER BY 3,4

--SELECT * FROM
--Projects..CovidVaccination
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Projects..CovidDeaths
ORDER BY 1,2

-- Likelyhood of dying if you contract covid in CANADA

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Projects..CovidDeaths
WHERE location like 'Canada'
ORDER BY 1,2

-- Percentage of people that got infected with covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM Projects..CovidDeaths
WHERE location like 'Canada'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM Projects..CovidDeaths
GROUP BY location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count

SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount 
FROM Projects..CovidDeaths
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc

--Continent with Highest Death Count

SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount 
FROM Projects..CovidDeaths
WHERE continent is not null
GROUP BY continent
Order By TotalDeathCount Desc

--Overall Global Numbers

SELECT date, SUM(new_cases) as Totalcases, SUM(CAST(new_deaths as int)) as TotalDeaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage 
FROM Projects..CovidDeaths
WHERE continent is not null
GROUP BY date
Order By 1,2


--Looking at Total Population vs Total Vaccination 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) Over (Partition By dea.location Order by dea.location, dea.date) as RollingVacCount
From Projects..CovidDeaths Dea
Join Projects..CovidVaccination Vac
	on dea.location = Vac.location
	and dea.date = Vac.date
Where dea.continent is not null
Order by 2,3 

--Using CTE to get Percentage Population Vaccinated

With PopulationvsVac (continent, location, date, population, new_vaccinations, RollingVacCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) Over (Partition By dea.location Order by dea.location, dea.date) as RollingVacCount
From Projects..CovidDeaths Dea
Join Projects..CovidVaccination Vac
	on dea.location = Vac.location
	and dea.date = Vac.date
Where dea.continent is not null
)
Select *, (RollingVacCount/Population)*100 as PercentVaccination
From PopulationvsVac
Order by 2,3


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVacCount numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) Over (Partition By dea.location Order by dea.location, dea.date) as RollingVacCount
From Projects..CovidDeaths Dea
Join Projects..CovidVaccination Vac
	on dea.location = Vac.location
	and dea.date = Vac.date
--Where dea.continent is not null

Select *, (RollingVacCount/Population)*100 as PercentVaccination
From #PercentPopulationVaccinated
Order by 2,3


--Creating View for Visualization

Create view GlobalDeathCount as
SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount 
FROM Projects..CovidDeaths
WHERE continent is not null
GROUP BY continent
--Order By TotalDeathCount Desc

Select * from GlobalDeathCount
