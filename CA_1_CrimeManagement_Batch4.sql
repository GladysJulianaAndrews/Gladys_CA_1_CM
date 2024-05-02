-- create database

drop database if exists CrimeManagement;
create database CrimeManagement;
use CrimeManagement;

-- create table crime

create table crime (crimeid int primary key, incidenttype varchar(255), incidentdate date, location varchar(255), description text, status varchar(20));

-- create table victim

create table victim (victimid int primary key, crimeid int, name varchar(255), contactinfo varchar(255), injuries varchar(255),
foreign key (crimeid) references crime(crimeid));

-- create table suspect

create table suspect (suspectid int primary key, crimeid int, name varchar(255), description text, criminalhistory text,
foreign key (crimeid) references crime(crimeid));
 
 -- insert values into crime
 
insert into crime (crimeid, incidenttype, incidentdate, location, description, status) values
(1, 'robbery', '2023-09-15', '123 main st, cityville', 'armed robbery at a convenience store', 'open'),
(2, 'homicide', '2023-09-20', '456 elm st, townsville', 'investigation into a murder case', 'under investigation'),
(3, 'theft', '2023-09-10', '789 oak st, villagetown', 'shoplifting incident at a mall', 'closed'),
(4, 'assault', '2023-10-25', '532 MG Road, Mumbai', 'Assault in a camp', 'open'),
(5, 'burglary', '2023-10-26', '67 Park Street, Kolkata', 'burglary at a residence', 'closed'),
(6, 'robbery', '2023-11-08', '89 MG Road, Pune', 'Robbery at a gas station', 'open'),
(7, 'homicide', '2023-12-22', '23 MG Road, Chennai', 'Investigation into a suspicious death', 'open'),
(8, 'theft', '2024-03-09', '901 Cherry St, Countryside', 'Pickpocketing incident at a park', 'open'),
(9, 'robbery', '2024-02-13', '8 Park Lane, Hyderabad', 'Armed robbery at a bank', 'closed'),
(10, 'assault', '2024-02-05', '12 Brigade Road, Bangalore', 'Assault outside a mall', 'open');

-- insert into table victim

insert into victim (victimid, crimeid, name, contactinfo, injuries) values
(1, 1, 'John Doe', 'johndoe@example.com', 'minor injuries'),
(2, 2, 'Jane Smith', 'janesmith@example.com', 'deceased'),
(3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'none'),
(4, 4, 'Luke Joe', 'lukejoe@example.com', 'fractured leg'),
(5, 5, 'Sarah Mike', 'sarahmike@example.com', 'none'),
(6, 6, 'David', 'david@example.com', 'minor injuries'),
(7, 7, 'Jack J', 'jackj@example.com', 'deceased'),
(8, 8, 'Jeslin', 'michael@example.com', 'none'),
(9, 9, 'Jessica', 'jessica@example.com', 'minor injuries'),
(10, 10, 'Miller', 'miller@example.com', 'fractured arm');

-- insert into table suspect

insert into suspect (suspectid, crimeid, name, description, criminalhistory) values
(1, 1, 'Robber 1', 'armed and masked robber', 'previous robbery convictions'),
(2, 2, 'Unknown', 'investigation ongoing', null),
(3, 3, 'Suspect 1', 'shoplifting suspect', 'prior shoplifting arrests'),
(4, 4, 'Assailant X', 'suspect wearing a mask', 'no prior criminal history'),
(5, 5, 'Burglar Y', 'identity unknown', null),
(6, 6, 'UnKnown', 'armed robber with a getaway driver', 'previous robbery convictions'),
(7, 7, 'Miller', 'suspected foul play', null),
(8, 8, 'Pickpocket Z', 'skilled pickpocket', 'multiple prior arrests for theft'),
(9, 9, 'Bank Robber A', 'masked robber with a weapon', 'previous bank robbery conviction'),
(10, 10, 'Aggressor B', 'suspected member of a gang', 'prior arrests for assault');

-- 1. Select all open incidents.

select * from crime where status = 'open';

-- 2. Find the total number of incidents.

select count(*) total_incident from crime;

-- 3. List all unique incident types.

select distinct incidenttype from crime;

-- 4. Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'.

select * from crime where incidentdate between '2023-09-01' and '2023-09-10';

-- 5. List persons involved in incidents in descending order of age.

alter table suspect add column dateofbirth date;

