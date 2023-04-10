Select * 
From PortifolioProject..CovidDeaths

where continent is not null

order by 3,4

--Select *
--From PortifolioProject..CovidVaccinations
--order by 3,4

-- Select the data that we are using

Select location, date,total_cases, new_cases, total_deaths,population

From PortifolioProject..CovidDeaths

order by 1,2

-- Looking at total cases vs deaths

-- Likely hood of dying by Covid in your country

Select location, date,total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage

From PortifolioProject..CovidDeaths

where location like'Zambia'

order by 1,2

-- Total cases vs population
-- Shows what percentage had Covid

Select location, date, population,total_cases, (total_cases/population)*100 as CovidPercentages

From PortifolioProject..CovidDeaths

where location like'Zambia'

order by 1,2

-- Looking at Countries with highest infection rate vs population


Select location,  population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageInfection

From PortifolioProject..CovidDeaths

Where continent is not null

Group by location, population

order by PercentageInfection desc

-- Showing Countries with the highest death count per population

Select location,  MAX(total_deaths) as TotalDeathCount

From PortifolioProject..CovidDeaths

Where continent is not null

Group by location

order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT

Select continent,  MAX(total_deaths) as TotalDeathCount

From PortifolioProject..CovidDeaths

Where continent is not null

Group by continent

order by TotalDeathCount desc

-- Showing the continents with the highest death count

Select continent,  MAX(total_deaths) as TotalDeathCount

From PortifolioProject..CovidDeaths

Where continent is not null

Group by continent

order by TotalDeathCount desc


-- Global Numbers

Select date, sum(new_cases) as TotalCases,sum(new_deaths) as TotalDeaths,
			--(select new_cases from PortifolioProject..CovidDeaths where new_cases !=0)/
			--(select new_deaths from PortifolioProject..CovidDeaths where new_deaths !=0)*100 as deathpercentage
			sum(new_deaths)/sum(new_cases)*100 as deathpercentage

From PortifolioProject..CovidDeaths

where --location like 'Zambia'
 continent is not null and (new_cases != 0 and new_deaths != 0)

Group by date

order by 1,2

-- Total Cases Total Deaths percentage

Select  sum(new_cases) as TotalCases,sum(new_deaths) as TotalDeaths,
			--(select new_cases from PortifolioProject..CovidDeaths where new_cases !=0)/
			--(select new_deaths from PortifolioProject..CovidDeaths where new_deaths !=0)*100 as deathpercentage
			sum(new_deaths)/sum(new_cases)*100 as deathpercentage

From PortifolioProject..CovidDeaths

where --location like 'Zambia'
 continent is not null and (new_cases != 0 and new_deaths != 0)

--Group by date

order by 1,2

--- Total population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	

From PortifolioProject..CovidDeaths dea
Join
 PortifolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Use CTE
With PopvsVac ( Continent, Location, Date, Population,new_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	

From PortifolioProject..CovidDeaths dea
Join
 PortifolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Where dea.continent is not null

)

Select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(Continent nvarchar (255), Location nvarchar (255),
Date Datetime, Population int,new_vaccinations int,RollingPeopleVaccinated float)

insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	

From PortifolioProject..CovidDeaths dea
Join
 PortifolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Where dea.continent is not null

Select *, (#PercentPopulationVaccinated.RollingPeopleVaccinated / Population)*100
from #PercentPopulationVaccinated

-- creating view for visualizations

create view PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	

From PortifolioProject..CovidDeaths dea
Join
 PortifolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


select * from PercentPopulationVaccinated