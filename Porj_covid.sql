USE Proj_Covid;
select* from DBO.CovidDeaths$

-- consulta Total de casos vs Total de muerte por lacacion
	-- porcentaje de muerte por total de casos 
USE Proj_Covid;
select location, DATE,total_cases, total_deaths, ((total_deaths/total_cases)*100) as deadthsPercentage
from DBO.CovidDeaths$
where location like '%salvador%'
ORDER BY 1,2
	-- porcentaje de casos por poblacion 
USE Proj_Covid;
select location, DATE,total_cases, total_deaths, population, (total_cases/population)*100 as casesPercentage
from DBO.CovidDeaths$
where location like '%salvador%'
ORDER BY 1,2

-- tasa de infecion por poblacion
select location,population, max(total_cases), max((total_cases/population))*100 as tasa_infencion
from DBO.CovidDeaths$
group by location, population
ORDER BY tasa_infencion desc


-- paies con mas muester
select location, max(cast(total_deaths as int )) as Total_muerte
from DBO.CovidDeaths$
where continent is not null
group by location
order by Total_muerte desc

-- Muerte por cotinente 
select continent,max(cast(total_deaths as int )) as Total_muerte, (max(total_cases)/ max(population))*100 as poblacion_infectada
from DBO.CovidDeaths$
where continent is not null
group by continent
order by Total_muerte desc

-- numeros globales
use Proj_Covid;
Select date,sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths, 
sum(cast (new_deaths as int))/sum(new_cases)*100 as deathsPercentage
from DBO.CovidDeaths$
where continent is not null
group by date
order by 1,2


-- JOIN muertes con vacunacion
SELECT dea.continent, dea.location, dea.date, dea.population, vacu.new_vaccinations, 
sum(CONVERT(int,vacu.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date ) as Poblacion_Vacu
	-- se utiliza en funciones de agregado (como SUM, COUNT, AVG, etc.) para dividir los resultados en grupos particulares, 
	-- específicamente,por los valores especificados en el argumento de la cláusula PARTITION BY.
FROM Proj_Covid..CovidDeaths$ dea
join Proj_Covid..CovidVaccinations$ vacu
	on dea.location = vacu.location
	and dea.date = vacu.date
where dea.continent is not null
order by 2,3

-- use CTE

with PopvsVacu (continent, location, date, population, new_vaccinations, Poblacion_Vacu)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacu.new_vaccinations, 
sum(CONVERT(int,vacu.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date ) as Poblacion_Vacu
	-- se utiliza en funciones de agregado (como SUM, COUNT, AVG, etc.) para dividir los resultados en grupos particulares, 
	-- específicamente,por los valores especificados en el argumento de la cláusula PARTITION BY.
FROM Proj_Covid..CovidDeaths$ dea
join Proj_Covid..CovidVaccinations$ vacu
	on dea.location = vacu.location
	and dea.date = vacu.date
where dea.continent is not null
-- order by 2,3
)
select *, (Poblacion_Vacu/population)*100
from PopvsVacu

-- CREAR UNA VISTA CON % POBLACION VACUNADA
USE Proj_Covid
go 
Create view PoblacionVacunada_porcentage as 
SELECT dea.continent, dea.location, dea.date, dea.population, vacu.new_vaccinations, 
sum(CONVERT(int,vacu.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date ) as Poblacion_Vacu
	-- se utiliza en funciones de agregado (como SUM, COUNT, AVG, etc.) para dividir los resultados en grupos particulares, 
	-- específicamente,por los valores especificados en el argumento de la cláusula PARTITION BY.
FROM Proj_Covid..CovidDeaths$ dea
join Proj_Covid..CovidVaccinations$ vacu
	on dea.location = vacu.location
	and dea.date = vacu.date
where dea.continent is not null

