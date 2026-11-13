DROP VIEW z_j_all_player_dates;
create or replace view z_j_all_player_dates AS
SELECT 
    players.surname ||', '|| players.firstname AS "Name"
    , Players.dob
    , Min(Matches_j.Date1) AS Debut
    , Players.PlayerID
    , Min(Seasons_j.Year) AS "First Season"
    , Max(Matches_j.Date1) AS "Final Game"
    , Max(Seasons_j.Year) AS "Last Season"
    , Count(Matches_j.MatchID) AS CountOfMatchID
FROM Seasons_j
INNER JOIN Matches_j
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN Players
ON Players.PlayerID = Batting_j.PlayerID
GROUP BY players.surname ||', '|| players.firstname, Players.dob, Players.PlayerID;


create or replace view z_j_wickin AS
SELECT
    innings_j.inningsid
    , sum(case when lower(how_out) not in ('not out','retired hurt','retired not out','error','0','dnb') then 1 else 0 end) as num_wickets
FROM Innings_j 
INNER JOIN Wickets_j 
ON Innings_j.InningsID = Wickets_j.InningsID
GROUP BY Innings_j.InningsID;


create or replace view z_j_batmax_A AS
SELECT Batting_j.PlayerID, Max(Batting_j.Score) AS MaxOfScore
FROM Batting_j
GROUP BY Batting_j.PlayerID;


create or replace view z_j_batmax AS
SELECT z_j_batmax_A.PlayerID
    , Max(CASE WHEN lower(Batting_j.how_out) in ('not out','retired hurt','retired not out') then TO_CHAR(Batting_j.score,'999')||'*' else TO_CHAR(Batting_j.score,'999') end) AS HS
FROM z_j_batmax_A 
INNER JOIN Batting_j 
ON z_j_batmax_A.MaxOfScore = Batting_j.Score
AND z_j_batmax_A.PlayerID = Batting_j.PlayerID
GROUP BY z_j_batmax_A.PlayerID;

create or replace view z_j_batmax_season_A AS
SELECT Batting_j.PlayerID, Max(Batting_j.Score) AS MaxOfScore, seasons_j.seasonid
FROM Seasons_j INNER JOIN (Matches_j INNER JOIN (Innings_j INNER JOIN Batting_j ON Innings_j.InningsID = Batting_j.InningsID) ON Matches_j.MatchID = Innings_j.MatchID) ON Seasons_j.SeasonID = Matches_j.SeasonID
GROUP BY Batting_j.PlayerID, Seasons_j.SeasonID;

create or replace view z_j_batmax_season AS
SELECT z_j_batmax_season_A.PlayerID
    , Max(CASE WHEN lower(Batting_j.how_out) in ('not out','retired hurt','retired not out') then TO_CHAR(Batting_j.score,'999')||'*' else TO_CHAR(Batting_j.score,'999') end) AS HS
    , Seasons_j.SeasonID
FROM Matches_j INNER JOIN (Innings_j INNER JOIN (Seasons_j INNER JOIN (Batting_j INNER JOIN z_j_batmax_season_A ON (Batting_j.PlayerID = z_j_batmax_season_A.PlayerID) AND (Batting_j.Score = z_j_batmax_season_A.MaxOfScore)) ON Seasons_j.SeasonID = z_j_batmax_season_A.SeasonID) ON Innings_j.InningsID = Batting_j.InningsID) ON (Seasons_j.SeasonID = Matches_j.SeasonID) AND (Matches_j.MatchID = Innings_j.MatchID)
GROUP BY z_j_batmax_season_A.PlayerID, Seasons_j.SeasonID;



create or replace view z_j_batpos_max as
SELECT 
    seasons_j.eleven
    , Batting_j.batting_position
    , Max(Batting_j.Score) AS MaxOfScore
FROM Seasons_j INNER JOIN (Matches_j INNER JOIN (Innings_j INNER JOIN (Players INNER JOIN Batting_j ON Players.PlayerID = Batting_j.PlayerID) ON Innings_j.InningsID = Batting_j.InningsID) ON Matches_j.MatchID = Innings_j.MatchID) ON Seasons_j.SeasonID = Matches_j.SeasonID
where Batting_j.batting_position between 1 and 11
GROUP BY seasons_j.eleven, Batting_j.batting_position
;


create or replace view z_j_batting_totals AS
SELECT 
    case when b.num_wickets=10 then (b.bat_runs+i.extras)::varchar
        else concat(b.num_wickets,'/',(b.bat_runs+i.extras)) end as Score
    , i.Ov
    , b.bat_runs+i.extras as runs
    , num_wickets as wickets_j
    , i.inningsno
    , Matches_j.Opponent
    , Seasons_j.Year
    , Matches_j.Round
    , Seasons_j.Eleven
    , Seasons_j.Grade
    , Seasons_j.Association
    , matches_j.MatchID
FROM seasons_j 
INNER JOIN matches_j 
ON seasons_j.SeasonID = matches_j.SeasonID
INNER JOIN (
    SELECT
        MatchID
        , InningsID
        , inningsno
        , concat(Bat_Overs,'.',coalesce(extra_balls,'0')) as Ov
        , extras
    from Innings_j 
    where upper(Innings_Type) = 'BAT'
    and   Bat_Overs > 0
) i
ON Matches_j.MatchID = i.MatchID
INNER JOIN (
    SELECT inningsid
        , sum(score) as bat_runs
        , sum(case when lower(how_out) not in ('dnb','not out','retired','retired hurt','retired not out','forced retirement','0') then 1 else 0 end) as num_wickets
    FROM batting_j 
    group by inningsid
) b
ON i.InningsID = b.inningsid
;



create or replace view z_j_bowling_totals AS
SELECT  
    (CASE WHEN max(z_j_wickin.num_wickets)=10 then '' else max(z_j_wickin.num_wickets) ||'/' end) || Sum(Bowling_j.no_balls)+Sum(Bowling_j.Wides)+Sum(Bowling_j.runs_off_bat)+max(Innings_j.Extras) AS score
    , Sum(bowling_j.overs) ||'.'|| Sum(bowling_j.extra_balls) AS ov
    , 6*(Sum(Bowling_j.no_balls)+Sum(Bowling_j.Wides)+Sum(Bowling_j.runs_off_bat)+max(Innings_j.Extras))/Sum(6*bowling_j.overs+bowling_j.extra_balls) AS run_rate
    , Matches_j.Opponent
    , Sum(Bowling_j.no_balls)+Sum(Bowling_j.Wides)+Sum(Bowling_j.runs_off_bat)+max(Innings_j.Extras) AS runs
    , Matches_j.MatchID
    , Innings_j.InningsNO
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID=Matches_j.SeasonID
INNER JOIN Innings_j
ON Matches_j.MatchID=Innings_j.MatchID
INNER JOIN z_j_wickin 
ON Innings_j.InningsID=z_j_wickin.InningsID
INNER JOIN Bowling_j 
ON Innings_j.InningsID=Bowling_j.InningsID

GROUP BY Matches_j.Opponent, Innings_j.InningsID, Matches_j.MatchID, Innings_j.InningsNO
HAVING Innings_j.InningsNO in (1,2)
ORDER BY Sum(Bowling_j.no_balls)+Sum(Bowling_j.Wides)+Sum(Bowling_j.runs_off_bat)+max(Innings_j.Extras) DESC;
--!!! ran til here

create or replace view z_j_bat_ind_dismissal_types AS
SELECT 
    players.player_name AS Name
    , batting_j_01_summary_ind.Inn-batting_j_01_summary_ind."NO" AS dismissals
    , Sum(CASE WHEN lower(batting_j.how_out)<>'not out' And batting_j.score=0 then 1 else 0 end) AS Ducks
    , Sum(CASE WHEN lower(batting_j.how_out)='lbw' then 1 else 0 end) AS LBW
    , Sum(CASE WHEN lower(batting_j.how_out)='caught' then 1 else 0 end) AS C
    , Sum(CASE WHEN lower(batting_j.how_out)='bowled' then 1 else 0 end) AS B
    , Sum(CASE WHEN lower(batting_j.how_out)='stumped' then 1 else 0 end) AS ST
    , Sum(CASE WHEN lower(batting_j.how_out)='run out' then 1 else 0 end) AS RO
    , Sum(CASE WHEN lower(batting_j.how_out)='retired' then 1 else 0 end) AS Retired
    , Sum(CASE WHEN lower(batting_j.how_out)='hit wicket' then 1 else 0 end) AS HW
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting_j.PlayerID
INNER JOIN z_j_batmax
ON z_j_batmax.PlayerID = Players.PlayerID
INNER JOIN batting_j_01_summary_ind 
ON batting_j_01_summary_ind.PlayerID = z_j_batmax.PlayerID
WHERE batting_j_01_summary_ind.Inn>0
GROUP BY players.player_name, batting_j_01_summary_ind.Inn-batting_j_01_summary_ind."NO"
;


--CREATE EXTENSION tablefunc;
create or replace view z_j_fow_ct as
select * from crosstab(
    'select inningsid, wicket, max(FOW)
    from batting_j
    group by inningsid, wicket
    order by inningsid, wicket',
    'select distinct wicket from batting_j where wicket between 1 and 10 order by wicket'
) as ct (inningsid int, "1" int, "2" int, "3" int, "4" int, "5" int, "6" int, "7" int, "8" int, "9" int, "10" int)
;


create or replace view z_j_bat_partnerships AS
SELECT 
    Batting_j.InningsID
    , Batting_j.PlayerID
    , Batting_j.not_out_batter
    , Batting_j.Wicket
    , CASE WHEN wicket=1 THEN batting_j.fow
        ELSE (CASE WHEN wicket=2  THEN z_j_fow_ct."2" - z_j_fow_ct."1"
        ELSE (CASE WHEN wicket=3  THEN z_j_fow_ct."3" - z_j_fow_ct."2"
        ELSE (CASE WHEN wicket=4  THEN z_j_fow_ct."4" - z_j_fow_ct."3"
        ELSE (CASE WHEN wicket=5  THEN z_j_fow_ct."5" - z_j_fow_ct."4"
        ELSE (CASE WHEN wicket=6  THEN z_j_fow_ct."6" - z_j_fow_ct."5"
        ELSE (CASE WHEN wicket=7  THEN z_j_fow_ct."7" - z_j_fow_ct."6"
        ELSE (CASE WHEN wicket=8  THEN z_j_fow_ct."8" - z_j_fow_ct."7"
        ELSE (CASE WHEN wicket=9  THEN z_j_fow_ct."9" - z_j_fow_ct."8"
        ELSE (CASE WHEN wicket=10 THEN z_j_fow_ct."10"- z_j_fow_ct."9" ELSE 0 END) END) END) END) END) END) END) END) END) END AS p
FROM Batting_j 
INNER JOIN z_j_fow_ct 
ON Batting_j.InningsID=z_j_fow_ct.InningsID
GROUP BY Batting_j.InningsID, Batting_j.PlayerID, Batting_j.not_out_batter, Batting_j.Wicket, p
HAVING (((Batting_j.not_out_batter) Is Not Null) AND ((Batting_j.Wicket) Is Not Null))
ORDER BY p desc, Batting_j.InningsID, Batting_j.Wicket;

