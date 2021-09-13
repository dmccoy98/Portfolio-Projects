select *
from
	[Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

----select *
----from
----	[Portfolio Project]..CovidVaccinations
----order by 3,4

-- Select data that I'm going to be using

select location, date, total_cases, new_cases, total_deaths, population
from
	[Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows how likely you are to die if you contract Covid in your country
select 
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from
	[Portfolio Project]..CovidDeaths
where location = 'United States'
and continent is not null
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows percentage of population that contracted covid

select 
	location, date, population, total_cases, (total_cases/population)*100 as case_percentage
from
	[Portfolio Project]..CovidDeaths
where location = 'United States'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select 
	location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as case_percentage
from
	[Portfolio Project]..CovidDeaths
--where location = 'United States'
where continent is not null
group by location, population
order by case_percentage desc

-- Showing Countries with Highest Death Count per Population

select 
	location, max(cast(total_deaths as int)) as total_death_count
from
	[Portfolio Project]..CovidDeaths
--where location = 'United States'
where continent is not null
group by location
order by total_death_count desc

-- Exploring by Continent
-- Showing Continents with Highest Death Count

select 
	continent, max(cast(total_deaths as int)) as total_death_count
from
	[Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc


-- Global Numbers

select 
	sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from
	[Portfolio Project]..CovidDeaths
where 
	continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select *, (rolling_people_vaccinated/population)*100
from PopvsVac



-- Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *, (rolling_people_vaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating View to Store Data for Later Visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationVaccinated
