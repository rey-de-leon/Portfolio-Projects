Select *
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
-- Where continent is NOT NULL
--Order By 3,4


Select location, date, total_cases, new_cases, total_deaths, new_deaths, population
From PortfolioProject..CovidDeaths
Order By 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

Select location, date, total_cases, total_deaths, 
	(Cast(total_deaths as float)/Cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is NOT NULL
Order By 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases,
	(Cast(total_cases as float)/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
--Where location like '%states%'
Order By 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,
	(Cast(MAX(total_cases) as float)/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
--Where location like '%states%'
Group BY location, population
Order By PercentPopulationInfected desc


-- Showing Highest Death Count per Population

Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is NOT NULL
Group BY location
Order By TotalDeathCount desc



-- Let's break things down by continent




-- Showing continents with highest death count per population


Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is NOT NULL
Group BY continent
Order By TotalDeathCount desc


-- GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
	SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
--	(Cast(total_deaths as float)/Cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%' 
Where continent is NOT NULL
-- Group by date
Order By 1,2




-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by (dea.location) Order by dea.location, dea.date)
	as RollingPeopleVaccinated
	-- RollingPeopleVaccinated/dea.population
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3 



-- USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations,
	RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by (dea.location) Order by dea.location, dea.date)
	as RollingPeopleVaccinated
	-- RollingPeopleVaccinated/dea.population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3 
)
Select *, RollingPeopleVaccinated/Population*100
From PopVsVac


-- USE TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by (dea.location) Order by dea.location, dea.date)
	as RollingPeopleVaccinated
	-- RollingPeopleVaccinated/dea.population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
-- Where dea.continent is not null
-- Order by 2,3 

Select *, RollingPeopleVaccinated/Population*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualisation

-- DROP View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by (dea.location) Order by dea.location, dea.date)
	as RollingPeopleVaccinated
	-- RollingPeopleVaccinated/dea.population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3 

Select *
From PercentPopulationVaccinated


