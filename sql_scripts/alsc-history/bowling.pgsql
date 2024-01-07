
drop view bowling_01_summary_ind;
CREATE OR REPLACE VIEW bowling_01_summary_ind AS
SELECT 
    z_bcsa.Name
    , z_bcsa.Mat
    , z_bcsa.O
    , z_bcsa.Balls
    , z_bcsa.Mdns
    , z_bcsa."Total Runs"
    , z_bcsa."Total Wickets"
    , z_bcsa.Average
    , z_bcsa."Strike Rate", z_bcsa.RPO, z_bcsa.ABD, z_bcsa._4s, z_bcsa._6s, z_bcsa.Figures, z_bcsa."5WI", z_bcsa."Expensive Over", z_bcsa.Catches, 
z_bcsa.Stumpings, z_bcsa.PlayerID
FROM z_bcsa
WHERE z_bcsa.Balls>0
--GROUP BY z_bcsa.Name, z_bcsa.Mat, z_bcsa.O, z_bcsa.Balls, z_bcsa.Mdns, z_bcsa."Total Runs", z_bcsa."Total Wickets", z_bcsa.Average, z_bcsa."Strike Rate", z_bcsa.RPO, z_bcsa.ABD, z_bcsa._4s, z_bcsa._6s, z_bcsa.Figures, z_bcsa."5WI", z_bcsa."Expensive Over", z_bcsa.Catches, z_bcsa.Stumpings, z_bcsa.PlayerID
ORDER BY Name
;


CREATE OR REPLACE VIEW bowling_02_p1_wickets AS
select 
    "Total Wickets"
    , Name
    , mat
    , Average
from z_bocsa
where "Total Wickets" > 0
order by "Total Wickets" desc
;


CREATE OR REPLACE VIEW bowling_03_p1_ave AS
select 
    Average
    , Name
    , mat
    , "Total Wickets"
from z_bocsa
where "Total Wickets" > 14
order by Average
;


CREATE OR REPLACE VIEW bowling_04_p1_sr AS
select 
    "Strike Rate"
    , Name
    , mat
    , "Total Wickets"
from z_bocsa
where "Total Wickets" > 14
order by "Strike Rate"
;


CREATE OR REPLACE VIEW bowling_05_p2_career_econ_low AS
select 
    RPO
    , Name
    , O
from z_bocsa
where balls > 119
order by RPO
;


CREATE OR REPLACE VIEW bowling_06_p2_career_econ_high AS
select 
    RPO
    , Name
    , O
from z_bocsa
where balls > 119
order by RPO DESC
;


CREATE OR REPLACE VIEW bowling_07_p2_5WI AS
SELECT 
    "5WI"
    , Name
    , Mat
from z_Bowling_Career_5WI
where balls > 119
order by "5WI" DESC
;


CREATE OR REPLACE VIEW bowling_08_p2_season_wickets AS
SELECT 
    sum(z_Bowling_Figures_All.w) AS Wickets
    , players.player_name
    , sum(z_Bowling_Figures_All.runs)/sum(z_Bowling_Figures_All.w) as Av
    , count(distinct Matches.MatchID) as Mat
    , Seasons.Year, Seasons.Grade, Seasons.Eleven, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID=Matches.SeasonID
INNER JOIN Innings
ON Matches.MatchID=Innings.MatchID
INNER JOIN z_Bowling_Figures_All
ON z_Bowling_Figures_All.inningsid = Innings.inningsid
INNER JOIN players
ON players.playerid = z_Bowling_Figures_All.playerid
group by player_name, z_Bowling_Figures_All.playerid, Seasons.Year, Seasons.Grade, Seasons.Eleven, Seasons.Association
having sum(z_Bowling_Figures_All.w) > 0
order by Wickets DESC, av
;


CREATE OR REPLACE VIEW bowling_09_p3_best_figs AS
SELECT players.player_name AS Player
    , z_Bowling_Figures_All.Ov AS Overs
    , z_Bowling_Figures_All.Figures
    , Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID=Matches.SeasonID
INNER JOIN Innings
ON Matches.MatchID=Innings.MatchID
INNER JOIN z_Bowling_Figures_All
ON z_Bowling_Figures_All.inningsid = Innings.inningsid
INNER JOIN players
ON players.playerid = z_Bowling_Figures_All.playerid
ORDER BY z_Bowling_Figures_All.w DESC , z_Bowling_Figures_All.runs
;


