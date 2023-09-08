
Select * from CovidDeathsCSV
where continent is not null
order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeathsCSV
where continent is not null
order by 1,2

--looking at the total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeathsCSV
Where location like '%states'
where continent is not null
order by 1,2

--Looking at Total cases vs Population
--shows what percentage of population got Covid

Select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from CovidDeathsCSV
Where location like '%states'
and continent is not null
order by 1,2 

--looking at the countries with highest infection rate compared to population

Select location, population, MAX (total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeathsCSV
--Where location like '%states'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc 


--showing the countries with Highest Death Count per Population

Select location, MAX (total_deaths) as TotalDeathCount
from CovidDeathsCSV
--Where location like '%states'
where continent is not null
Group by location
order by TotalDeathCount desc 

--LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

Select continent, MAX (total_deaths) as TotalDeathCount
from CovidDeathsCSV
--Where location like '%states'
where continent is not null
Group by continent
order by TotalDeathCount desc 

--GLOBAL NUMBERS (CONFUSION)

Select SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from CovidDeathsCSV
--Where location like '%states'
where continent is not null
--Group By date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeathsCSV dea
join CovidVaccinationsCSV vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeathsCSV dea
join CovidVaccinationsCSV vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeathsCSV dea
join CovidVaccinationsCSV vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeathsCSV dea
join CovidVaccinationsCSV vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated
