select * from CovidDeaths
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2


-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%state%'
and continent is not null
order by 1,2

--looking at total cases vs population
--shows what % of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%state%'
and continent is not null
order by 1,2


-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by location
order by TotalDeathCount desc


-- let's break things down by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount desc


select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is null
group by location
order by TotalDeathCount desc


--showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths--, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null
group by date
order by 1,2


--looking at total population vs vaccination

--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location)
--from PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, sum(vac.new_vaccinations) over (partition by dea.location) as RollingPeopleVaccinated
--from PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location 
		order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location 
		order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--use a temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location 
		order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location 
		order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated
