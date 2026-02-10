
CREATE OR REPLACE VIEW bowling_i_01_summary_ind AS
SELECT 
    z_i_bcsa.Name
    , z_i_bcsa.Mat
    , z_i_bcsa.O
    , z_i_bcsa.Balls
    , z_i_bcsa.Mdns
    , z_i_bcsa."Total Runs"
    , z_i_bcsa."Total Wickets_i"
    , z_i_bcsa.Average
    , z_i_bcsa."Strike Rate", z_i_bcsa.RPO, z_i_bcsa.ABD, z_i_bcsa._4s, z_i_bcsa._6s, z_i_bcsa.Figures, z_i_bcsa."5WI", z_i_bcsa."Expensive Over", z_i_bcsa.Catches, 
z_i_bcsa.Stumpings, z_i_bcsa.PlayerID
FROM z_i_bcsa
WHERE z_i_bcsa.Balls>0
--GROUP BY z_i_bcsa.Name, z_i_bcsa.Mat, z_i_bcsa.O, z_i_bcsa.Balls, z_i_bcsa.Mdns, z_i_bcsa."Total Runs", z_i_bcsa."Total Wickets_i", z_i_bcsa.Average, z_i_bcsa."Strike Rate", z_i_bcsa.RPO, z_i_bcsa.ABD, z_i_bcsa._4s, z_i_bcsa._6s, z_i_bcsa.Figures, z_i_bcsa."5WI", z_i_bcsa."Expensive Over", z_i_bcsa.Catches, z_i_bcsa.Stumpings, z_i_bcsa.PlayerID
ORDER BY Name
;


CREATE OR REPLACE VIEW bowling_i_02_p1_wickets AS
select 
    "Total Wickets_i"
    , Name
    , mat
    , Average
from z_i_bocsa
where "Total Wickets_i" > 0
order by "Total Wickets_i" desc
;


CREATE OR REPLACE VIEW bowling_i_03_p1_ave AS
select 
    Average
    , Name
    , mat
    , "Total Wickets_i"
from z_i_bocsa
where "Total Wickets_i" > 14
order by Average
;


CREATE OR REPLACE VIEW bowling_i_04_p1_sr AS
select 
    "Strike Rate"
    , Name
    , mat
    , "Total Wickets_i"
from z_i_bocsa
where "Total Wickets_i" > 14
order by "Strike Rate"
;


CREATE OR REPLACE VIEW bowling_i_05_p2_career_econ_low AS
select 
    RPO
    , Name
    , O
from z_i_bocsa
where balls > 119
order by RPO
;


CREATE OR REPLACE VIEW bowling_i_06_p2_career_econ_high AS
select 
    RPO
    , Name
    , O
from z_i_bocsa
where balls > 119
order by RPO DESC
;


CREATE OR REPLACE VIEW bowling_i_07_p2_5WI AS
SELECT 
    "5WI"
    , Name
    , Mat
from z_i_Bowling_Career_5WI
where balls > 119
order by "5WI" DESC
;


CREATE OR REPLACE VIEW bowling_i_08_p2_season_wickets AS
SELECT 
    sum(z_i_Bowling_Figures_All.w) AS Wickets_i
    , players.player_name
    , sum(z_i_Bowling_Figures_All.runs)/sum(z_i_Bowling_Figures_All.w) as Av
    , count(distinct Matches_i.MatchID) as Mat
    , Seasons_i.Year, Seasons_i.Grade, Seasons_i.Eleven, Seasons_i.Association
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID=Matches_i.SeasonID
INNER JOIN Innings_i
ON Matches_i.MatchID=Innings_i.MatchID
INNER JOIN z_i_Bowling_Figures_All
ON z_i_Bowling_Figures_All.inningsid = Innings_i.inningsid
INNER JOIN players
ON players.playerid = z_i_Bowling_Figures_All.playerid
group by player_name, z_i_Bowling_Figures_All.playerid, Seasons_i.Year, Seasons_i.Grade, Seasons_i.Eleven, Seasons_i.Association
having sum(z_i_Bowling_Figures_All.w) > 0
order by Wickets_i DESC, av
;


CREATE OR REPLACE VIEW bowling_i_09_p3_best_figs AS
SELECT players.player_name AS Player
    , z_i_Bowling_Figures_All.Ov AS Overs
    , z_i_Bowling_Figures_All.Figures
    , Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Seasons_i.Association
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID=Matches_i.SeasonID
INNER JOIN Innings_i
ON Matches_i.MatchID=Innings_i.MatchID
INNER JOIN z_i_Bowling_Figures_All
ON z_i_Bowling_Figures_All.inningsid = Innings_i.inningsid
INNER JOIN players
ON players.playerid = z_i_Bowling_Figures_All.playerid
ORDER BY z_i_Bowling_Figures_All.w DESC , z_i_Bowling_Figures_All.runs
;


CREATE OR REPLACE VIEW bowling_i_10_p3_hat_trick AS
SELECT Players.player_Name, Wickets_i.Hat_Trick, Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Association, Seasons_i.Grade
FROM Seasons_i INNER JOIN (Matches_i INNER JOIN (Players INNER JOIN ((Wickets_i INNER JOIN (z_i_Bowling_Figures_All INNER JOIN Bowling_i ON (z_i_Bowling_Figures_All.InningsID = Bowling_i.InningsID) AND (z_i_Bowling_Figures_All.PlayerID = Bowling_i.PlayerID)) ON Wickets_i.InningsID = z_i_Bowling_Figures_All.InningsID) INNER JOIN Innings_i ON (Innings_i.InningsID = Wickets_i.InningsID) AND (Innings_i.InningsID = Bowling_i.InningsID) AND (z_i_Bowling_Figures_All.InningsID 
= Innings_i.InningsID)) ON (Players.PlayerID = Bowling_i.PlayerID) AND (Players.PlayerID = Wickets_i.playerID)) ON Matches_i.MatchID = Innings_i.MatchID) ON Seasons_i.SeasonID = Matches_i.SeasonID
WHERE (((Wickets_i.Hat_Trick)=1))
ORDER BY Innings_i.inningsid DESC;

--drop view bowling_i_11_p3_10WM;
CREATE OR REPLACE VIEW bowling_i_11_p3_10WM AS
SELECT players.player_Name AS "Name"
    , aa.wickets_i as "Wickets_i", aa.Figures as "Figures"
    , Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Seasons_i.Association
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID=Matches_i.SeasonID
INNER JOIN (
    
    select 
        playerid, MatchID, sum(w) as wickets_i, max(figs1) ||' & '|| max(figs2) as figures, max(runs1)+max(runs2) as runs
    from (
        select 
            playerid, MatchID, w
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 1 then figures end as figs1
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 2 then figures end as figs2
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 1 then runs end as runs1
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 2 then runs end as runs2
        from z_i_Bowling_Figures_All
    ) a
    group by playerid, MatchID
    having sum(w) >= 10
) aa
ON aa.MatchID = Matches_i.MatchID
INNER JOIN players
ON players.playerid = aa.playerid
--GROUP BY players.player_Name, Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Seasons_i.Association
ORDER BY aa.wickets_i DESC , aa.runs;


--drop view bowling_i_12_p3_match_econ;
CREATE OR REPLACE VIEW bowling_i_12_p3_match_econ AS
SELECT players.player_name AS Player
    , z_i_Bowling_Figures_All.Ov AS Overs
    , z_i_Bowling_Figures_All.Figures
    , Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Seasons_i.Association
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID=Matches_i.SeasonID
INNER JOIN Innings_i
ON Matches_i.MatchID=Innings_i.MatchID
INNER JOIN z_i_Bowling_Figures_All
ON z_i_Bowling_Figures_All.inningsid = Innings_i.inningsid
INNER JOIN players
ON players.playerid = z_i_Bowling_Figures_All.playerid
where (6*z_i_Bowling_Figures_All.Ov1 + z_i_Bowling_Figures_All.Extra_Balls) > 59
ORDER BY (6.0*z_i_Bowling_Figures_All.runs/(6*z_i_Bowling_Figures_All.Ov1 + z_i_Bowling_Figures_All.Extra_Balls))
;

CREATE OR REPLACE VIEW bowling_i_13_p4_match_runs AS
SELECT players.player_name AS Player
    , z_i_Bowling_Figures_All.Ov AS Overs
    , z_i_Bowling_Figures_All.Figures
    , Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Seasons_i.Association
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID=Matches_i.SeasonID
INNER JOIN Innings_i
ON Matches_i.MatchID=Innings_i.MatchID
INNER JOIN z_i_Bowling_Figures_All
ON z_i_Bowling_Figures_All.inningsid = Innings_i.inningsid
INNER JOIN players
ON players.playerid = z_i_Bowling_Figures_All.playerid
ORDER BY z_i_Bowling_Figures_All.runs DESC, z_i_Bowling_Figures_All.w DESC
;

CREATE OR REPLACE VIEW bowling_i_14_p4_match_econ_high AS
SELECT players.player_name AS Player
    , z_i_Bowling_Figures_All.Ov AS Overs
    , z_i_Bowling_Figures_All.Figures
    , (6.0*z_i_Bowling_Figures_All.runs/(6*z_i_Bowling_Figures_All.Ov1 + z_i_Bowling_Figures_All.Extra_Balls)) AS Econ
    , Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Seasons_i.Association
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID=Matches_i.SeasonID
INNER JOIN Innings_i
ON Matches_i.MatchID=Innings_i.MatchID
INNER JOIN z_i_Bowling_Figures_All
ON z_i_Bowling_Figures_All.inningsid = Innings_i.inningsid
INNER JOIN players
ON players.playerid = z_i_Bowling_Figures_All.playerid
where (6*z_i_Bowling_Figures_All.Ov1 + z_i_Bowling_Figures_All.Extra_Balls) > 29
ORDER BY (6.0*z_i_Bowling_Figures_All.runs/(6*z_i_Bowling_Figures_All.Ov1 + z_i_Bowling_Figures_All.Extra_Balls)) DESC
;

CREATE OR REPLACE VIEW bowling_i_15_p4_expensive_over AS
SELECT players.player_name AS Name, Bowling_i.HighOver, Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Seasons_i.Association
FROM Seasons_i 
INNER JOIN Matches_i 
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN Innings_i 
ON Matches_i.MatchID = Innings_i.MatchID
INNER JOIN Bowling_i
ON Innings_i.InningsID = Bowling_i.InningsID
INNER JOIN Players 
ON Players.PlayerID = Bowling_i.PlayerID 
where Bowling_i.HighOver>9
ORDER BY Bowling_i.HighOver DESC;


CREATE OR REPLACE VIEW bowling_i_16_p4_extras_high AS
SELECT players.player_name AS Name
    , Sum(bowling_i.wides)+Sum(bowling_i.no_balls) AS Extras
    , Sum(Bowling_i.no_balls) AS NB
    , Sum(Bowling_i.Wides) AS W
    , (Sum(bowling_i.wides)+Sum(bowling_i.no_balls))/(Sum(overs)*6+Sum(bowling_i.extra_balls)) AS Rate
FROM Seasons_i INNER JOIN (Matches_i INNER JOIN (Innings_i INNER JOIN (Players INNER JOIN Bowling_i ON Players.PlayerID = Bowling_i.PlayerID) ON Innings_i.InningsID = Bowling_i.InningsID) ON Matches_i.MatchID = Innings_i.MatchID) ON Seasons_i.SeasonID = Matches_i.SeasonID
WHERE (Seasons_i.SeasonID)>3
GROUP BY players.player_name, Bowling_i.PlayerID
HAVING (Sum(overs)*6+Sum(bowling_i.extra_balls))>119
ORDER BY (Sum(bowling_i.wides)+Sum(bowling_i.no_balls))/(Sum(overs)*6+Sum(bowling_i.extra_balls)) DESC;


CREATE OR REPLACE VIEW bowling_i_17_dismissals_ct AS
SELECT
    1.0*Sum(CASE WHEN lower(wickets_i.how_out)='caught' then 1 else 0 end)/z_i_bocsa."Total Wickets_i" as Percentage
    , z_i_bocsa.Name
    , z_i_bocsa."Total Wickets_i" AS Wickets_i
    , Sum(CASE WHEN lower(wickets_i.how_out)='caught' then 1 else 0 end) AS "Caught W"
FROM z_i_bocsa INNER JOIN (Wickets_i INNER JOIN Players ON Wickets_i.playerID = Players.PlayerID) ON z_i_bocsa.PlayerID = Players.PlayerID
GROUP BY z_i_bocsa.Name, z_i_bocsa."Total Wickets_i", Players.PlayerID
HAVING (Count(Wickets_i.how_out))>9
ORDER BY Percentage DESC, z_i_bocsa."Total Wickets_i" Desc;


