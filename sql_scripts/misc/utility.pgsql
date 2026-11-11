-- Add new player
-- see what number we are up to:
select * from players where playerid < 900 order by playerid desc;

-- insert new row
--insert into players values (486,'Mayes, Philip','Philip','Mayes',NULL,'Philip Mayes');
--insert into players values (496,'Astley-Dixon, Javier','Javier','Astley-Dixon',NULL,'Javier Astley-Dixon');

select distinct result from matches;

select * from players order by playerid desc;

select * from batting_j;

select * from matches_j
where seasonid=24;

select * from bowling_i;

SELECT * FROM matches where seasonid in (85,86);

update matches set 
captain=269, 
wicketkeeper=387
where matchid=901;

-- Add new season
select * from seasons;
insert into seasons values (85, '2026/27', 'ASCA', 'S03', '1st', 269, 0, 0, 'true', 'Section 3 Cup');
insert into seasons values (86, '2026/27', 'ASCA', 'S08', '2nd', 265, 0, 0, 'true', 'Section 8 Claim this Cup');

select * from seasons_j;
insert into seasons_j values (11, '2023/24', 'SACA Junior Competitions', 'Under 10', 'Blue', 0, 0, 0, 'true', 'WSJCA - U10 - Blue');
insert into seasons_j values (12, '2023/24', 'SACA Junior Competitions', 'Under 10', 'Red', 0, 0, 0, 'true', 'WSJCA - U10 - Red');
insert into seasons_j values (13, '2023/24', 'SACA Junior Competitions', 'Under 12', 'Red', 0, 0, 0, 'true', 'WSJCA - U12 - Red');
insert into seasons_j values (14, '2023/24', 'SACA Junior Competitions', 'Under 12', 'Blue', 0, 0, 0, 'true', 'WSJCA - U12 - Blue');
insert into seasons_j values (15, '2024/25', 'SACA Junior Competitions', 'Under 10', 'Blue', 0, 0, 0, 'true', 'WSJCA - U10 - Blue');
insert into seasons_j values (16, '2024/25', 'SACA Junior Competitions', 'Under 12', 'Blue', 0, 0, 0, 'true', 'WSJCA - U12 - Blue');
insert into seasons_j values (17, '2024/25', 'SACA Junior Competitions', 'Under 12', 'Red' , 0, 0, 0, 'true', 'WSJCA - U12 - Red');
insert into seasons_j values (18, '2024/25', 'ATCA', 'Under 10', 'Green' , 0, 0, 0, 'true', 'U10 Green');
insert into seasons_j values (19, '2025/26', 'SACA Junior Competitions', 'Under 10', 'Blue' , 0, 0, 0, 'true', 'WSJCA U10 - Sunday - Blue');
insert into seasons_j values (20, '2025/26', 'SACA Junior Competitions', 'Under 12', '' , 0, 0, 0, 'true', 'WSJCA - U12 Division 2');
insert into seasons_j values (21, '2025/26', 'SACA Junior Competitions', 'Under 14', '' , 0, 0, 0, 'true', 'WSJCA - U14');
insert into seasons_j values (22, '2025/26', 'ATCA', 'Under 10', 'Red' , 0, 0, 0, 'true', 'U10 Division 2 - Red');
insert into seasons_j values (23, '2025/26', 'ATCA', 'Under 10', 'White' , 0, 0, 0, 'true', 'U10 Division 2 - White');
insert into seasons_j values (24, '2025/26', 'ATCA', 'Under 12', '' , 0, 0, 0, 'true', 'U12 Division 2');


insert into seasons_j values (25, '2026/27', 'ATCA', 'Under 10', 'Red' , 0, 0, 0, 'true', 'U10 Gold (Older Kids) - Red');
insert into seasons_j values (26, '2026/27', 'ATCA', 'Under 10', 'Royal' , 0, 0, 0, 'true', 'U10 Gold (Older Kids) - Royal');
insert into seasons_j values (27, '2026/27', 'ATCA', 'Under 10', 'White' , 0, 0, 0, 'true', 'U10 Green (Younger Kids) - White');
insert into seasons_j values (28, '2026/27', 'ATCA', 'Under 12', '' , 0, 0, 0, 'true', 'U12 Division 2');
insert into seasons_j values (29, '2026/27', 'SACA Junior Competitions', 'Under 10', 'Blue' , 0, 0, 0, 'true', 'Western Suburbs - U10 Sunday - Blue');
insert into seasons_j values (30, '2026/27', 'SACA Junior Competitions', 'Under 12', 'Blue' , 0, 0, 0, 'true', 'Western Suburbs - U12 Division 2 - Blue');
insert into seasons_j values (31, '2026/27', 'SACA Junior Competitions', 'Under 14', '' , 0, 0, 0, 'true', 'Western Suburbs - U14');




update seasons_j 
set playhq_season='U10 Gold (Older Kids) - Red'
where seasonid = 25
;

select * from seasons_i;
insert into seasons_i values (
    1, '2025/26', 'SACA', 'Senior', '1st', 457, 0, 0, 'true', 'SACA Inclusive Cricket League'
)

-- Update player name
update players set 
    player_name = 'Hodges, Henry'
    , name_fl = 'Henry Hodges'
    , firstname = 'Henry'
    , surname = 'Hodges'
where playerid = 604
;

-- insert into players values (-98, 'Fill In', '-','-',null,'Fill-in');

update players set 
    name_fl = 'Franco Raponi'
where playerid = 138
;

update players set 
    dob = '2008-12-27'
where playerid = 490
;

select * from players where surname = 'Bell';


update seasons set posn = 1 where seasonid = 79

select * from seasons where seasonid = 84

select * from players where playerid = 435
;
select * from players where surname = 'Hodge'
;
select * from players where firstname = 'Justin'
;
select * from matches where matchid = 901
;


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
select * from matches where seasonid = 84 and round = '4';
select * from innings where matchid = 875;
select * from batting where inningsid = 1943;
select * from bowling where inningsid = 1943;
select * from wickets where inningsid = 1943;

update wickets 
set playerid = 488
where inningsid=1943 and batting_position = 6;


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



create table bowling_i (
    inningsid int,
    playerid int,
    overs int,
    extra_balls int,
    maidens int,
    wides int,
    no_balls int,
    runs_off_bat int,
    _4s_against int,
    _6s_against int,
    highover int,
    _2nd_high_over int,
    _3rd_high_over int,
    wickets integer
);


/*
-- delete match
delete from batting where inningsid in 
    (select inningsid from innings where matchid = 886);
delete from bowling where inningsid in 
    (select inningsid from innings where matchid = 886);    
delete from fielding where inningsid in 
    (select inningsid from innings where matchid = 886);    
delete from wickets where inningsid in 
    (select inningsid from innings where matchid = 886);    
delete from matches where matchid = 886;
delete from innings where matchid = 886;
*/

-- Premierships
select s.year, s.grade, s.eleven, m.opponent, m.ground --, m.result
from seasons s
join matches m
on s.seasonid = m.seasonid
where m.round='GF'
and m.result like 'W%'
order by s.year desc
;


select * from matches_i

select * from innings_i

select * from bowling_i

select matches_i.opponent, bowling_i.inningsid, bowling_i.playerid, players.name_fl , overs,wickets,runs_off_bat
from bowling_i 
join players 
on bowling_i.playerid = players.playerid
join innings_i
on innings_i.inningsid= bowling_i.inningsid
join matches_i
on matches_i.matchid=innings_i.matchid
order by matches_i.round
;

update bowling_i 
set wickets=2 
where inningsid=1
and playerid=538
;
update bowling_i 
set wickets=1
where inningsid=1
and playerid=457
;
update bowling_i 
set wickets=2
where inningsid=1
and playerid=534
;
--
update bowling_i 
set wickets=2
where inningsid=7
and playerid=457
;
update bowling_i 
set wickets=1
where inningsid=7
and playerid=541
;
update bowling_i 
set wickets=1
where inningsid=7
and playerid=553
;
--
update bowling_i 
set wickets=2
where inningsid=12
and playerid=539
;
--
update bowling_i 
set wickets=3
where inningsid=14
and playerid=568
;
--

