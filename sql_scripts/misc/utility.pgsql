-- Add new player
-- see what number we are up to:
select * from players where playerid < 900 order by playerid desc;

-- insert new row
--insert into players values (486,'Mayes, Philip','Philip','Mayes',NULL,'Philip Mayes');
--insert into players values (496,'Astley-Dixon, Javier','Javier','Astley-Dixon',NULL,'Javier Astley-Dixon');

select distinct result from matches;

select * from players order by playerid desc;

select * from batting_j;

select * from matches_j;

select * from bowling_i

-- Add new season
select * from seasons;
insert into seasons values (
    84, '2025/26', 'ASCA', 'S09', '2nd', 439, 0, 0, 'true', 'Section 9 Hopkins McGowran Cup'
);

select * from seasons_j;
insert into seasons_j values (
    6, '2022/23', 'SACA Junior Competitions', 'Under 10', 'Blue', 0, 0, 0, 'true', 'U10 - Blue'
)

select * from seasons_i;
insert into seasons_i values (
    1, '2025/26', 'SACA', 'Senior', '1st', 457, 0, 0, 'true', 'SACA Inclusive Cricket League'
)

-- Update player name
update players set 
    player_name = 'PlayerX, Unknown'
    , name_fl = 'Unknown PlayerX'
    , firstname = 'Unknown'
    , surname = 'PlayerX'
where playerid = -99
;

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
select * from players where surname = 'Jongeneel'
;
select * from players where firstname = 'Justin'
;
select * from matches 
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

select * from wickets where inningsid in (1965,1966)