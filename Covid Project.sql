select *
from CovidDeaths
where continent is not null 
order by 3,4

--select *
--from Vaccinations
--order by 3,4

--Select the data we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from CovidDeaths
where location like '%canada%'
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population has gotten covdi

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%canada%'
order by 1,2

-- Looking at Countries with the Highest Infection Rate compared to Population

Select location, population, MAX(total_cases)as HighInfectionCount, MAX((total_cases)/population)*100 as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- Showing the Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null 
group by location
order by TotalDeathCount desc

-- Break things down by Contient 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

-- Showing the continents with the highest death counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

-- Global Numbers 

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null 
Group by date
order by 1,2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null 
order by 1,2

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join Vaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Use CTE 

With PopVsVac (Continent, Location, Date, Population, new_vaccinations,RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join Vaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null )

Select *, (RollingPeopleVaccinated/Population) *100
from PopVsVac 

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric 
)
insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join Vaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population) *100
from #PercentPopulationVaccinated 


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join Vaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated