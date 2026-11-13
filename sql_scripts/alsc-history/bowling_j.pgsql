
-- DROP VIEW bowling_j_01_summary_ind;
CREATE OR REPLACE VIEW bowling_j_01_summary_ind AS
SELECT 
    z_j_bcsa.Name
    , z_j_bcsa.Mat
    , z_j_bcsa.O
    , z_j_bcsa.Balls
    , z_j_bcsa.Mdns
    , z_j_bcsa."Total Runs"
    , z_j_bcsa."Total Wickets"
    , z_j_bcsa.Average
    , z_j_bcsa."Strike Rate", z_j_bcsa.RPO, z_j_bcsa.ABD, z_j_bcsa._4s, z_j_bcsa._6s, z_j_bcsa.Figures, z_j_bcsa."5WI", z_j_bcsa."Expensive Over", z_j_bcsa.Catches, 
z_j_bcsa.Stumpings, z_j_bcsa.PlayerID
FROM z_j_bcsa
WHERE z_j_bcsa.Balls>0
--GROUP BY z_j_bcsa.Name, z_j_bcsa.Mat, z_j_bcsa.O, z_j_bcsa.Balls, z_j_bcsa.Mdns, z_j_bcsa."Total Runs", z_j_bcsa."Total Wickets", z_j_bcsa.Average, z_j_bcsa."Strike Rate", z_j_bcsa.RPO, z_j_bcsa.ABD, z_j_bcsa._4s, z_j_bcsa._6s, z_j_bcsa.Figures, z_j_bcsa."5WI", z_j_bcsa."Expensive Over", z_j_bcsa.Catches, z_j_bcsa.Stumpings, z_j_bcsa.PlayerID
ORDER BY Name
;


CREATE OR REPLACE VIEW bowling_j_02_p1_wickets AS
select 
    "Total Wickets"
    , Name
    , mat
    , Average
from z_j_bocsa
where "Total Wickets" > 0
order by "Total Wickets" desc
;


CREATE OR REPLACE VIEW bowling_j_03_p1_ave AS
select 
    Average
    , Name
    , mat
    , "Total Wickets"
from z_j_bocsa
where "Total Wickets" > 14
order by Average
;


CREATE OR REPLACE VIEW bowling_j_04_p1_sr AS
select 
    "Strike Rate"
    , Name
    , mat
    , "Total Wickets"
from z_j_bocsa
where "Total Wickets" > 14
order by "Strike Rate"
;


CREATE OR REPLACE VIEW bowling_j_05_p2_career_econ_low AS
select 
    RPO
    , Name
    , O
from z_j_bocsa
where balls > 119
order by RPO
;


CREATE OR REPLACE VIEW bowling_j_06_p2_career_econ_high AS
select 
    RPO
    , Name
    , O
from z_j_bocsa
where balls > 119
order by RPO DESC
;


CREATE OR REPLACE VIEW bowling_j_07_p2_5WI AS
SELECT 
    "5WI"
    , Name
    , Mat
from z_j_Bowling_Career_5WI
where balls > 119
order by "5WI" DESC
;


CREATE OR REPLACE VIEW bowling_j_08_p2_season_wickets AS
SELECT 
    sum(z_j_Bowling_Figures_All.w) AS Wickets_j
    , players.player_name
    , sum(z_j_Bowling_Figures_All.runs)/sum(z_j_Bowling_Figures_All.w) as Av
    , count(distinct Matches_j.MatchID) as Mat
    , Seasons_j.Year, Seasons_j.Grade, Seasons_j.Eleven, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID=Matches_j.SeasonID
INNER JOIN Innings_j
ON Matches_j.MatchID=Innings_j.MatchID
INNER JOIN z_j_Bowling_Figures_All
ON z_j_Bowling_Figures_All.inningsid = Innings_j.inningsid
INNER JOIN players
ON players.playerid = z_j_Bowling_Figures_All.playerid
group by player_name, z_j_Bowling_Figures_All.playerid, Seasons_j.Year, Seasons_j.Grade, Seasons_j.Eleven, Seasons_j.Association
having sum(z_j_Bowling_Figures_All.w) > 0
order by Wickets_j DESC, av
;


CREATE OR REPLACE VIEW bowling_j_09_p3_best_figs AS
SELECT players.player_name AS Player
    , z_j_Bowling_Figures_All.Ov AS Overs
    , z_j_Bowling_Figures_All.Figures
    , Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID=Matches_j.SeasonID
INNER JOIN Innings_j
ON Matches_j.MatchID=Innings_j.MatchID
INNER JOIN z_j_Bowling_Figures_All
ON z_j_Bowling_Figures_All.inningsid = Innings_j.inningsid
INNER JOIN players
ON players.playerid = z_j_Bowling_Figures_All.playerid
ORDER BY z_j_Bowling_Figures_All.w DESC , z_j_Bowling_Figures_All.runs
;


CREATE OR REPLACE VIEW bowling_j_10_p3_hat_trick AS
SELECT Players.player_Name, Wickets_j.Hat_Trick, Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Association, Seasons_j.Grade
FROM Seasons_j INNER JOIN (Matches_j INNER JOIN (Players INNER JOIN ((Wickets_j INNER JOIN (z_j_Bowling_Figures_All INNER JOIN Bowling_j ON (z_j_Bowling_Figures_All.InningsID = Bowling_j.InningsID) AND (z_j_Bowling_Figures_All.PlayerID = Bowling_j.PlayerID)) ON Wickets_j.InningsID = z_j_Bowling_Figures_All.InningsID) INNER JOIN Innings_j ON (Innings_j.InningsID = Wickets_j.InningsID) AND (Innings_j.InningsID = Bowling_j.InningsID) AND (z_j_Bowling_Figures_All.InningsID 
= Innings_j.InningsID)) ON (Players.PlayerID = Bowling_j.PlayerID) AND (Players.PlayerID = Wickets_j.playerID)) ON Matches_j.MatchID = Innings_j.MatchID) ON Seasons_j.SeasonID = Matches_j.SeasonID
WHERE (((Wickets_j.Hat_Trick)=1))
ORDER BY Innings_j.inningsid DESC;

--drop view bowling_j_11_p3_10WM;
CREATE OR REPLACE VIEW bowling_j_11_p3_10WM AS
SELECT players.player_Name AS "Name"
    , aa.wickets_j as "Wickets", aa.Figures as "Figures"
    , Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID=Matches_j.SeasonID
INNER JOIN (
    
    select 
        playerid, MatchID, sum(w) as wickets_j, max(figs1) ||' & '|| max(figs2) as figures, max(runs1)+max(runs2) as runs
    from (
        select 
            playerid, MatchID, w
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 1 then figures end as figs1
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 2 then figures end as figs2
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 1 then runs end as runs1
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 2 then runs end as runs2
        from z_j_Bowling_Figures_All
    ) a
    group by playerid, MatchID
    having sum(w) >= 10
) aa
ON aa.MatchID = Matches_j.MatchID
INNER JOIN players
ON players.playerid = aa.playerid
--GROUP BY players.player_Name, Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
ORDER BY aa.wickets_j DESC , aa.runs;


--drop view bowling_j_12_p3_match_econ;
CREATE OR REPLACE VIEW bowling_j_12_p3_match_econ AS
SELECT players.player_name AS Player
    , z_j_Bowling_Figures_All.Ov AS Overs
    , z_j_Bowling_Figures_All.Figures
    , Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID=Matches_j.SeasonID
INNER JOIN Innings_j
ON Matches_j.MatchID=Innings_j.MatchID
INNER JOIN z_j_Bowling_Figures_All
ON z_j_Bowling_Figures_All.inningsid = Innings_j.inningsid
INNER JOIN players
ON players.playerid = z_j_Bowling_Figures_All.playerid
where (6*z_j_Bowling_Figures_All.Ov1 + z_j_Bowling_Figures_All.Extra_Balls) > 59
ORDER BY (6.0*z_j_Bowling_Figures_All.runs/(6*z_j_Bowling_Figures_All.Ov1 + z_j_Bowling_Figures_All.Extra_Balls))
;

CREATE OR REPLACE VIEW bowling_j_13_p4_match_runs AS
SELECT players.player_name AS Player
    , z_j_Bowling_Figures_All.Ov AS Overs
    , z_j_Bowling_Figures_All.Figures
    , Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID=Matches_j.SeasonID
INNER JOIN Innings_j
ON Matches_j.MatchID=Innings_j.MatchID
INNER JOIN z_j_Bowling_Figures_All
ON z_j_Bowling_Figures_All.inningsid = Innings_j.inningsid
INNER JOIN players
ON players.playerid = z_j_Bowling_Figures_All.playerid
ORDER BY z_j_Bowling_Figures_All.runs DESC, z_j_Bowling_Figures_All.w DESC
;

CREATE OR REPLACE VIEW bowling_j_14_p4_match_econ_high AS
SELECT players.player_name AS Player
    , z_j_Bowling_Figures_All.Ov AS Overs
    , z_j_Bowling_Figures_All.Figures
    , (6.0*z_j_Bowling_Figures_All.runs/(6*z_j_Bowling_Figures_All.Ov1 + z_j_Bowling_Figures_All.Extra_Balls)) AS Econ
    , Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID=Matches_j.SeasonID
INNER JOIN Innings_j
ON Matches_j.MatchID=Innings_j.MatchID
INNER JOIN z_j_Bowling_Figures_All
ON z_j_Bowling_Figures_All.inningsid = Innings_j.inningsid
INNER JOIN players
ON players.playerid = z_j_Bowling_Figures_All.playerid
where (6*z_j_Bowling_Figures_All.Ov1 + z_j_Bowling_Figures_All.Extra_Balls) > 29
ORDER BY (6.0*z_j_Bowling_Figures_All.runs/(6*z_j_Bowling_Figures_All.Ov1 + z_j_Bowling_Figures_All.Extra_Balls)) DESC
;

CREATE OR REPLACE VIEW bowling_j_15_p4_expensive_over AS
SELECT players.player_name AS Name, Bowling_j.HighOver, Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j 
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Bowling_j
ON Innings_j.InningsID = Bowling_j.InningsID
INNER JOIN Players 
ON Players.PlayerID = Bowling_j.PlayerID 
where Bowling_j.HighOver>9
ORDER BY Bowling_j.HighOver DESC;


CREATE OR REPLACE VIEW bowling_j_16_p4_extras_high AS
SELECT players.player_name AS Name
    , Sum(bowling_j.wides)+Sum(bowling_j.no_balls) AS Extras
    , Sum(Bowling_j.no_balls) AS NB
    , Sum(Bowling_j.Wides) AS W
    , (Sum(bowling_j.wides)+Sum(bowling_j.no_balls))/(Sum(overs)*6+Sum(bowling_j.extra_balls)) AS Rate
FROM Seasons_j INNER JOIN (Matches_j INNER JOIN (Innings_j INNER JOIN (Players INNER JOIN Bowling_j ON Players.PlayerID = Bowling_j.PlayerID) ON Innings_j.InningsID = Bowling_j.InningsID) ON Matches_j.MatchID = Innings_j.MatchID) ON Seasons_j.SeasonID = Matches_j.SeasonID
WHERE (Seasons_j.SeasonID)>3
GROUP BY players.player_name, Bowling_j.PlayerID
HAVING (Sum(overs)*6+Sum(bowling_j.extra_balls))>119
ORDER BY (Sum(bowling_j.wides)+Sum(bowling_j.no_balls))/(Sum(overs)*6+Sum(bowling_j.extra_balls)) DESC;


CREATE OR REPLACE VIEW bowling_j_17_dismissals_ct AS
SELECT
    1.0*Sum(CASE WHEN lower(wickets_j.how_out)='caught' then 1 else 0 end)/z_j_bocsa."Total Wickets" as Percentage
    , z_j_bocsa.Name
    , z_j_bocsa."Total Wickets" AS Wickets_j
    , Sum(CASE WHEN lower(wickets_j.how_out)='caught' then 1 else 0 end) AS "Caught W"
FROM z_j_bocsa INNER JOIN (Wickets_j INNER JOIN Players ON Wickets_j.playerID = Players.PlayerID) ON z_j_bocsa.PlayerID = Players.PlayerID
GROUP BY z_j_bocsa.Name, z_j_bocsa."Total Wickets", Players.PlayerID
HAVING (Count(Wickets_j.how_out))>9
ORDER BY Percentage DESC, z_j_bocsa."Total Wickets" Desc;


CREATE OR REPLACE VIEW bowling_j_18_dismissals_b AS
SELECT
    1.0*Sum(CASE WHEN lower(wickets_j.how_out)='bowled' then 1 else 0 end)/z_j_bocsa."Total Wickets" as Percentage
    , z_j_bocsa.Name
    , z_j_bocsa."Total Wickets" AS Wickets_j
    , Sum(CASE WHEN lower(wickets_j.how_out)='bowled' then 1 else 0 end) AS "Bowled W"
FROM z_j_bocsa INNER JOIN (Wickets_j INNER JOIN Players ON Wickets_j.playerID = Players.PlayerID) ON z_j_bocsa.PlayerID = Players.PlayerID
GROUP BY z_j_bocsa.Name, z_j_bocsa."Total Wickets", Players.PlayerID
HAVING (Count(Wickets_j.how_out))>9
ORDER BY Percentage DESC, z_j_bocsa."Total Wickets" Desc;


CREATE OR REPLACE VIEW bowling_j_19_dismissals_lbw AS
SELECT
    1.0*Sum(CASE WHEN lower(wickets_j.how_out)='lbw' then 1 else 0 end)/z_j_bocsa."Total Wickets" as Percentage
    , z_j_bocsa.Name
    , z_j_bocsa."Total Wickets" AS Wickets_j
    , Sum(CASE WHEN lower(wickets_j.how_out)='lbw' then 1 else 0 end) AS "LBW W"
FROM z_j_bocsa INNER JOIN (Wickets_j INNER JOIN Players ON Wickets_j.playerID = Players.PlayerID) ON z_j_bocsa.PlayerID = Players.PlayerID
GROUP BY z_j_bocsa.Name, z_j_bocsa."Total Wickets", Players.PlayerID
HAVING (Count(Wickets_j.how_out))>9
ORDER BY Percentage DESC, z_j_bocsa."Total Wickets" Desc;


CREATE OR REPLACE VIEW bowling_j_20_dismissals_no_lbw AS
SELECT
    z_j_bocsa."Total Wickets" AS Wickets_j
    , z_j_bocsa.Name
FROM z_j_bocsa INNER JOIN (Wickets_j INNER JOIN Players ON Wickets_j.playerID = Players.PlayerID) ON z_j_bocsa.PlayerID = Players.PlayerID
GROUP BY z_j_bocsa.Name, z_j_bocsa."Total Wickets", Players.PlayerID
HAVING Sum(CASE WHEN lower(wickets_j.how_out)='lbw' then 1 else 0 end) = 0
ORDER BY Wickets_j DESC
;

CREATE OR REPLACE VIEW bowling_j_21_dismissals_st AS
SELECT
    Sum(CASE WHEN lower(wickets_j.how_out)='stumped' then 1 else 0 end) AS Stumpings
    , z_j_bocsa.Name
FROM z_j_bocsa INNER JOIN (Wickets_j INNER JOIN Players ON Wickets_j.playerID = Players.PlayerID) ON z_j_bocsa.PlayerID = Players.PlayerID
GROUP BY z_j_bocsa.Name, z_j_bocsa."Total Wickets", Players.PlayerID
HAVING (Count(Wickets_j.how_out))>9
ORDER BY Stumpings DESC, z_j_bocsa."Total Wickets";


CREATE OR REPLACE VIEW bowling_j_22_finals_wickets AS
select 
    sum(bf.w) as "Wickets"
    , players.player_name as "Name"
    , count(inningsid) as "Inn"
    , case when sum(bf.w) > 0 then sum(bf.runs)/sum(bf.w) 
        else null end as "Ave"
from z_j_Bowling_Figures_All as bf
inner join matches_j 
on bf.matchid = matches_j.matchid
inner join players 
on bf.playerid = players.playerid
where matches_j.round in ('SF','GF')
group by players.player_name
having sum(bf.w) > 9
order by "Wickets" desc
;


CREATE OR REPLACE VIEW bowling_j_23_finals_ave AS
select 
    case when sum(bf.w) > 0 then sum(bf.runs)/sum(bf.w) 
        else null end as "Ave"
    , players.player_name as "Name"
    , count(inningsid) as "Inn"
    , sum(bf.w) as "Wickets"

from z_j_Bowling_Figures_All as bf
inner join matches_j 
on bf.matchid = matches_j.matchid
inner join players 
on bf.playerid = players.playerid
where matches_j.round in ('SF','GF')
group by players.player_name
having sum(bf.w) > 9
order by "Ave"
;

--per opponent
CREATE OR REPLACE VIEW bowling_j_24_opp_wickets AS
select 
      players.player_name as "Name"
    , regexp_replace(matches_j.Opponent,' (II|III|IV|V|VI)$','',1,1,'c') AS opponent
    , sum(bf.w) as "Wickets"
    , count(inningsid) as "Inn"
    , case when sum(bf.w) > 0 then sum(bf.runs)/sum(bf.w) 
        else null end as "Ave"
from z_j_Bowling_Figures_All as bf
inner join matches_j 
on bf.matchid = matches_j.matchid
inner join players 
on bf.playerid = players.playerid
group by players.player_name, opponent
having sum(bf.w) > 9
order by "Wickets" desc
;

CREATE OR REPLACE VIEW bowling_j_25_opp_ave AS
select 
      players.player_name as "Name"
    , regexp_replace(matches_j.Opponent,' (II|III|IV|V|VI)$','',1,1,'c') AS opponent
    , case when sum(bf.w) > 0 then sum(bf.runs)/sum(bf.w) 
        else null end as "Ave"
    , count(inningsid) as "Inn"
    , sum(bf.w) as "Wickets"

from z_j_Bowling_Figures_All as bf
inner join matches_j 
on bf.matchid = matches_j.matchid
inner join players 
on bf.playerid = players.playerid
group by players.player_name, opponent
having sum(bf.w) > 9
order by "Ave"
;

-- home/away
--, case when ground similar to '(Bulldog Park|Park 21|Adelaide Lutheran|Schmidt Oval)%' then 'home' else 'away' end as ha
-- drop view tmp_bowling_26_ha_ave;
CREATE OR REPLACE VIEW tmp_bowling_26_ha_ave AS
select 
      players.player_name as "Name"
    , case when ground similar to '(Bulldog Park|Park 21|Adelaide Lutheran|Schmidt Oval)%' then 'home' else 'away' end as ha
    , case when sum(bf.w) > 0 then sum(bf.runs)/sum(bf.w) 
        else null end as "Ave"
    , count(inningsid) as "Inn"
    , sum(bf.w) as "Wickets"

from z_j_Bowling_Figures_All as bf
inner join matches_j 
on bf.matchid = matches_j.matchid
inner join players 
on bf.playerid = players.playerid
group by players.player_name, ha
having sum(bf.w) > 9
order by "Ave"
;

-- drop view bowling_j_26_ha_ave;
CREATE OR REPLACE VIEW bowling_j_26_ha_ave AS
select 
    h."Name"
    , h."Inn" as h_inn, h."Wickets" as h_wickets, h."Ave" as h_ave
    , a."Inn" as a_inn, a."Wickets" as a_wickets, a."Ave" as a_ave
    , a."Ave"-h."Ave" as diff
from tmp_bowling_26_ha_ave h
inner join tmp_bowling_26_ha_ave a
on h."Name" = a."Name"
and h.ha='home'
and a.ha='away'
order by abs(h."Ave"-a."Ave") desc
;

-- drop view bowling_j_27_top4_wickets;
CREATE OR REPLACE VIEW bowling_j_27_top4_wickets AS
select 
    to_char(100*sum(case when wickets_j.batting_position < 5 then 1 else 0 end)::float / count(wickets_j.playerid), '99%') 
     as "Pct of Wickets"
    , players.player_name as "Name"
    , count(wickets_j.playerid) as "Total Wickets"
    , sum(case when wickets_j.batting_position < 5 then 1 else 0 end) as "Top 4 Wickets"
from wickets_j
inner join players
on wickets_j.playerid = players.playerid
group by players.player_name
having count(wickets_j.playerid) > 15
order by "Pct of Wickets" desc
;

--drop view bowling_j_28_bottom4_wickets;
CREATE OR REPLACE VIEW bowling_j_28_bottom4_wickets AS
select 
    to_char(100*sum(case when wickets_j.batting_position > 7 then 1 else 0 end)::float / count(wickets_j.playerid), '99%') 
     as "Pct of Wickets"
    , players.player_name as "Name"
    , count(wickets_j.playerid) as "Total Wickets"
    , sum(case when wickets_j.batting_position > 7 then 1 else 0 end) as "Bottom 4 Wickets"
from wickets_j
inner join players
on wickets_j.playerid = players.playerid
group by players.player_name
having count(wickets_j.playerid) > 15
order by "Pct of Wickets" desc
;