update suspect set dateofbirth = case 
when suspectid = 1 then '1978-05-20'
when suspectid = 2 then '1983-09-10'
when suspectid = 3 then '1994-02-28'
when suspectid = 4 then '1976-11-15'
when suspectid = 5 then '1989-01-03'
when suspectid = 6 then '1981-04-22'
when suspectid = 7 then '1998-10-08'
when suspectid = 8 then '1974-12-17'
when suspectid = 9 then '1987-06-09'
when suspectid = 10 then '1973-08-14'
else null
end;

select name, TIMESTAMPDIFF(YEAR, dateofbirth, CURDATE()) as age from (select name, dateofbirth from suspect) as all_people order by age desc;

-- 6. Find the average age of persons involved in incidents.

select avg(TIMESTAMPDIFF(YEAR, dateofbirth, CURDATE())) as average_age from (select dateofbirth from suspect) as all_people;
 
-- 7. List incident types and their counts, only for open cases.

select incidenttype type, count(incidenttype) count from crime where status = 'open' group by incidenttype;

-- 8. Find persons with names containing 'Doe'.

select name from (select name from victim union all select name from suspect) all_names where name like '%Doe%'; 

-- 9. Retrieve the names of persons involved in open cases and closed cases.

select distinct name from victim where crimeid in (select crimeid from crime where status = 'open')union
select distinct name from victim where crimeid in (select crimeid from crime where status = 'closed');

-- 10. List incident types where there are persons aged 30 or 35 involved

select distinct c.incidenttype from suspect s inner join crime c on s.crimeid = c.crimeid where TIMESTAMPDIFF(YEAR, s.dateofbirth, CURDATE()) in (30, 35);

-- 11. Find persons involved in incidents of the same type as 'Robbery'.

select distinct(s.name), c.incidenttype from suspect s inner join crime c on s.crimeid= c.crimeid where c.incidenttype = 'robbery'; 

-- 12. List incident types with more than one open case.

select incidenttype from crime where status = 'open' group by incidenttype having count(*) > 1;

-- 13. List all incidents with suspects whose names also appear as victims in other incidents

select distinct c.crimeid, c.incidenttype, c.incidentdate, v.name as victim_name, s.name as suspect_name
from crime c inner join victim v on c.crimeid = v.crimeid inner join suspect s on c.crimeid = s.crimeid where s.name in (select name from victim);

-- 14. Retrieve all incidents along with victim and suspect details.

select c.crimeid, c.incidenttype, c.incidentdate, v.name as victim_name, v.contactinfo as victim_contact, v.injuries,
s.name as suspect_name, s.description as suspect_description, s.criminalhistory from crime c left join victim v on c.crimeid = v.crimeid
left join suspect s on c.crimeid = s.crimeid;

-- 15. Find incidents where the suspect is older than any victim.

alter table victim add dateofbirth date;
 
update victim set dateofbirth = case 
when victimid = 1 then '1980-01-01'
when victimid = 2 then '1975-02-15'
when victimid = 3 then '1990-07-20'
when victimid = 4 then '1988-04-10'
when victimid = 5 then '1972-11-30'
when victimid = 6 then '1985-09-18'
when victimid = 7 then '1979-06-25'
when victimid = 8 then '1982-03-12'
when victimid = 9 then '1995-08-05'
when victimid = 10 then '1970-12-28'
else null
end;

select c.incidenttype from crime c inner join victim v on c.crimeid = v.crimeid inner join suspect s on c.crimeid = s.crimeid
where TIMESTAMPDIFF(YEAR, s.dateofbirth, CURDATE()) > any (select TIMESTAMPDIFF(YEAR, dateofbirth, CURDATE()) from victim where crimeid = c.crimeid);

-- 16. Find suspects involved in multiple incidents.

select suspectid, name from suspect group by suspectid, name having count(*) > 1;

-- 17. List incidents with no suspects involved.

select * from crime where crimeid not in (select distinct crimeid from suspect);

-- 18. List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 'Robbery'.

(select * from crime where incidenttype = 'Homicide' limit 1) union all (select * from crime where incidenttype = 'Robbery');

-- 19. Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 'No Suspect' if there are none.

select c.crimeid, c.incidenttype, case when s.name = 'unknown' then 'no suspect' else s.name end as suspect_name from crime c 
left join suspect s on c.crimeid = s.crimeid union select c.crimeid, c.incidenttype, 'no suspect' as suspect_name from crime c 
where c.crimeid not in (select distinct crimeid from suspect);

-- 20. List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault'

select distinct s.name from suspect s inner join crime c on s.crimeid = c.crimeid where c.incidenttype in ('robbery', 'assault');