CREATE OR REPLACE VIEW bowling_10_p3_hat_trick AS
SELECT Players.player_Name, Wickets.Hat_Trick, Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Association, Seasons.Grade
FROM Seasons INNER JOIN (Matches INNER JOIN (Players INNER JOIN ((Wickets INNER JOIN (z_Bowling_Figures_All INNER JOIN Bowling ON (z_Bowling_Figures_All.InningsID = Bowling.InningsID) AND (z_Bowling_Figures_All.PlayerID = Bowling.PlayerID)) ON Wickets.InningsID = z_Bowling_Figures_All.InningsID) INNER JOIN Innings ON (Innings.InningsID = Wickets.InningsID) AND (Innings.InningsID = Bowling.InningsID) AND (z_Bowling_Figures_All.InningsID 
= Innings.InningsID)) ON (Players.PlayerID = Bowling.PlayerID) AND (Players.PlayerID = Wickets.playerID)) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
WHERE (((Wickets.Hat_Trick)=1))
ORDER BY Innings.inningsid DESC;

--drop view bowling_11_p3_10WM;
CREATE OR REPLACE VIEW bowling_11_p3_10WM AS
SELECT players.player_Name AS "Name"
    , aa.wickets as "Wickets", aa.Figures as "Figures"
    , Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID=Matches.SeasonID
INNER JOIN (
    
    select 
        playerid, MatchID, sum(w) as wickets, max(figs1) ||' & '|| max(figs2) as figures, max(runs1)+max(runs2) as runs
    from (
        select 
            playerid, MatchID, w
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 1 then figures end as figs1
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 2 then figures end as figs2
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 1 then runs end as runs1
            , case when row_number() over (partition by playerid, MatchID order by inningsid) = 2 then runs end as runs2
        from z_Bowling_Figures_All
    ) a
    group by playerid, MatchID
    having sum(w) >= 10
) aa
ON aa.MatchID = Matches.MatchID
INNER JOIN players
ON players.playerid = aa.playerid
--GROUP BY players.player_Name, Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
ORDER BY aa.wickets DESC , aa.runs;


--drop view bowling_12_p3_match_econ;
CREATE OR REPLACE VIEW bowling_12_p3_match_econ AS
SELECT players.player_name AS Player
    , z_Bowling_Figures_All.Ov AS Overs
    , z_Bowling_Figures_All.Figures
    , Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID=Matches.SeasonID
INNER JOIN Innings
ON Matches.MatchID=Innings.MatchID
INNER JOIN z_Bowling_Figures_All
ON z_Bowling_Figures_All.inningsid = Innings.inningsid
INNER JOIN players
ON players.playerid = z_Bowling_Figures_All.playerid
where (6*z_Bowling_Figures_All.Ov1 + z_Bowling_Figures_All.Extra_Balls) > 59
ORDER BY (6.0*z_Bowling_Figures_All.runs/(6*z_Bowling_Figures_All.Ov1 + z_Bowling_Figures_All.Extra_Balls))
;

CREATE OR REPLACE VIEW bowling_13_p4_match_runs AS
SELECT players.player_name AS Player
    , z_Bowling_Figures_All.Ov AS Overs
    , z_Bowling_Figures_All.Figures
    , Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID=Matches.SeasonID
INNER JOIN Innings
ON Matches.MatchID=Innings.MatchID
INNER JOIN z_Bowling_Figures_All
ON z_Bowling_Figures_All.inningsid = Innings.inningsid
INNER JOIN players
ON players.playerid = z_Bowling_Figures_All.playerid
ORDER BY z_Bowling_Figures_All.runs DESC, z_Bowling_Figures_All.w DESC
;

CREATE OR REPLACE VIEW bowling_14_p4_match_econ_high AS
SELECT players.player_name AS Player
    , z_Bowling_Figures_All.Ov AS Overs
    , z_Bowling_Figures_All.Figures
    , (6.0*z_Bowling_Figures_All.runs/(6*z_Bowling_Figures_All.Ov1 + z_Bowling_Figures_All.Extra_Balls)) AS Econ
    , Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID=Matches.SeasonID
INNER JOIN Innings
ON Matches.MatchID=Innings.MatchID
INNER JOIN z_Bowling_Figures_All
ON z_Bowling_Figures_All.inningsid = Innings.inningsid
INNER JOIN players
ON players.playerid = z_Bowling_Figures_All.playerid
where (6*z_Bowling_Figures_All.Ov1 + z_Bowling_Figures_All.Extra_Balls) > 29
ORDER BY (6.0*z_Bowling_Figures_All.runs/(6*z_Bowling_Figures_All.Ov1 + z_Bowling_Figures_All.Extra_Balls)) DESC
;

CREATE OR REPLACE VIEW bowling_15_p4_expensive_over AS
SELECT players.player_name AS Name, Bowling.HighOver, Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Bowling
ON Innings.InningsID = Bowling.InningsID
INNER JOIN Players 
ON Players.PlayerID = Bowling.PlayerID 
where Bowling.HighOver>9
ORDER BY Bowling.HighOver DESC;


CREATE OR REPLACE VIEW bowling_16_p4_extras_high AS
SELECT players.player_name AS Name
    , Sum(bowling.wides)+Sum(bowling.no_balls) AS Extras
    , Sum(Bowling.no_balls) AS NB
    , Sum(Bowling.Wides) AS W
    , (Sum(bowling.wides)+Sum(bowling.no_balls))/(Sum(overs)*6+Sum(bowling.extra_balls)) AS Rate
FROM Seasons INNER JOIN (Matches INNER JOIN (Innings INNER JOIN (Players INNER JOIN Bowling ON Players.PlayerID = Bowling.PlayerID) ON Innings.InningsID = Bowling.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
WHERE (Seasons.SeasonID)>3
GROUP BY players.player_name, Bowling.PlayerID
HAVING (Sum(overs)*6+Sum(bowling.extra_balls))>119
ORDER BY (Sum(bowling.wides)+Sum(bowling.no_balls))/(Sum(overs)*6+Sum(bowling.extra_balls)) DESC;


CREATE OR REPLACE VIEW bowling_17_dismissals_ct AS
SELECT
    1.0*Sum(CASE WHEN lower(wickets.how_out)='caught' then 1 else 0 end)/z_bocsa."Total Wickets" as Percentage
    , z_bocsa.Name
    , z_bocsa."Total Wickets" AS Wickets
    , Sum(CASE WHEN lower(wickets.how_out)='caught' then 1 else 0 end) AS "Caught W"
FROM z_bocsa INNER JOIN (Wickets INNER JOIN Players ON Wickets.playerID = Players.PlayerID) ON z_bocsa.PlayerID = Players.PlayerID
GROUP BY z_bocsa.Name, z_bocsa."Total Wickets", Players.PlayerID
HAVING (Count(Wickets.how_out))>9
ORDER BY Percentage DESC, z_bocsa."Total Wickets" Desc;


CREATE OR REPLACE VIEW bowling_18_dismissals_b AS
SELECT
    1.0*Sum(CASE WHEN lower(wickets.how_out)='bowled' then 1 else 0 end)/z_bocsa."Total Wickets" as Percentage
    , z_bocsa.Name
    , z_bocsa."Total Wickets" AS Wickets
    , Sum(CASE WHEN lower(wickets.how_out)='bowled' then 1 else 0 end) AS "Bowled W"
FROM z_bocsa INNER JOIN (Wickets INNER JOIN Players ON Wickets.playerID = Players.PlayerID) ON z_bocsa.PlayerID = Players.PlayerID
GROUP BY z_bocsa.Name, z_bocsa."Total Wickets", Players.PlayerID
HAVING (Count(Wickets.how_out))>9
ORDER BY Percentage DESC, z_bocsa."Total Wickets" Desc;


CREATE OR REPLACE VIEW bowling_19_dismissals_lbw AS
SELECT
    1.0*Sum(CASE WHEN lower(wickets.how_out)='lbw' then 1 else 0 end)/z_bocsa."Total Wickets" as Percentage
    , z_bocsa.Name
    , z_bocsa."Total Wickets" AS Wickets
    , Sum(CASE WHEN lower(wickets.how_out)='lbw' then 1 else 0 end) AS "LBW W"
FROM z_bocsa INNER JOIN (Wickets INNER JOIN Players ON Wickets.playerID = Players.PlayerID) ON z_bocsa.PlayerID = Players.PlayerID
GROUP BY z_bocsa.Name, z_bocsa."Total Wickets", Players.PlayerID
HAVING (Count(Wickets.how_out))>9
ORDER BY Percentage DESC, z_bocsa."Total Wickets" Desc;


CREATE OR REPLACE VIEW bowling_20_dismissals_no_lbw AS
SELECT
    z_bocsa."Total Wickets" AS Wickets
    , z_bocsa.Name
FROM z_bocsa INNER JOIN (Wickets INNER JOIN Players ON Wickets.playerID = Players.PlayerID) ON z_bocsa.PlayerID = Players.PlayerID
GROUP BY z_bocsa.Name, z_bocsa."Total Wickets", Players.PlayerID
HAVING Sum(CASE WHEN lower(wickets.how_out)='lbw' then 1 else 0 end) = 0
ORDER BY Wickets DESC
;

CREATE OR REPLACE VIEW bowling_21_dismissals_st AS
SELECT
    Sum(CASE WHEN lower(wickets.how_out)='stumped' then 1 else 0 end) AS Stumpings
    , z_bocsa.Name
FROM z_bocsa INNER JOIN (Wickets INNER JOIN Players ON Wickets.playerID = Players.PlayerID) ON z_bocsa.PlayerID = Players.PlayerID
GROUP BY z_bocsa.Name, z_bocsa."Total Wickets", Players.PlayerID
HAVING (Count(Wickets.how_out))>9
ORDER BY Stumpings DESC, z_bocsa."Total Wickets";



