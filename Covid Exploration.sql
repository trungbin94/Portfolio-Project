--Have a look at all data first

select * 
from PortfolioProject..CovidDeaths$


/*
select * from PortfolioProject..CovidVaccinations$
where continent is not null
order by 3,4
*/

--Data I'm going to use later

Select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if contracting covid in Vietnam
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%vietnam%'
order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of population got Covid

Select location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%vietnam%'
order by 1,2


--Looking at Countries with Highest Infection rate compared to Population

Select location,max(total_cases) as HighestInfectionCount ,population, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
group by location, population
order by 4 desc

--Showing countries with Highest Death Count per Population

Select location,max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by 2 desc 

--Let's break things down by continent

Select location,max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths$
where location not like '%in%' 
and location not like'world'
and location not like'%union%'
and continent is null
group by location
order by 2 desc 




--GLOBAL NUMBERS-- 
Select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%vietnam%'
where continent is not null
order by 1,2


--Looking at total population vs vacciaion

select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 1,2,3

--Use CTE

With PopvsVac
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
--order by 1,2,3
)
select location, population, max(RollingPeopleVaccinated/population)*100 as percentpplgotvaccinated
from PopvsVac
group by population, location
order by 3 desc


--Temp table

Drop table if exists #Percentpopulationvaccinated
Create table #Percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #Percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 1,2,3


  select location, population, max(RollingPeopleVaccinated/population)*100 as percentpplgotvaccinated
from #Percentpopulationvaccinated
group by population, location
order by 3 desc


--Creating View to store data for later visualizations

Create View Percentpplvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 1,2,3

  select * from Percentpplvaccinated