create or replace view z_j_bat_part_max AS
SELECT z_j_bat_partnerships.Wicket, Max(z_j_bat_partnerships.p) AS MaxOfp, Seasons_j.Eleven
FROM Seasons_j INNER JOIN (Matches_j INNER JOIN (Players AS Players_1 INNER JOIN (Players INNER JOIN (z_j_bat_partnerships INNER JOIN Innings_j ON z_j_bat_partnerships.InningsID = Innings_j.InningsID) ON Players.PlayerID = z_j_bat_partnerships.PlayerID) ON Players_1.PlayerID = z_j_bat_partnerships.not_out_batter) ON Matches_j.MatchID = Innings_j.MatchID) ON Seasons_j.SeasonID = Matches_j.SeasonID
GROUP BY z_j_bat_partnerships.Wicket, Seasons_j.Eleven
ORDER BY eleven, z_j_bat_partnerships.Wicket, Max(z_j_bat_partnerships.p) DESC;

create or replace view z_j_bat_part_max_season AS
SELECT z_j_bat_partnerships.Wicket, Max(z_j_bat_partnerships.p) AS MaxOfp, Matches_j.SeasonID
FROM Matches_j INNER JOIN (Players AS Players_1 
INNER JOIN (Players INNER JOIN (z_j_bat_partnerships 
INNER JOIN Innings_j ON z_j_bat_partnerships.InningsID = Innings_j.InningsID) 
ON Players.PlayerID = z_j_bat_partnerships.PlayerID) 
ON Players_1.PlayerID = z_j_bat_partnerships.not_out_batter) ON Matches_j.MatchID = Innings_j.MatchID
GROUP BY z_j_bat_partnerships.Wicket, Matches_j.SeasonID
;



CREATE OR REPLACE VIEW z_j_batting_partnerships_highest AS
SELECT 
    z_j_bat_partnerships.p::varchar || (CASE WHEN lower(batting_j.how_out)='not out' And lower(batting_1.how_out)='not out' then '*' else '' end) AS Runs
    , z_j_bat_partnerships.Wicket
    , players.player_name AS "Player 1"
    , players_1.player_name AS "Player 2"
    , Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association, z_j_bat_partnerships.p
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j
ON Matches_j.MatchID = Innings_j.MatchID

INNER JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN Players 
on Players.PlayerID = Batting_j.PlayerID

INNER JOIN Batting_j AS Batting_1 
on Innings_j.InningsID = Batting_1.InningsID
INNER JOIN Players AS Players_1 
ON Batting_1.PlayerID = Players_1.PlayerID

INNER JOIN z_j_bat_partnerships 
ON z_j_bat_partnerships.InningsID = Innings_j.InningsID
AND Players.PlayerID = z_j_bat_partnerships.PlayerID
AND Players_1.PlayerID = z_j_bat_partnerships.not_out_batter
WHERE z_j_bat_partnerships.p >30
ORDER BY z_j_bat_partnerships.p DESC;


create or replace view z_j_player_season_matches AS
SELECT 
    players.player_name AS Name
    , Sum(CASE WHEN innings_j.inningsno=1 Or innings_j.inningsno=2 then 1 else 0 end) AS Mat
    , Players.PlayerID
    , Seasons_j.SeasonID
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID=Matches_j.SeasonID
INNER JOIN Innings_j
ON Matches_j.MatchID=Innings_j.MatchID
INNER JOIN Batting_j 
ON Innings_j.InningsID=Batting_j.InningsID
INNER JOIN Players 
ON Players.PlayerID=Batting_j.PlayerID
GROUP BY players.player_name, Players.PlayerID, Seasons_j.SeasonID
ORDER BY Sum(CASE WHEN innings_j.inningsno=1 Or innings_j.inningsno=2 then 1 else 0 end) DESC;


create or replace view z_j_player_matches_all AS
SELECT players.player_name AS Name
    , Sum(CASE WHEN innings_j.inningsno=1 Or innings_j.inningsno=2 then 1 else 0 end) AS Mat
    , batting_j_01_summary_ind.Debut
    , batting_j_01_summary_ind."Last Season"
    , Players.PlayerID
