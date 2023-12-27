-- Add new player
select * from players order by playerid desc

--insert into players values (475,'Patel, Kashap','Kashap','Patel',NULL,'Kashap Patel');

-- Add new season
select * from seasons
-- insert into seasons values (
--     78, '2022/23', 'ASCA', 'S09', '3rd', 408, 0, 9, 'true', 'Section 9 Hopkins McGowran Cup'
-- )

-- Update player name
update players set 
    player_name = 'Panchal, Sunil'
    , name_fl = 'Sunil Panchal'
    , firstname = 'Sunil'
where playerid = 414
;

update players set 
    name_fl = 'Franco Raponi'
where playerid = 138
;



select * from players where playerid = 435
;
select * from players where surname = 'Patel'
;
select * from players where firstname = 'Divyesh'
;
select * from seasons
;
-- drop view z_All_Player_Dates cascade

select * from players order by playerid desc

-- Create new player
-- insert into players values (
--     471, 'Sharma, Ram', 'Ram', 'Sharma', Null, 'Ram Sharma'
-- )



select * from batting where playerid = 269 and score=0

select * from innings where  inningsid = 1478
select * from matches where matchid = 651

select distinct result from matches

select * from 
(select seasonid, round, count(*) as c from matches group by seasonid, round) a
where c>1

--delete from matches where matchid = 813
-- delete from innings where inningsid in (1813, 1814);
-- delete from batting where inningsid in (1813, 1814);
-- delete from bowling where inningsid in (1813, 1814);
-- delete from wickets where inningsid in (1813, 1814);


select * from innings where matchid in (812,813)



-- check where missing extras
select 
    matches.seasonid
    , matches.round
    , innings.inningsid
    , innings.innings_type
    , innings.inningsno
from innings 
inner join matches
on innings.matchid = matches.matchid
where matches.seasonid in (76,77,78)
and innings.extras = 0
;
-- exclude wides and no balls for bowling innings




select * from matches where seasonid = 78 and round = '4'
select * from innings where matchid = 809



