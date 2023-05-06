Select * from PortfolioProject..CovidDeaths where continent is not null order by 3,4



Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths  where continent is not null
order by 1,2

--Total cases vs total deaths
-- shows what percentage of population died of covid

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%brazil%' and continent is not null
order by 1,2

--Looking at total cases vs population
-- shows what percentage of global population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as PopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%brazil%' and continent is not null
order by 1,2

-- Looking at the counties that have the highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by PopulationInfected desc

-- Showing the total deaths by continent

Select continent, max(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathsCount desc

-- Showing the global deaths


Select sum(cast(new_deaths as int)) as total_deaths, sum(new_cases) as total_cases, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2


-- Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated -- (RollingPeopleVaccinated/Population)*100
from  PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- use CTE

With PopvsVac(continent, location, date, population, new_caccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated -- (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100 from PopvsVac

-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVccinated

Create table #PercentPopulationVccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated -- (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVccinated


-- Creating view to store date for later visualization

Create view PercentPopulationVccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated -- (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVccinated