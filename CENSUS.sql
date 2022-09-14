select * from project.dbo.literacy;

select * from project.dbo.pop_dist;

-- number of rows into our dataset

select count(*) from project..literacy
select count(*) from project..pop_dist

-- dataset for Andhra Pradhesh and Kerala
select * from project..data1 where state in ('Andhra Pradhesh' ,'Kerala')

-- population of India

select sum(population) as Population from project..pop_dist

-- avg growth 

select state,avg(growth)*100 avg_growth from project..literacy group by state;

-- avg sex ratio

select state,round(avg(sex_ratio),0) avg_sex_ratio from project..literacy group by state order by avg_sex_ratio desc;

-- avg literacy rate
 
select state,round(avg(literacy),0) avg_literacy_ratio from project..literacy 
group by state having round(avg(literacy),0)>90 order by avg_literacy_ratio desc ;

-- top 3 state showing highest growth ratio


select top 3 state,avg(growth)*100 avg_growth from project..literacy group by state order by avg_growth desc;


--bottom 3 state showing lowest sex ratio

select top 3 state,round(avg(sex_ratio),0) avg_sex_ratio from project..literacy group by state order by avg_sex_ratio asc;


-- top and bottom 3 states in literacy state

drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstate float

  )

insert into #topstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..literacy 
group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstate desc;

drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float

  )

insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..literacy 
group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

--union opertor

select * from (
select top 3 * from #topstates order by #topstates.topstate desc) a

union

select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;


-- states starting with letter a

select distinct state from project..literacy where lower(state) like 'a%' or lower(state) like 'b%'

select distinct state from project..literacy where lower(state) like 'a%' and lower(state) like '%m'


-- joining both table

--total males and females

 select d.state,sum(d.males) TOTAL_MALES,sum(d.females) as TOTAL_FEMALES 
 from
     (select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) as MALES, 
	 round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) FEMALES 
	 from
         (select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population 
		 from project..literacy a 
		 inner join project..pop_dist b on a.district=b.district ) c) d
group by d.state;

-- total literacy rate


select c.state,
       sum(literate_people) as total_literate_pop,
	   sum(illiterate_people) total_lliterate_pop 
from 
    (select d.district,d.state,
	round(d.literacy_ratio*d.population,0) as literate_people,
    round((1-d.literacy_ratio)* d.population,0) illiterate_people 
	from
        (select a.district,a.state,
		a.literacy/100 literacy_ratio,
		b.population from project..literacy a 
        inner join project..pop_dist b on a.district=b.district) d) c
group by c.state

-- population in previous census vs current census


select sum(m.previous_census_population) previous_census_population,
       sum(m.current_census_population) current_census_population 
	   from(
           select e.state,sum(e.previous_census_population) as previous_census_population,
		                  sum(e.current_census_population) as current_census_population 
						  from
                              (select d.district,d.state,
							  round(d.population/(1+d.growth),0) as previous_census_population,
							  d.population as current_census_population 
							  from
								  (select a.district,
								  a.state,a.growth growth,
								  b.population 
								  from project..literacy a inner join project..pop_dist b 
								  on a.district=b.district) d) e
group by e.state)m

