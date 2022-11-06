select *
from ProjectCensus.dbo.data1;
select *
from ProjectCensus.dbo.data2;

--count total count----
select count(*) from ProjectCensus..data1
select count(*) from ProjectCensus..data2

---data set for jharkhand and bihar
select * from ProjectCensus..data1 where state in ('jharkhand','bihar')

---population of india
select sum(population) as population from ProjectCensus..data2

--avg growth
select avg(growth)*100 as AVGGROWTH from ProjectCensus..data1;

---AVG growth of entire state
select state,avg(growth)*100 as state_growth from projectcensus..data1
group by state
;

--AVG_sex ratio
select state,ROUND(avg(SEX_RATIO ),0) as state_growth from projectcensus..data1
group by state 
ORDER BY state_growth desc;





---- Project 2------


---Joining both table---
select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population from ProjectCensus..data1 a inner join ProjectCensus..data2 b on a.district=b.district) c) d group by d.state;
 
 
-- --calculation------ male number and female number.
-- --female/male= sex_ratio----1
----females+males=population----2
--females=population-males----3
--(population-males) =(sex_ratio)*males
--population=males(sex_ratio+1)
--males= population/(sex_ratio+1)......males
--females=population-population/(sex_ratio+1)...females
---=population(1-1/(sex_ratio+1))
---=(population*(sex_ratio))/(sex_ratio+1)



---Total literacy rate---
select c.state,sum(literate_people) total_literate_people,sum(illiterate_people) total_illiterate_people from
(select d.district, d.state,round(d.literacy_ratio*d.population,0) literate_people,round((1-literacy_ratio)* d.population,0) illiterate_people from 
(select a.district,a.state,a.literacy/1000 literacy_ratio,b.population from ProjectCensus..data1 a inner join ProjectCensus..data2 b on a.district=b.district) d)c
group by c.state


---- --calculation-- literate and illiterate----
--Total Literate people/people=literacy_ratio.....1
--total literate people=literacy_ratio*population
--total illiterate people=(1-literacy_ratio)*population



---Population in previous census----
select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_population from (
Select e.state, sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state, round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from ProjectCensus..data1 a inner join ProjectCensus..data2 b on a.district=b.district ) d) e
group by e.state)m

---- --calculation-
--population
--previous_census+growth*previous_census=population
--previous_census=population/(1+growth)


---Population vs area----
select (g.total_area/g.previous_census_population) as previous_census_population_vs_area, (g.total_area/g.current_census_population) as current_census_population_vs_area from
(select q.*,r.total_area from(
select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_population from (
Select e.state, sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state, round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from ProjectCensus..data1 a inner join ProjectCensus..data2 b on a.district=b.district ) d) e
group by e.state)m)n ) q inner join (

select '1' as keyy,z.* from(
select sum(area_km2) total_area from projectcensus..data2)z)r on q.keyy=r.keyy)g


---Window function----
--output top 3 districts from each state with higest literacy rate 

select a.* from 
(select district,state, literacy, rank() over(partition by state order by literacy desc) rnk from ProjectCensus..data1) a
where a.rnk in (1,2,3) order by state