CREATE OR REPLACE VIEW bowling_i_18_dismissals_b AS
SELECT
    1.0*Sum(CASE WHEN lower(wickets_i.how_out)='bowled' then 1 else 0 end)/z_i_bocsa."Total Wickets_i" as Percentage
    , z_i_bocsa.Name
    , z_i_bocsa."Total Wickets_i" AS Wickets_i
    , Sum(CASE WHEN lower(wickets_i.how_out)='bowled' then 1 else 0 end) AS "Bowled W"
FROM z_i_bocsa INNER JOIN (Wickets_i INNER JOIN Players ON Wickets_i.playerID = Players.PlayerID) ON z_i_bocsa.PlayerID = Players.PlayerID
GROUP BY z_i_bocsa.Name, z_i_bocsa."Total Wickets_i", Players.PlayerID
HAVING (Count(Wickets_i.how_out))>9
ORDER BY Percentage DESC, z_i_bocsa."Total Wickets_i" Desc;


CREATE OR REPLACE VIEW bowling_i_19_dismissals_lbw AS
SELECT
    1.0*Sum(CASE WHEN lower(wickets_i.how_out)='lbw' then 1 else 0 end)/z_i_bocsa."Total Wickets_i" as Percentage
    , z_i_bocsa.Name
    , z_i_bocsa."Total Wickets_i" AS Wickets_i
    , Sum(CASE WHEN lower(wickets_i.how_out)='lbw' then 1 else 0 end) AS "LBW W"
FROM z_i_bocsa INNER JOIN (Wickets_i INNER JOIN Players ON Wickets_i.playerID = Players.PlayerID) ON z_i_bocsa.PlayerID = Players.PlayerID
GROUP BY z_i_bocsa.Name, z_i_bocsa."Total Wickets_i", Players.PlayerID
HAVING (Count(Wickets_i.how_out))>9
ORDER BY Percentage DESC, z_i_bocsa."Total Wickets_i" Desc;


CREATE OR REPLACE VIEW bowling_i_20_dismissals_no_lbw AS
SELECT
    z_i_bocsa."Total Wickets_i" AS Wickets_i
    , z_i_bocsa.Name
FROM z_i_bocsa INNER JOIN (Wickets_i INNER JOIN Players ON Wickets_i.playerID = Players.PlayerID) ON z_i_bocsa.PlayerID = Players.PlayerID
GROUP BY z_i_bocsa.Name, z_i_bocsa."Total Wickets_i", Players.PlayerID
HAVING Sum(CASE WHEN lower(wickets_i.how_out)='lbw' then 1 else 0 end) = 0
ORDER BY Wickets_i DESC
;

CREATE OR REPLACE VIEW bowling_i_21_dismissals_st AS
SELECT
    Sum(CASE WHEN lower(wickets_i.how_out)='stumped' then 1 else 0 end) AS Stumpings
    , z_i_bocsa.Name
FROM z_i_bocsa INNER JOIN (Wickets_i INNER JOIN Players ON Wickets_i.playerID = Players.PlayerID) ON z_i_bocsa.PlayerID = Players.PlayerID
GROUP BY z_i_bocsa.Name, z_i_bocsa."Total Wickets_i", Players.PlayerID
HAVING (Count(Wickets_i.how_out))>9
ORDER BY Stumpings DESC, z_i_bocsa."Total Wickets_i";


CREATE OR REPLACE VIEW bowling_i_22_finals_wickets AS
select 
    sum(bf.w) as "Wickets_i"
    , players.player_name as "Name"
    , count(inningsid) as "Inn"
    , case when sum(bf.w) > 0 then sum(bf.runs)/sum(bf.w) 
        else null end as "Ave"
from z_i_Bowling_Figures_All as bf
inner join matches_i 
on bf.matchid = matches_i.matchid
inner join players 
on bf.playerid = players.playerid
where matches_i.round in ('SF','GF')
group by players.player_name
having sum(bf.w) > 9
order by "Wickets_i" desc
;


CREATE OR REPLACE VIEW bowling_i_23_finals_ave AS
select 
    case when sum(bf.w) > 0 then sum(bf.runs)/sum(bf.w) 
        else null end as "Ave"
    , players.player_name as "Name"
    , count(inningsid) as "Inn"
    , sum(bf.w) as "Wickets_i"

from z_i_Bowling_Figures_All as bf
inner join matches_i 
on bf.matchid = matches_i.matchid
inner join players 
on bf.playerid = players.playerid
where matches_i.round in ('SF','GF')
group by players.player_name
having sum(bf.w) > 9
order by "Ave"
;