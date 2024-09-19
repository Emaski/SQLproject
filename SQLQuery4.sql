SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4 

SELECT * 
FROM PortfolioProject..CovidVaccinations
where continent is not null
order by 3, 4 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


-- shows likelyhood of dying if youu contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/ nullif(total_cases, 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
AND continent is not null
order by 1, 2

--Sows what percentage of population got covid
select location, date, population, total_cases, (nullif(total_cases, 0)/ population)*100 as percentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1, 2

--looking at countries with the highest infection rates compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((nullif(total_cases, 0)/ population))*100 as percentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group By location, population
order by percentPopulationInfected desc

--Showing the countries with the highest death count per population
select continent, MAX( cast(total_deaths as int) ) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group By continent
order by TotalDeathCount desc


--GLOBAL NUMBERS BY DATE
select date, SUM(new_cases)as newCases, SUM(cast(new_deaths as int)) as newDeaths, SUM(cast(new_deaths as int))/SUM(nullif(total_cases, 0))*100 as DeathPercentage --, total_deaths, (total_deaths/ nullif(total_cases, 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY date
order by 1, 2

--GLOBAL NUMBERS
select SUM(new_cases)as newCases, SUM(cast(new_deaths as int)) as newDeaths,
SUM(cast(new_deaths as int))/SUM(nullif(total_cases, 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(ISNULL(vac.new_vaccinations, 0) as BIGINT)) 
OVER (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac 
join PortfolioProject..CovidDeaths dea
     on dea.location = vac.location 
	     and dea.date = vac.date
where dea.continent is not null
order by 2,3

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(ISNULL(vac.new_vaccinations, 0) as BIGINT)) 
OVER (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac 
join PortfolioProject..CovidDeaths dea
     on dea.location = vac.location 
	     and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as PercentageOfVaccinated
from #PercentPopulationVaccinated

--creating view to store later for visualizations

CREATE VIEW percentPopulationsvaccinated AS 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(ISNULL(vac.new_vaccinations, 0) as BIGINT)) 
OVER (Partition by dea.Location order by dea.Location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac 
join PortfolioProject..CovidDeaths dea
     on dea.location = vac.location 
	     and dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--order by 2,3
