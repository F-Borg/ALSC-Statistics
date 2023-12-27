create or replace view z_all_player_dates AS
SELECT 
    players.surname ||', '|| players.firstname AS "Name"
    , Players.dob
    , Min(Matches.Date1) AS Debut
    , Players.PlayerID
    , Min(Seasons.Year) AS "First Season"
    , Max(Matches.Date1) AS "Final Game"
    , Max(Seasons.Year) AS "Last Season"
    , Count(Matches.MatchID) AS CountOfMatchID
FROM Seasons
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players
ON Players.PlayerID = Batting.PlayerID
GROUP BY players.surname ||', '|| players.firstname, Players.dob, Players.PlayerID;


create or replace view z_wickin AS
SELECT
    innings.inningsid
    , sum(case when upper(how_out) not in ('NOT OUT','RETIRED HURT') then 1 else 0 end) as num_wickets
FROM Innings 
INNER JOIN Wickets 
ON Innings.InningsID = Wickets.InningsID
GROUP BY Innings.InningsID;


create or replace view z_batmax_A AS
SELECT Batting.PlayerID, Max(Batting.Score) AS MaxOfScore
FROM Batting
GROUP BY Batting.PlayerID;


create or replace view z_batmax AS
SELECT z_batmax_A.PlayerID
    , Max(CASE WHEN Batting.how_out='Not Out' Or Batting.how_out='Retired Hurt' then TO_CHAR(Batting.score,'999')||'*' else TO_CHAR(Batting.score,'999') end) AS HS
FROM z_batmax_A 
INNER JOIN Batting 
ON z_batmax_A.MaxOfScore = Batting.Score
AND z_batmax_A.PlayerID = Batting.PlayerID
GROUP BY z_batmax_A.PlayerID;

create or replace view z_batmax_season_A AS
SELECT Batting.PlayerID, Max(Batting.Score) AS MaxOfScore, seasons.seasonid
FROM Seasons INNER JOIN (Matches INNER JOIN (Innings INNER JOIN Batting ON Innings.InningsID = Batting.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
GROUP BY Batting.PlayerID, Seasons.SeasonID;

create or replace view z_batmax_season AS
SELECT z_batmax_season_A.PlayerID
    , Max(CASE WHEN Batting.how_out='Not Out' Or Batting.how_out='Retired Hurt' then TO_CHAR(Batting.score,'999')||'*' else TO_CHAR(Batting.score,'999') end) AS HS
    , Seasons.SeasonID
FROM Matches INNER JOIN (Innings INNER JOIN (Seasons INNER JOIN (Batting INNER JOIN z_batmax_season_A ON (Batting.PlayerID = z_batmax_season_A.PlayerID) AND (Batting.Score = z_batmax_season_A.MaxOfScore)) ON Seasons.SeasonID = z_batmax_season_A.SeasonID) ON Innings.InningsID = Batting.InningsID) ON (Seasons.SeasonID = Matches.SeasonID) AND (Matches.MatchID = Innings.MatchID)
GROUP BY z_batmax_season_A.PlayerID, Seasons.SeasonID;



create or replace view z_batpos_max as
SELECT 
    seasons.eleven
    , Batting.batting_position
    , Max(Batting.Score) AS MaxOfScore
FROM Seasons INNER JOIN (Matches INNER JOIN (Innings INNER JOIN (Players INNER JOIN Batting ON Players.PlayerID = Batting.PlayerID) ON Innings.InningsID = Batting.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
where Batting.batting_position between 1 and 11
GROUP BY seasons.eleven, Batting.batting_position
;


create or replace view z_batting_totals AS
SELECT 
    case when b.num_wickets=10 then (b.bat_runs+i.extras)::varchar
        else concat(b.num_wickets,'/',(b.bat_runs+i.extras)) end as Score
    , i.Ov
    , b.bat_runs+i.extras as runs
    , num_wickets as wickets
    , i.inningsno
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Seasons.Eleven
    , Seasons.Grade
    , Seasons.Association
    , matches.MatchID
FROM seasons 
INNER JOIN matches 
ON seasons.SeasonID = matches.SeasonID
INNER JOIN (
    SELECT
        MatchID
        , InningsID
        , inningsno
        , concat(Bat_Overs,'.',coalesce(extra_balls,'0')) as Ov
        , extras
    from Innings 
    where upper(Innings_Type) = 'BAT'
    and   Bat_Overs > 0
) i
ON Matches.MatchID = i.MatchID
INNER JOIN (
    SELECT inningsid
        , sum(score) as bat_runs
        , sum(case when upper(how_out) not in ('DNB','NOT OUT','RETIRED','RETIRED HURT','FORCED RETIREMENT','0') then 1 else 0 end) as num_wickets
    FROM batting 
    group by inningsid
) b
ON i.InningsID = b.inningsid
;



create or replace view z_bowling_totals AS
SELECT  
    (CASE WHEN max(z_wickin.num_wickets)=10 then '' else max(z_wickin.num_wickets) ||'/' end) || Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras) AS score
    , Sum(bowling.overs) ||'.'|| Sum(bowling.extra_balls) AS ov
    , 6*(Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras))/Sum(6*bowling.overs+bowling.extra_balls) AS run_rate
    , Matches.Opponent
    , Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras) AS runs
    , Matches.MatchID
    , Innings.InningsNO
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID=Matches.SeasonID
INNER JOIN Innings
ON Matches.MatchID=Innings.MatchID
INNER JOIN z_wickin 
ON Innings.InningsID=z_wickin.InningsID
INNER JOIN Bowling 
ON Innings.InningsID=Bowling.InningsID

GROUP BY Matches.Opponent, Innings.InningsID, Matches.MatchID, Innings.InningsNO
HAVING Innings.InningsNO in (1,2)
ORDER BY Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras) DESC;

create or replace view z_bat_ind_dismissal_types AS
SELECT 
    players.player_name AS Name
    , batting_01_summary_ind.Inn-batting_01_summary_ind."NO" AS dismissals
    , Sum(CASE WHEN lower(batting.how_out)<>'not out' And batting.score=0 then 1 else 0 end) AS Ducks
    , Sum(CASE WHEN lower(batting.how_out)='lbw' then 1 else 0 end) AS LBW
    , Sum(CASE WHEN lower(batting.how_out)='caught' then 1 else 0 end) AS C
    , Sum(CASE WHEN lower(batting.how_out)='bowled' then 1 else 0 end) AS B
    , Sum(CASE WHEN lower(batting.how_out)='stumped' then 1 else 0 end) AS ST
    , Sum(CASE WHEN lower(batting.how_out)='run out' then 1 else 0 end) AS RO
    , Sum(CASE WHEN lower(batting.how_out)='retired' then 1 else 0 end) AS Retired
    , Sum(CASE WHEN lower(batting.how_out)='hit wicket' then 1 else 0 end) AS HW
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting 
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting.PlayerID
INNER JOIN z_batmax
ON z_batmax.PlayerID = Players.PlayerID
INNER JOIN batting_01_summary_ind 
ON batting_01_summary_ind.PlayerID = z_batmax.PlayerID
WHERE batting_01_summary_ind.Inn>0
GROUP BY players.player_name, batting_01_summary_ind.Inn-batting_01_summary_ind."NO"
;


--CREATE EXTENSION tablefunc;
create or replace view z_fow_ct as
select * from crosstab(
    'select inningsid, wicket, max(FOW)
    from batting
    group by inningsid, wicket
    order by inningsid, wicket',
    'select distinct wicket from batting where wicket between 1 and 10 order by wicket'
) as ct (inningsid int, "1" int, "2" int, "3" int, "4" int, "5" int, "6" int, "7" int, "8" int, "9" int, "10" int)
;


create or replace view z_bat_partnerships AS
SELECT 
    Batting.InningsID
    , Batting.PlayerID
    , Batting.not_out_batter
    , Batting.Wicket
    , CASE WHEN wicket=1 THEN batting.fow
        ELSE (CASE WHEN wicket=2  THEN z_fow_ct."2" - z_fow_ct."1"
        ELSE (CASE WHEN wicket=3  THEN z_fow_ct."3" - z_fow_ct."2"
        ELSE (CASE WHEN wicket=4  THEN z_fow_ct."4" - z_fow_ct."3"
        ELSE (CASE WHEN wicket=5  THEN z_fow_ct."5" - z_fow_ct."4"
        ELSE (CASE WHEN wicket=6  THEN z_fow_ct."6" - z_fow_ct."5"
        ELSE (CASE WHEN wicket=7  THEN z_fow_ct."7" - z_fow_ct."6"
        ELSE (CASE WHEN wicket=8  THEN z_fow_ct."8" - z_fow_ct."7"
        ELSE (CASE WHEN wicket=9  THEN z_fow_ct."9" - z_fow_ct."8"
        ELSE (CASE WHEN wicket=10 THEN z_fow_ct."10"- z_fow_ct."9" ELSE 0 END) END) END) END) END) END) END) END) END) END AS p
FROM Batting 
INNER JOIN z_fow_ct 
ON Batting.InningsID=z_fow_ct.InningsID
GROUP BY Batting.InningsID, Batting.PlayerID, Batting.not_out_batter, Batting.Wicket, p
HAVING (((Batting.not_out_batter) Is Not Null) AND ((Batting.Wicket) Is Not Null))
ORDER BY p desc, Batting.InningsID, Batting.Wicket;

create or replace view z_bat_part_max AS
SELECT z_bat_partnerships.Wicket, Max(z_bat_partnerships.p) AS MaxOfp, Seasons.Eleven
FROM Seasons INNER JOIN (Matches INNER JOIN (Players AS Players_1 INNER JOIN (Players INNER JOIN (z_bat_partnerships INNER JOIN Innings ON z_bat_partnerships.InningsID = Innings.InningsID) ON Players.PlayerID = z_bat_partnerships.PlayerID) ON Players_1.PlayerID = z_bat_partnerships.not_out_batter) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
GROUP BY z_bat_partnerships.Wicket, Seasons.Eleven
ORDER BY eleven, z_bat_partnerships.Wicket, Max(z_bat_partnerships.p) DESC;

create or replace view z_bat_part_max_season AS
SELECT z_bat_partnerships.Wicket, Max(z_bat_partnerships.p) AS MaxOfp, Matches.SeasonID
FROM Matches INNER JOIN (Players AS Players_1 
INNER JOIN (Players INNER JOIN (z_bat_partnerships 
INNER JOIN Innings ON z_bat_partnerships.InningsID = Innings.InningsID) 
ON Players.PlayerID = z_bat_partnerships.PlayerID) 
ON Players_1.PlayerID = z_bat_partnerships.not_out_batter) ON Matches.MatchID = Innings.MatchID
GROUP BY z_bat_partnerships.Wicket, Matches.SeasonID
;



CREATE OR REPLACE VIEW z_batting_partnerships_highest AS
SELECT 
    z_bat_partnerships.p::varchar || (CASE WHEN lower(batting.how_out)='not out' And lower(batting_1.how_out)='not out' then '*' else '' end) AS Runs
    , z_bat_partnerships.Wicket
    , players.player_name AS "Player 1"
    , players_1.player_name AS "Player 2"
    , Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association, z_bat_partnerships.p
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings
ON Matches.MatchID = Innings.MatchID

INNER JOIN Batting 
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
on Players.PlayerID = Batting.PlayerID

INNER JOIN Batting AS Batting_1 
on Innings.InningsID = Batting_1.InningsID
INNER JOIN Players AS Players_1 
ON Batting_1.PlayerID = Players_1.PlayerID

INNER JOIN z_bat_partnerships 
ON z_bat_partnerships.InningsID = Innings.InningsID
AND Players.PlayerID = z_bat_partnerships.PlayerID
AND Players_1.PlayerID = z_bat_partnerships.not_out_batter
WHERE z_bat_partnerships.p >30
ORDER BY z_bat_partnerships.p DESC;


create or replace view z_player_season_matches AS
SELECT 
    players.player_name AS Name
    , Sum(CASE WHEN innings.inningsno=1 Or innings.inningsno=2 then 1 else 0 end) AS Mat
    , Players.PlayerID
    , Seasons.SeasonID
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID=Matches.SeasonID
INNER JOIN Innings
ON Matches.MatchID=Innings.MatchID
INNER JOIN Batting 
ON Innings.InningsID=Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID=Batting.PlayerID
GROUP BY players.player_name, Players.PlayerID, Seasons.SeasonID
ORDER BY Sum(CASE WHEN innings.inningsno=1 Or innings.inningsno=2 then 1 else 0 end) DESC;


create or replace view z_player_matches_all AS
SELECT players.player_name AS Name
    , Sum(CASE WHEN innings.inningsno=1 Or innings.inningsno=2 then 1 else 0 end) AS Mat
    , batting_01_summary_ind.Debut
    , batting_01_summary_ind."Last Season"
    , Players.PlayerID
FROM Matches 
INNER JOIN (Innings 
INNER JOIN (batting_01_summary_ind 
INNER JOIN (Players 
INNER JOIN Batting ON Players.PlayerID = Batting.PlayerID) ON batting_01_summary_ind.PlayerID = Players.PlayerID) ON Innings.InningsID = 
Batting.InningsID) ON Matches.MatchID = Innings.MatchID
GROUP BY players.player_name, batting_01_summary_ind.Debut, batting_01_summary_ind."Last Season", Players.PlayerID
ORDER BY Sum((CASE WHEN innings.inningsno=1 Or innings.inningsno=2 then 1 else 0 end)) DESC;
;


create or replace view z_Bowling_Figures_All as
SELECT Count(wickets.playerid) ||'/'|| (CASE WHEN lower(Seasons.nbw_status)='true' THEN bowling.no_balls+bowling.wides+bowling.runs_off_bat ELSE bowling.runs_off_bat end) AS Figures
, Bowling.PlayerID
, Bowling.InningsID
, Count(Wickets.playerID) AS w
, Sum(CASE WHEN Wickets.batting_position > 1 then Wickets.batting_position-1 else 1 END) AS TBD
, (CASE WHEN lower(Seasons.nbw_status)='true' THEN bowling.no_balls+bowling.wides+bowling.runs_off_bat ELSE bowling.runs_off_bat END) AS runs
, Bowling.Overs AS Ov1
, Bowling.Extra_Balls
, Bowling.Maidens
, bowling.overs || (CASE WHEN bowling.extra_balls>0 THEN '.' || bowling.extra_balls else '' end) AS Ov
, Matches.MatchID
, Bowling.Wides
, Bowling.no_balls
, Seasons.SeasonID
FROM Seasons 
INNER JOIN (Matches INNER JOIN (Innings 
INNER JOIN (Wickets RIGHT JOIN Bowling ON (Wickets.playerID = Bowling.PlayerID) AND (Wickets.InningsID = Bowling.InningsID)) 
ON Innings.InningsID = Bowling.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
GROUP BY Bowling.PlayerID, Seasons.SeasonID, Bowling.InningsID, Bowling.Overs, Bowling.Extra_Balls, Bowling.Maidens, Matches.MatchID, bowling.no_balls, bowling.wides, bowling.runs_off_bat, seasons.nbw_status
ORDER BY w DESC, runs;


-- create or replace view z_Bowling_Figures as
-- SELECT 
--     z_Bowling_Figures_All.Figures
--     , z_Bowling_Figures_All.PlayerID
--     , z_Bowling_Figures_All.w
--     , z_Bowling_Figures_All.runs
--     , z_Bowling_Figures_All.InningsID
--     , z_Bowling_Figures_All.TBD
-- FROM z_Bowling_Figures_All
-- GROUP BY z_Bowling_Figures_All.Figures, z_Bowling_Figures_All.PlayerID, z_Bowling_Figures_All.w, z_Bowling_Figures_All.runs, z_Bowling_Figures_All.InningsID, z_Bowling_Figures_All.TBD
-- ORDER BY z_Bowling_Figures_All.w DESC , z_Bowling_Figures_All.runs;

--drop view z_Bowling_Career_5WI cascade;
create or replace view z_Bowling_Career_5WI AS
SELECT 
    Sum((CASE WHEN z_Bowling_Figures_All.w>4 then 1 else 0 end)) AS "5WI"
    , players.player_name AS Name
    , batting_01_summary_ind.Mat
    , z_Bowling_Figures_All.PlayerID
    , 6*Sum(z_Bowling_Figures_All.Ov1) + Sum(z_Bowling_Figures_All.extra_balls) as balls
FROM batting_01_summary_ind 
INNER JOIN (Players INNER JOIN z_Bowling_Figures_All ON Players.PlayerID = z_Bowling_Figures_All.PlayerID) ON batting_01_summary_ind.PlayerID = Players.PlayerID
GROUP BY players.player_name, batting_01_summary_ind.Mat, z_Bowling_Figures_All.PlayerID
ORDER BY "5WI" DESC;


-- create or replace view z_bbf_A AS
-- SELECT --Min(z_Bowling_Figures_All.OrderID) AS OrderID_min, 
--     z_Bowling_Figures_All.PlayerID
--     , z_Bowling_Career_5WI."5WI"
-- FROM z_Bowling_Figures_All 
-- INNER JOIN z_Bowling_Career_5WI ON z_Bowling_Figures_All.PlayerID = z_Bowling_Career_5WI.PlayerID
-- GROUP BY z_Bowling_Figures_All.PlayerID, z_Bowling_Career_5WI."5WI"
-- ORDER BY Min(z_Bowling_Figures_All.OrderID);


create or replace view z_bbf AS
select * from (
    SELECT 
        z_Bowling_Figures_All.PlayerID
        , z_Bowling_Figures_All.Figures
        , Sum((CASE WHEN z_Bowling_Figures_All.w>4 then 1 else 0 end)) over (partition by playerid) AS "5WI"
        , z_Bowling_Figures_All.InningsID
        , row_number() over (partition by playerid order by w desc, runs) as bowling_figures_rank
    FROM z_Bowling_Figures_All
) a
where bowling_figures_rank = 1
order by playerid
;

create or replace view z_bbf_season AS
select * from (
    SELECT 
        z_Bowling_Figures_All.PlayerID
        , z_Bowling_Figures_All.seasonid
        , z_Bowling_Figures_All.Figures
        , Sum((CASE WHEN z_Bowling_Figures_All.w>4 then 1 else 0 end)) over (partition by playerid) AS "5WI"
        , z_Bowling_Figures_All.InningsID
        , row_number() over (partition by playerid, seasonid order by w desc, runs) as bowling_figures_rank
    FROM z_Bowling_Figures_All
) a
where bowling_figures_rank = 1
;


create or replace view z_bocsa AS
SELECT 
    Players.player_name AS Name
    , z_player_matches_all.Mat
    , floor((Sum(overs)*6+Sum(bowling.extra_balls))/6)::varchar || 
        CASE WHEN floor((Sum(overs)*6+Sum(bowling.extra_balls))/6)=(Sum(overs)*6+Sum(bowling.extra_balls))/6 THEN '' 
            ELSE '.' || Round(6*((Sum(overs)*6+Sum(bowling.extra_balls))/6-floor((Sum(overs)*6+Sum(bowling.extra_balls))/6))) END AS O
    , Sum(overs)*6+Sum(bowling.extra_balls) AS Balls
    , Sum(Bowling.Maidens) AS Mdns
    , Sum(z_Bowling_Figures_All.runs) AS "Total Runs"
    , Sum(z_Bowling_Figures_All.w) AS "Total Wickets"
    , CASE WHEN Sum(z_Bowling_Figures_All.w)=0 THEN -9 ELSE Sum(z_Bowling_Figures_All.runs)/Sum(z_Bowling_Figures_All.w) END AS Average
    , CASE WHEN Sum(z_Bowling_Figures_All.w)=0 THEN -9 ELSE (Sum(overs)*6+Sum(bowling.extra_balls))/Sum(z_Bowling_Figures_All.w) END AS "Strike Rate"
    , 6*(Sum(z_Bowling_Figures_All.runs))/(Sum(overs)*6+Sum(bowling.extra_balls)) AS RPO
    , Sum(z_Bowling_Figures_All.tbd)/Sum(z_Bowling_Figures_All.w) AS ABD
    , Sum(Bowling._4s_against) AS _4s
    , Sum(Bowling._6s_against) AS _6s
    , z_bbf.Figures
    , z_bbf."5WI"
    , Max(Bowling.HighOver) AS "Expensive Over"
    , Players.PlayerID
FROM Matches 
INNER JOIN (Innings 
INNER JOIN (z_player_matches_all 
INNER JOIN (z_bbf RIGHT JOIN (z_Bowling_Figures_All RIGHT JOIN (Players INNER JOIN Bowling ON Players.PlayerID = Bowling.PlayerID) 
        ON (z_Bowling_Figures_All.InningsID = Bowling.InningsID) AND (z_Bowling_Figures_All.PlayerID = Bowling.PlayerID)) 
    ON z_bbf.PlayerID = Bowling.PlayerID) 
ON z_player_matches_all.PlayerID = Players.PlayerID) 
ON Innings.InningsID = Bowling.InningsID) 
ON Matches.MatchID = Innings.MatchID
GROUP BY Players.player_name, z_player_matches_all.Mat, z_bbf.Figures, z_bbf."5WI", Players.PlayerID, z_Bowling_Figures_All.PlayerID
ORDER BY Players.player_name, Sum(z_Bowling_Figures_All.w) DESC;
;




create or replace view z_bcsa AS
SELECT 
    z_player_matches_all.Name
    , z_player_matches_all.Mat
    , z_bocsa.O
    , z_bocsa.Balls
    , z_bocsa.Mdns
    , z_bocsa."Total Runs"
    , z_bocsa."Total Wickets"
    , z_bocsa.Average
    , z_bocsa."Strike Rate"
    , z_bocsa.RPO
    , z_bocsa.ABD
    , z_bocsa._4s
    , z_bocsa._6s
    , z_bocsa.Figures
    , z_bocsa."5WI"
    , z_bocsa."Expensive Over"
    , Sum(CASE WHEN lower(wickets.how_out) in ('caught','stumped') then 1 else 0 end) AS Dismissals
    , Sum(CASE WHEN lower(wickets.how_out)='caught' then 1 else 0 end) AS Catches
    , Sum(CASE WHEN lower(wickets.how_out)='stumped' then 1 else 0 end) AS Stumpings
    , Players.PlayerID
FROM (Players 
    LEFT JOIN Wickets 
    ON Players.PlayerID = Wickets.assist) 
INNER JOIN z_player_matches_all 
ON Players.PlayerID = z_player_matches_all.PlayerID
LEFT JOIN z_bocsa 
ON z_player_matches_all.Name = z_bocsa.Name
GROUP BY z_player_matches_all.Name, z_player_matches_all.Mat, z_bocsa.O, z_bocsa.Balls, z_bocsa.Mdns, z_bocsa."Total Runs", z_bocsa."Total Wickets", z_bocsa.Average, z_bocsa."Strike Rate", z_bocsa.RPO, z_bocsa.ABD, z_bocsa._4s, z_bocsa._6s, z_bocsa.Figures, z_bocsa."5WI", z_bocsa."Expensive Over", Players.PlayerID, z_player_matches_all.Mat
ORDER BY Dismissals DESC , catches DESC;

