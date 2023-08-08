Select *
From CovidDeaths$
Where continent is not null
Order by 3,4


--Select *
--from CovidVaccinations$
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
Order by 1, 2



Select Location, Date, Total_cases, Total_deaths, (Total_Deaths/Total_Cases)*100 DeathPercentage
From CovidDeaths$
Where Location like '%states%'
Order by 1, 2


--Looking at total Cases vs Population
-- Shows Percentage of population got Covid


Select Location, Date, Total_cases, Population, (Total_cases/Population)*100 as PercentPopulationInfected
From CovidDeaths$
Where location like '%states%'
Order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population 


Select Location, Population, MAX(Total_Cases) as HighestInfectionRate, MAX((Total_Cases/Population))*100 PercentPopulationInfected
From CovidDeaths$
Where location like '%states%'
Group by Location, Population
Order by PercentPopulationInfected DESC


--Showing Countries with Highest Death count per Population



Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount DESC


--Showing the Contients with Highest Death count per Population


Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount DESC


-- Gobal Numbers


Select Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From CovidDeaths$
--Where Location like '%states%'
Where continent is not null
--Group by Date
Order by 1, 2


--looking at total Population vs Vaccinations

-- Use CTE

With PopvsVac (Contient, Locations, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, MAX(RollingPeopleVaccinated/Population)*100
From CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Use Temp Table

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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visulization 

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationVaccinated


--Showing the Contients Percentage of Population Death rate 


Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount, Max(Population) as TotalPoP, SUM(total_deaths/population)*100 as PercentPopDeath
From [PortfolioProject SQL].dbo.CovidDeaths$
--Where location like '%states%'
Where continent is  null
Group by location
Order by TotalDeathCount DESC




Select vac.continent, vac.population_density, vac.diabetes_prevalence, Max(dea.new_cases) as totalcases
from [PortfolioProject SQL].dbo.CovidVaccinations$ vac
join [PortfolioProject SQL].dbo.CovidDeaths$ dea 
	on vac.continent = dea.continent
group by vac.continent, vac.population_density, vac.diabetes_prevalence