FROM Matches_j 
INNER JOIN (Innings_j 
INNER JOIN (batting_j_01_summary_ind 
INNER JOIN (Players 
INNER JOIN Batting_j ON Players.PlayerID = Batting_j.PlayerID) ON batting_j_01_summary_ind.PlayerID = Players.PlayerID) ON Innings_j.InningsID = 
Batting_j.InningsID) ON Matches_j.MatchID = Innings_j.MatchID
GROUP BY players.player_name, batting_j_01_summary_ind.Debut, batting_j_01_summary_ind."Last Season", Players.PlayerID
ORDER BY Sum((CASE WHEN innings_j.inningsno=1 Or innings_j.inningsno=2 then 1 else 0 end)) DESC;
;


create or replace view z_j_Bowling_Figures_All as
SELECT Count(wickets_j.playerid) ||'/'|| (CASE WHEN lower(Seasons_j.nbw_status)='true' THEN bowling_j.no_balls+bowling_j.wides+bowling_j.runs_off_bat ELSE bowling_j.runs_off_bat end) AS Figures
, Bowling_j.PlayerID
, Bowling_j.InningsID
, Count(Wickets_j.playerID) AS w
, Sum(CASE WHEN Wickets_j.batting_position > 1 then Wickets_j.batting_position-1 else 1 END) AS TBD
, (CASE WHEN lower(Seasons_j.nbw_status)='true' THEN bowling_j.no_balls+bowling_j.wides+bowling_j.runs_off_bat ELSE bowling_j.runs_off_bat END) AS runs
, Bowling_j.Overs AS Ov1
, Bowling_j.Extra_Balls
, Bowling_j.Maidens
, bowling_j.overs || (CASE WHEN bowling_j.extra_balls>0 THEN '.' || bowling_j.extra_balls else '' end) AS Ov
, Matches_j.MatchID
, Bowling_j.Wides
, Bowling_j.no_balls
, Seasons_j.SeasonID
FROM Seasons_j 
INNER JOIN (Matches_j INNER JOIN (Innings_j 
INNER JOIN (Wickets_j RIGHT JOIN Bowling_j ON (Wickets_j.playerID = Bowling_j.PlayerID) AND (Wickets_j.InningsID = Bowling_j.InningsID)) 
ON Innings_j.InningsID = Bowling_j.InningsID) ON Matches_j.MatchID = Innings_j.MatchID) ON Seasons_j.SeasonID = Matches_j.SeasonID
GROUP BY Bowling_j.PlayerID, Seasons_j.SeasonID, Bowling_j.InningsID, Bowling_j.Overs, Bowling_j.Extra_Balls, Bowling_j.Maidens, Matches_j.MatchID, bowling_j.no_balls, bowling_j.wides, bowling_j.runs_off_bat, seasons_j.nbw_status
ORDER BY w DESC, runs;


-- create or replace view z_j_Bowling_Figures as
-- SELECT 
--     z_j_Bowling_Figures_All.Figures
--     , z_j_Bowling_Figures_All.PlayerID
--     , Bowling_j.wickets
--     , z_j_Bowling_Figures_All.runs
--     , z_j_Bowling_Figures_All.InningsID
--     , z_j_Bowling_Figures_All.TBD
-- FROM z_j_Bowling_Figures_All
-- GROUP BY z_j_Bowling_Figures_All.Figures, z_j_Bowling_Figures_All.PlayerID, Bowling_j.wickets, z_j_Bowling_Figures_All.runs, z_j_Bowling_Figures_All.InningsID, z_j_Bowling_Figures_All.TBD
-- ORDER BY Bowling_j.wickets DESC , z_j_Bowling_Figures_All.runs;

--drop view z_j_Bowling_Career_5WI cascade;
create or replace view z_j_Bowling_Career_5WI AS
SELECT 
    Sum((CASE WHEN Bowling_j.wickets>4 then 1 else 0 end)) AS "5WI"
    , players.player_name AS Name
    , batting_j_01_summary_ind.Mat
    , z_j_Bowling_Figures_All.PlayerID
    , 6*Sum(z_j_Bowling_Figures_All.Ov1) + Sum(z_j_Bowling_Figures_All.extra_balls) as balls
FROM batting_j_01_summary_ind 
INNER JOIN (Players INNER JOIN z_j_Bowling_Figures_All ON Players.PlayerID = z_j_Bowling_Figures_All.PlayerID) ON batting_j_01_summary_ind.PlayerID = Players.PlayerID
GROUP BY players.player_name, batting_j_01_summary_ind.Mat, z_j_Bowling_Figures_All.PlayerID
ORDER BY "5WI" DESC;


-- create or replace view z_j_bbf_A AS
-- SELECT --Min(z_j_Bowling_Figures_All.OrderID) AS OrderID_min, 
--     z_j_Bowling_Figures_All.PlayerID
--     , z_j_Bowling_Career_5WI."5WI"
-- FROM z_j_Bowling_Figures_All 
-- INNER JOIN z_j_Bowling_Career_5WI ON z_j_Bowling_Figures_All.PlayerID = z_j_Bowling_Career_5WI.PlayerID
-- GROUP BY z_j_Bowling_Figures_All.PlayerID, z_j_Bowling_Career_5WI."5WI"
-- ORDER BY Min(z_j_Bowling_Figures_All.OrderID);


create or replace view z_j_bbf AS
select * from (
    SELECT 
        z_j_Bowling_Figures_All.PlayerID
        , z_j_Bowling_Figures_All.Figures
        , Sum((CASE WHEN Bowling_j.wickets>4 then 1 else 0 end)) over (partition by playerid) AS "5WI"
        , z_j_Bowling_Figures_All.InningsID
        , row_number() over (partition by playerid order by w desc, runs) as bowling_figures_rank
    FROM z_j_Bowling_Figures_All
) a
where bowling_figures_rank = 1
order by playerid
;

create or replace view z_j_bbf_season AS
select * from (
    SELECT 
        z_j_Bowling_Figures_All.PlayerID
        , z_j_Bowling_Figures_All.seasonid
        , z_j_Bowling_Figures_All.Figures
        , Sum((CASE WHEN Bowling_j.wickets>4 then 1 else 0 end)) over (partition by playerid) AS "5WI"
        , z_j_Bowling_Figures_All.InningsID
        , row_number() over (partition by playerid, seasonid order by w desc, runs) as bowling_figures_rank
    FROM z_j_Bowling_Figures_All
) a
where bowling_figures_rank = 1
;

select * from bowling_j limit 100

-- DROP VIEW z_j_bocsa CASCADE;
create or replace view z_j_bocsa AS
SELECT 
    Players.player_name AS Name
    , z_j_player_matches_all.Mat
    , floor((Sum(overs)*6+Sum(bowling_j.extra_balls))/6)::varchar || 
        CASE WHEN floor((Sum(overs)*6+Sum(bowling_j.extra_balls))/6)=(Sum(overs)*6+Sum(bowling_j.extra_balls))/6 THEN '' 
            ELSE '.' || Round(6*((Sum(overs)*6+Sum(bowling_j.extra_balls))/6-floor((Sum(overs)*6+Sum(bowling_j.extra_balls))/6))) END AS O
    , Sum(overs)*6+Sum(bowling_j.extra_balls) AS Balls
    , Sum(Bowling_j.Maidens) AS Mdns
    , Sum(z_j_Bowling_Figures_All.runs) AS "Total Runs"
    , Sum(Bowling_j.wickets) AS "Total Wickets"
    , CASE WHEN Sum(Bowling_j.wickets)=0 THEN -9 ELSE Sum(z_j_Bowling_Figures_All.runs)/Sum(Bowling_j.wickets) END AS Average
    , CASE WHEN Sum(Bowling_j.wickets)=0 THEN -9 ELSE (Sum(overs)*6+Sum(bowling_j.extra_balls))/Sum(Bowling_j.wickets) END AS "Strike Rate"
    , 6*(Sum(z_j_Bowling_Figures_All.runs))/(Sum(overs)*6+Sum(bowling_j.extra_balls)) AS RPO
    , CASE WHEN Sum(Bowling_j.wickets) > 0 then Sum(z_j_Bowling_Figures_All.tbd)/Sum(Bowling_j.wickets) ELSE -9 END AS ABD
    , Sum(Bowling_j._4s_against) AS _4s
    , Sum(Bowling_j._6s_against) AS _6s
    , z_j_bbf.Figures
    , z_j_bbf."5WI"
    , Max(Bowling_j.HighOver) AS "Expensive Over"
    , Players.PlayerID
FROM Matches_j 
INNER JOIN (Innings_j 
INNER JOIN (z_j_player_matches_all 
INNER JOIN (z_j_bbf RIGHT JOIN (z_j_Bowling_Figures_All RIGHT JOIN (Players INNER JOIN Bowling_j ON Players.PlayerID = Bowling_j.PlayerID) 
        ON (z_j_Bowling_Figures_All.InningsID = Bowling_j.InningsID) AND (z_j_Bowling_Figures_All.PlayerID = Bowling_j.PlayerID)) 
    ON z_j_bbf.PlayerID = Bowling_j.PlayerID) 
ON z_j_player_matches_all.PlayerID = Players.PlayerID) 
ON Innings_j.InningsID = Bowling_j.InningsID) 
ON Matches_j.MatchID = Innings_j.MatchID
GROUP BY Players.player_name, z_j_player_matches_all.Mat, z_j_bbf.Figures, z_j_bbf."5WI", Players.PlayerID, z_j_Bowling_Figures_All.PlayerID
ORDER BY Players.player_name, Sum(Bowling_j.wickets) DESC;
;


-- DROP VIEW z_j_bcsa CASCADE;
create or replace view z_j_bcsa AS
SELECT 
    z_j_player_matches_all.Name
    , z_j_player_matches_all.Mat
    , z_j_bocsa.O
    , z_j_bocsa.Balls
    , z_j_bocsa.Mdns
    , z_j_bocsa."Total Runs"
    , z_j_bocsa."Total Wickets"
    , z_j_bocsa.Average
    , z_j_bocsa."Strike Rate"
    , z_j_bocsa.RPO
    , z_j_bocsa.ABD
    , z_j_bocsa._4s
    , z_j_bocsa._6s
    , z_j_bocsa.Figures
    , z_j_bocsa."5WI"
    , z_j_bocsa."Expensive Over"
    , Sum(CASE WHEN lower(wickets_j.how_out) in ('caught','stumped') then 1 else 0 end) AS Dismissals
    , Sum(CASE WHEN lower(wickets_j.how_out)='caught' then 1 else 0 end) AS Catches
    , Sum(CASE WHEN lower(wickets_j.how_out)='stumped' then 1 else 0 end) AS Stumpings
    , Players.PlayerID
FROM (Players 
    LEFT JOIN Wickets_j 
    ON Players.PlayerID = Wickets_j.assist) 
INNER JOIN z_j_player_matches_all 
ON Players.PlayerID = z_j_player_matches_all.PlayerID
LEFT JOIN z_j_bocsa 
ON z_j_player_matches_all.Name = z_j_bocsa.Name
GROUP BY z_j_player_matches_all.Name, z_j_player_matches_all.Mat, z_j_bocsa.O, z_j_bocsa.Balls, z_j_bocsa.Mdns, z_j_bocsa."Total Runs", z_j_bocsa."Total Wickets", z_j_bocsa.Average, z_j_bocsa."Strike Rate", z_j_bocsa.RPO, z_j_bocsa.ABD, z_j_bocsa._4s, z_j_bocsa._6s, z_j_bocsa.Figures, z_j_bocsa."5WI", z_j_bocsa."Expensive Over", Players.PlayerID, z_j_player_matches_all.Mat
ORDER BY Dismissals DESC , catches DESC;

