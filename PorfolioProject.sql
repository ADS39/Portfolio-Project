
Select * from PortfolioProject.dbo.CovidDeaths order by 3,4
--Select * from PortfolioProject.dbo.CovidVaccination order by 3,4


select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject.dbo.CovidDeaths order by 1,2

--Looking for total cases vs total deaths
--shows the likelyhood if you contract covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject.dbo.CovidDeaths where location like '%states%' order by 1,2

--total cases vs population
Select location,date,total_cases,population,(total_cases/population)*100 as percent_population_inflation 
from PortfolioProject.dbo.CovidDeaths 
--where location like '%states%' 
order by 1,2

--3
--loking at countries with highest infection rate compared to population
select location,population,max(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as PercentagePopulationInfected 
from PortfolioProject.dbo.CovidDeaths
group by location,population
order by PercentagePopulationInfected desc

--4
--loking at countries with highest infection rate compared to population
select location,population,date,max(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as PercentagePopulationInfected 
from PortfolioProject.dbo.CovidDeaths
group by location,population,date
order by PercentagePopulationInfected desc

--showing counties with highest desath count per population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
group by location
order by TotalDeathCount desc

--2
select location,sum(cast(new_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is null and location not in ('World','Europe Union','International')
group by location
order by TotalDeathCount desc

--Let's break things down by continent
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is null 
group by location
order by TotalDeathCount desc

--showing continents with the highest death count per population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

--global numbers
select date,sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as deathpercentage from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

--1
select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as deathpercentage from PortfolioProject.dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2


--Vaccinated database and death database join
select * from PortfolioProject.dbo.CovidDeaths as death join PortfolioProject.dbo.CovidVaccination as vaccine
on death.location=vaccine.location and death.date=vaccine.date

--Looking for total population vs vaccination
with popvsvac(Continent,location,date,population,new_vaccinations,RollingPeopleVaccinations)
as(
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(convert(int,vaccine.new_vaccinations)) over (partition by death.location order by death.location,death.date)
as Rollingvaccinated --, (Rollingvaccinated/population)*100  
from PortfolioProject.dbo.CovidDeaths as death
join PortfolioProject.dbo.CovidVaccination as vaccine on death.location=vaccine.location 
and death.date=vaccine.date where death.continent is not null
--order by 2,3 
)
select * ,(RollingPeopleVaccinations/population)*100 from popvsvac


--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
 continent nvarchar(255),
 loaction nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric
 )
 insert into #percentpopulationvaccinated
 select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(convert(int,vaccine.new_vaccinations)) over (partition by death.location order by death.location,death.date)
as Rollingvaccinated --, (Rollingvaccinated/population)*100  
from PortfolioProject.dbo.CovidDeaths as death
join PortfolioProject.dbo.CovidVaccination as vaccine on death.location=vaccine.location 
and death.date=vaccine.date where death.continent is not null

select *,(RollingPeopleVaccinated/population)*100
from #percentpopulationvaccinated

--creating view fro storer dat for later visulisation
Create View percentpopulationvaccinate as
 select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations,
sum(convert(int,vaccine.new_vaccinations)) over (partition by death.location order by death.location,death.date)
as Rollingvaccinated --, (Rollingvaccinated/population)*100  
from PortfolioProject.dbo.CovidDeaths as death
join PortfolioProject.dbo.CovidVaccination as vaccine on death.location=vaccine.location 
and death.date=vaccine.date where death.continent is not null

select * from percentpopulationvaccinate

