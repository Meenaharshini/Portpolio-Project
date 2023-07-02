CREATE DATABASE Portfolio

SELECT * FROM Portfolio..CovidDeaths$ order by 3,4
SELECT * FROM Portfolio..CovidVaccinations$ order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths$ order by 1,2

----Total cases vs total deaths -- Death percentage

SELECT Location, date, total_cases,total_deaths, ROUND((total_deaths/total_cases) * 100,2) AS DeathPercentage
FROM Portfolio..CovidDeaths$ 
WHERE location LIKE 'As%'
order by 1,2 

---Looking Total cases vs population

SELECT Location, date, total_cases,population, ROUND((total_cases/population) * 100,2) AS TotalPopulation
FROM Portfolio..CovidDeaths$ 
order by 1,2 

---Highest Death count per population


SELECT Location, MAX(CAST(total_deaths AS INT)) AS HighestDeathRate,
MAX(total_deaths/population) * 100 AS InfectionDeathPercentage FROM
Portfolio..CovidDeaths$ 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY  HighestDeathRate DESC

---Break the continent column

SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathRate,
MAX(total_deaths/population) * 100 AS InfectionDeathPercentage FROM
Portfolio..CovidDeaths$ 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  HighestDeathRate DESC

---Continent with highest death count

SELECT TOP 1 continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathRate
FROM Portfolio..CovidDeaths$ 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  HighestDeathRate DESC

---combine two tables

SELECT * FROM Portfolio..CovidDeaths$ cd
JOIN
Portfolio..CovidVaccinations$ cv ON cd.date = cv.date
AND cd.location = cv.location

---Total population vs total vaccination Using CTE

;WITH totalPopCTE (continent,location,date,population,new_vaccinations,Total_vaccinations)
AS
(
SELECT cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS Total_vaccinations
FROM Portfolio..CovidDeaths$ cd
JOIN
Portfolio..CovidVaccinations$ cv ON cd.date = cv.date
AND cd.location = cv.location
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, ROUND((Total_vaccinations/population) * 100 ,2) AS Total_Population
FROM totalPopCTE



--Using Temp Table

DROP TABLE IF EXISTS #PercentOfPopulationVaccination

CREATE TABLE #PercentOfPopulationVaccination(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccination NUMERIC,
Total_vaccination NUMERIC)

INSERT INTO #PercentOfPopulationVaccination
SELECT cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS Total_vaccination
FROM Portfolio..CovidDeaths$ cd
JOIN
Portfolio..CovidVaccinations$ cv ON cd.date = cv.date
AND cd.location = cv.location
--WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, ROUND((Total_vaccination/population) * 100 ,2) AS Total_Population
FROM #PercentOfPopulationVaccination

---CREATE view to store date to further data visualization

CREATE VIEW PercentOfPopulationVaccination
AS
SELECT cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS Total_vaccination
FROM Portfolio..CovidDeaths$ cd
JOIN
Portfolio..CovidVaccinations$ cv ON cd.date = cv.date
AND cd.location = cv.location
WHERE cd.continent IS NOT NULL

SELECT * FROM PercentOfPopulationVaccination


---Used query for tableau project---

---Global Numbers
---1--
SELECT   Sum(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, 
SUM(CAST(new_deaths AS INT)) / SUM(new_cases) AS DeathPercentage
FROM Portfolio..CovidDeaths$ 
WHERE continent IS NOT NULL
--GROUP BY date
order by 1,2 

---Deathrate of European union
---2---

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM Portfolio..CovidDeaths$
WHERE continent IS NOT NULL AND
location not in  ('World','European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC OFFSET 0 ROWS


---Country is with the highest infection rate population
---3---
SELECT Location,population, MAX(total_cases) AS HighestInfectionRate,
MAX(total_cases/population) * 100 AS InfectionPopulationPercentage FROM
Portfolio..CovidDeaths$ 
--WHERE location = 'India'
GROUP BY location,population
ORDER BY  location ASC,InfectionPopulationPercentage DESC

---4--
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths$
WHERE location = 'Vatican'
Group by Location, Population, date
order by PercentPopulationInfected desc
OFFSET 0 ROWS

