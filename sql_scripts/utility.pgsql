-- Add new player
select * from players order by playerid desc;

--insert into players values (485,'Pradhan, Nabin','Nabin','Pradhan',NULL,'Nabin Pradhan');

-- Add new season
select * from seasons;
insert into seasons values (
    79, '2023/24', 'ASCA', 'S09', '2nd', 435, 0, 0, 'true', 'Section 9 Hopkins McGowran Cup'
)

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

update seasons set posn = 1 where seasonid = 79

select * from seasons where seasonid = 80

select * from players where playerid = 435
;
select * from players where surname = 'Wills'
;
select * from players where firstname = 'Jasraj'
;
select * from matches
;
-- drop view z_All_Player_Dates cascade

select * from players order by playerid desc

-- Create new player
-- insert into players values (
--     471, 'Sharma, Ram', 'Ram', 'Sharma', Null, 'Ram Sharma'
-- )



select * from batting where playerid = 112
where lower(how_out) = 'absent out'


select * from innings where  inningsid = 1583
select * from matches where matchid = 701

select * from wickets;

select distinct result from matches

select * from 
(select seasonid, round, count(*) as c from matches group by seasonid, round) a
where c>1

select * from players where name_fl = 'Geoff Brereton'



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




select * from matches where seasonid = 78 and round = '4';
select * from innings where matchid = 809;


select * from seasons;
select * from matches where seasonid = 77 and round = '13';
select * from innings where matchid = 804;
select * from batting where inningsid = 1795;

update batting set
    balls_faced = 66
    , batting_position = 5
where inningsid = 1795 and playerid = 457
;

update batting set
    balls_faced = 30
    , batting_position = 6
where inningsid = 1795 and playerid = 440
;

update batting set
batting_position = 2
where inningsid = 1862
and playerid = 265
;

select * from wickets where hat_trick = 1;

update wickets set
hat_trick = 1
where inningsid = 1861 and batting_position = 10
;





select * from yb_02_batting_summary
    where seasonid = 79

select * from players where firstname = 'Sidhaarth'

update players
set player_name = 'Thangaswamy, Sidhaarth'
, surname = 'Thangaswamy'
where playerid = 456


select * from batting where playerid = 265
order by how_out

select * from z_bat_ind_dismissal_types where name like 'Waldhuter, Josh%'
