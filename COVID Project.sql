Select *
From PortfolioProject.dbo.CovidDeaths
where continent is not NULL
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
where continent is not NULL
order by 1,2

-- Looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like 'Poland'
order by 1,2

-- Total cases vs population
Select Location, date, total_cases, population, (cast(total_cases as float)/population)*100 as CasePercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not NULL
order by 1,2

-- Looking at countries with the highest infection rate compared to population.
Select Location, MAX(total_cases) as HighestInfectionCount, population, (Max(total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
where continent is not NULL
Group by Location, Population
order by 4 desc

-- Showing countries with highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount, population, Max((cast(total_deaths as int)/population)*100) as PercentPopulationDeaths
From PortfolioProject.dbo.CovidDeaths
where continent is not NULL
Group by Location, Population
order by 4 desc

-- Showing continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is not NULL
Group by continent
order by TotalDeathCount desc

-- Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(NULLIF(new_cases,0))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by date
order by 1,2


--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
and new_vaccinations is not NULL
order by 2,3


with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
)
Select *,(RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from PopVsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL

Select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL

--Total Numbers in the world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null 
order by 1,2

--Total numbers for each continent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International','High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc

--Countries with highest infection rate

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc