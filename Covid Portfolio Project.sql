select *from
Portfolio..coviddeaths
order by 3,4

--select *from
--Portfolio..covidvaccinations
--order by 3,4

select location, date,total_cases, new_cases, total_deaths, [ population]
from Portfolio..coviddeaths
order by 1,2

-- Total cases vs Total deaths per country
-- Likelihood of death if covid contracted in India 
select location, date,total_cases,  total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
from Portfolio..coviddeaths
where location = 'India'
order by 1,2

-- How much of the population is infected 
select location, date,total_cases,  [ population], NULLIF(CONVERT(float, total_cases),0)/(CONVERT(float, [ population]))*100 as Infected 
from Portfolio..coviddeaths
where location = 'India'
order by 1,2

--Highest infected rate
select location, MAX(total_cases),  [ population], MAX(NULLIF(CONVERT(float, total_cases),0)/(CONVERT(float, [ population])))*100 as Infected
from Portfolio..coviddeaths
group by location, [ population]
order by Infected desc

-- display countries with the highest death counts 
select location, MAX(cast(total_deaths as int)) as TotalDeaths
from Portfolio..coviddeaths
where continent is not NULL
group by location
order by TotalDeaths desc

select location, MAX(cast(total_deaths as int)) as TotalDeaths
from Portfolio..coviddeaths
where continent is not NULL
group by location
order by TotalDeaths desc

select location from Portfolio..coviddeaths
where continent is NULL

--Maximum deaths per continent 
select location, MAX(cast(total_deaths as int)) as TotalDeaths
from Portfolio..coviddeaths
where continent is NULL
group by location
order by TotalDeaths desc


-- GLOBAL NUMBERS 
select date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage 
from Portfolio..coviddeaths
where continent  is not NULL
group by date 
order by 1,2

--DEATH PERCENTAGE ACROSS THE GLOBE 
select SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage 
from Portfolio..coviddeaths
order by 1,2


--Checking total vaccinated population
select de.continent, de.location, de.date, de.[ population], vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by de.location order by de.location, de.date)
as PeopleVaccinated
from Portfolio..coviddeaths de 
JOIN Portfolio..covidvaccinations vac 
ON de.location = vac.location AND 
de.date = vac.date
order by 2,3 

 --WITH CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations,
PeopleVaccinated)
as 
(
select de.continent, de.location, de.date, de.[ population], vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by de.location order by de.location, de.date)
as PeopleVaccinated
from Portfolio..coviddeaths de 
JOIN Portfolio..covidvaccinations vac 
ON de.location = vac.location AND 
de.date = vac.date
)

Select *,PeopleVaccinated/Population as PercentageVaccinated from PopvsVac

-- WITH TEMP TABLE
DROP table if exists #PopulationVaccinated
Create Table #PopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinated numeric)

Insert into #PopulationVaccinated
select de.continent, de.location, de.date, de.[ population], vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by de.location order by de.location, de.date)
as PeopleVaccinated
from Portfolio..coviddeaths de 
JOIN Portfolio..covidvaccinations vac 
ON de.location = vac.location AND 
de.date = vac.date

Select *,PeopleVaccinated/Population as PercentageVaccinated from #PopulationVaccinated

--VIEW
CREATE View PercentPopulationVaccinated as 
select de.continent, de.location, de.date, de.[ population], vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by de.location order by de.location, de.date)
as PeopleVaccinated
from Portfolio..coviddeaths de 
JOIN Portfolio..covidvaccinations vac 
ON de.location = vac.location AND 
de.date = vac.date

Select *from PercentPopulationVaccinated