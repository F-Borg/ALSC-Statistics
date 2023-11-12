-- drop table batting cascade


alter table seasons rename column "SeasonID" to seasonid;
alter table seasons rename column "Year" to year;
alter table seasons rename column "Association" to association;
alter table seasons rename column "Grade" to grade;
alter table seasons rename column "Eleven" to eleven;
alter table seasons rename column "Captain" to captain;
alter table seasons rename column "Vice Captain" to vice_captain;
alter table seasons rename column "Position" to posn;
alter table seasons rename column "NBW Status" to nbw_status;
alter table matches rename column "MatchID" to matchid;
alter table matches rename column "Opponent" to opponent;
alter table matches rename column "Ground" to ground;
alter table matches rename column "Round" to round;
alter table matches rename column "SeasonID" to seasonid;
alter table matches rename column "Result" to result;
alter table matches rename column "Date1" to date1;
alter table matches rename column "Date2" to date2;
alter table matches rename column "NoDays" to nodays;
alter table matches rename column "Captain" to captain;
alter table matches rename column "Wicketkeeper" to wicketkeeper;
alter table matches rename column "FV 1st" to fv_1st;
alter table matches rename column "FV 2nd" to fv_2nd;
alter table innings rename column "InningsID" to inningsid;
alter table innings rename column "Extras" to extras;
alter table innings rename column "MatchID" to matchid;
alter table innings rename column "InningsNO" to inningsno;
alter table innings rename column "Innings_Type" to innings_type;
alter table innings rename column "Bat_Overs" to bat_overs;
alter table innings rename column "Extra Balls" to extra_balls;
alter table batting rename column "InningsID" to inningsid;
alter table batting rename column "PlayerID" to playerid;
alter table batting rename column "Batting Position" to batting_position;
alter table batting rename column "How Out" to how_out;
alter table batting rename column "Bowler's Name" to bowler_name;
alter table batting rename column "Score" to score;
alter table batting rename column "4s" to _4s;
alter table batting rename column "6s" to _6s;
alter table batting rename column "Balls Faced" to balls_faced;
alter table batting rename column "FOW" to fow;
alter table batting rename column "Wicket" to wicket;
alter table batting rename column "Not Out Batsman" to not_out_batter;
alter table bowling rename column "InningsID" to inningsid;
alter table bowling rename column "PlayerID" to playerid;
alter table bowling rename column "Overs" to overs;
alter table bowling rename column "Extra Balls" to extra_balls;
alter table bowling rename column "Maidens" to maidens;
alter table bowling rename column "Wides" to wides;
alter table bowling rename column "No Balls" to no_balls;
alter table bowling rename column "Runs off Bat" to runs_off_bat;
alter table bowling rename column "4s against" to _4s_against;
alter table bowling rename column "6s against" to _6s_against;
alter table bowling rename column "HighOver" to highover;
alter table bowling rename column "2nd High Over" to _2nd_high_over;
alter table bowling rename column "3rd High Over" to _3rd_high_over;
alter table wickets rename column "InningsID" to inningsid;
alter table wickets rename column "batting position" to batting_position;
alter table wickets rename column "batsman dismissed" to batter_name;
alter table wickets rename column "how out" to how_out;
--alter table wickets rename column "assist" to assist;
alter table wickets rename column "playerID" to playerid;
alter table wickets rename column "Hat Trick" to hat_trick;
alter table players rename column "PlayerID" to playerid;
alter table players rename column "Name" to player_name;
alter table players rename column "FirstName" to firstname;
alter table players rename column "Surname" to surname;
alter table players rename column "DOB" to dob;


-- add player name
alter table players add column name_FL VARCHAR;
update players 
set name_fl = firstname||' '||surname
;

update players 
set name_fl = 'Joshua Waldhuter'
where playerid = 265
;

-- wrong date for match - update
update matches 
set date1 = '2021-11-20'
where matchid = 740
;
update matches 
set date1 = '2021-10-23'
where matchid = 737
;
update matches 
set date1 = '2022-01-15'
where matchid = 758
;

select * from matches where seasonid in (73,74,75)
--and round = '2'
order by seasonid, date1




select 
    inningsid
    , concat(b.num_wickets,'/',b.batting_tot) as tot
    , num_wickets
    , batting_tot
from (
SELECT inningsid
    , max("FOW") as batting_tot
    , sum(case when upper(how_out) not in ('DNB','NOT OUT','RETIRED','RETIRED HURT','FORCED RETIREMENT','0') then 1 else 0 end) as num_wickets
FROM batting 
group by InningsID
) b;


select 
    how_out
    , case when upper(how_out) not in ('DNB','NOT OUT','RETIRED','RETIRED HURT','FORCED RETIREMENT','0') then 1 else 0 end as temp1
from batting
where inningsid=1494

select distinct how_out from batting


select case when 'Not Out' = 'not out' then 1 else 0 end as test;





select * from wickets where inningsid > 1650;

select * from batting where inningsid > 1650;

select * from bowling where inningsid > 1650;

select * from seasons where seasonid > 50;

select * from matches where matchid > 720;

select * from innings where inningsid > 1650;


delete from wickets where inningsid in (1657,1656);
delete from batting where inningsid in (1657,1656);
delete from bowling where inningsid in (1657,1656);
delete from innings where inningsid in (1657,1656);
delete from matches where seasonid in (76);
