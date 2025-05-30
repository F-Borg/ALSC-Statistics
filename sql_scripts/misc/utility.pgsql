-- Add new player
-- see what number we are up to:
select * from players where playerid < 900 order by playerid desc;

-- insert new row
--insert into players values (486,'Mayes, Philip','Philip','Mayes',NULL,'Philip Mayes');
--insert into players values (487,'Zeeshan, Muhammad','Muhammad','Zeeshan',NULL,'Muhammad Zeeshan');
--insert into players values (488,'Fitzsimmons, Joshua','Joshua','Fitzsimmons',NULL,'Joshua Fitzsimmons');
--insert into players values (489,'Ladlow, Jamie','Jamie','Ladlow',NULL,'Jamie Ladlow');
--insert into players values (490,'Kupke, Tygh','Tygh','Kupke',NULL,'Tygh Kupke');
--insert into players values (491,'Leckie, Justin','Justin','Leckie',NULL,'Justin Leckie');
--insert into players values (492,'Rawat, Aditya','Aditya','Rawat',NULL,'Aditya Rawat');


-- Add new season
select * from seasons;
insert into seasons values (
    82, '2024/25', 'ASCA', 'S09', '2nd', 435, 0, 0, 'true', 'Section 9 Hopkins McGowran Cup'
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

update players set 
    dob = '2008-12-27'
where playerid = 490
;

select * from players where surname = 'Kupke';


update seasons set posn = 1 where seasonid = 79

select * from seasons where seasonid = 80

select * from players where playerid = 435
;
select * from players where surname = 'Jongeneel'
;
select * from players where firstname = 'Justin'
;
select * from matches
;
-- drop view z_All_Player_Dates cascade

select * from players order by playerid desc

select * from wickets where inningsid in
(select distinct inningsid from wickets where playerid = 48)
order by inningsid,batting_position;
-- insert into wickets values 
-- --(71,10,'bonus', 'Caught',null,48,0)
-- (71,11,'bonus', 'Bowled',null,48,0)


select * from batting where playerid = 112
where lower(how_out) = 'absent out'


select * from innings where  inningsid = 1583
select * from matches where matchid = 701


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


update players set name_fl = 'Christopher Mann' where playerid = 163;


select * from batting where playerid = 265
order by how_out

select * from z_bat_ind_dismissal_types where name like 'Waldhuter, Josh%'


select * from batting_11_high_score_sixes
where _6s > 8

select * from team_15_ind_youngest order by "Age on Final Game" desc