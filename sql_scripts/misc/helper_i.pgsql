create or replace view z_i_all_player_dates AS
SELECT 
    players.surname ||', '|| players.firstname AS "Name"
    , Players.dob
    , Min(Matches_i.Date1) AS Debut
    , Players.PlayerID
    , Min(Seasons_i.Year) AS "First Season"
    , Max(Matches_i.Date1) AS "Final Game"
    , Max(Seasons_i.Year) AS "Last Season"
    , Count(Matches_i.MatchID) AS CountOfMatchID
FROM Seasons_i
INNER JOIN Matches_i
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN Innings_i 
ON Matches_i.MatchID = Innings_i.MatchID
INNER JOIN Batting_i
ON Innings_i.InningsID = Batting_i.InningsID
INNER JOIN Players
ON Players.PlayerID = Batting_i.PlayerID
GROUP BY players.surname ||', '|| players.firstname, Players.dob, Players.PlayerID;


create or replace view z_i_wickin AS
SELECT
    innings_i.inningsid
    , sum(case when lower(how_out) not in ('not out','retired hurt','retired not out','error','0','dnb') then 1 else 0 end) as num_wickets
FROM Innings_i 
INNER JOIN Wickets_i 
ON Innings_i.InningsID = Wickets_i.InningsID
GROUP BY Innings_i.InningsID;


create or replace view z_i_batmax_A AS
SELECT Batting_i.PlayerID, Max(Batting_i.Score) AS MaxOfScore
FROM Batting_i
GROUP BY Batting_i.PlayerID;


create or replace view z_i_batmax AS
SELECT z_i_batmax_A.PlayerID
    , Max(CASE WHEN lower(Batting_i.how_out) in ('not out','retired hurt','retired not out') then TO_CHAR(Batting_i.score,'999')||'*' else TO_CHAR(Batting_i.score,'999') end) AS HS
FROM z_i_batmax_A 
INNER JOIN Batting_i 
ON z_i_batmax_A.MaxOfScore = Batting_i.Score
AND z_i_batmax_A.PlayerID = Batting_i.PlayerID
GROUP BY z_i_batmax_A.PlayerID;

create or replace view z_i_batmax_season_A AS
SELECT Batting_i.PlayerID, Max(Batting_i.Score) AS MaxOfScore, seasons_i.seasonid
FROM Seasons_i INNER JOIN (Matches_i INNER JOIN (Innings_i INNER JOIN Batting_i ON Innings_i.InningsID = Batting_i.InningsID) ON Matches_i.MatchID = Innings_i.MatchID) ON Seasons_i.SeasonID = Matches_i.SeasonID
GROUP BY Batting_i.PlayerID, Seasons_i.SeasonID;

create or replace view z_i_batmax_season AS
SELECT z_i_batmax_season_A.PlayerID
    , Max(CASE WHEN lower(Batting_i.how_out) in ('not out','retired hurt','retired not out') then TO_CHAR(Batting_i.score,'999')||'*' else TO_CHAR(Batting_i.score,'999') end) AS HS
    , Seasons_i.SeasonID
FROM Matches_i INNER JOIN (Innings_i INNER JOIN (Seasons_i INNER JOIN (Batting_i INNER JOIN z_i_batmax_season_A ON (Batting_i.PlayerID = z_i_batmax_season_A.PlayerID) AND (Batting_i.Score = z_i_batmax_season_A.MaxOfScore)) ON Seasons_i.SeasonID = z_i_batmax_season_A.SeasonID) ON Innings_i.InningsID = Batting_i.InningsID) ON (Seasons_i.SeasonID = Matches_i.SeasonID) AND (Matches_i.MatchID = Innings_i.MatchID)
GROUP BY z_i_batmax_season_A.PlayerID, Seasons_i.SeasonID;



create or replace view z_i_batpos_max as
SELECT 
    seasons_i.eleven
    , Batting_i.batting_position
    , Max(Batting_i.Score) AS MaxOfScore
FROM Seasons_i INNER JOIN (Matches_i INNER JOIN (Innings_i INNER JOIN (Players INNER JOIN Batting_i ON Players.PlayerID = Batting_i.PlayerID) ON Innings_i.InningsID = Batting_i.InningsID) ON Matches_i.MatchID = Innings_i.MatchID) ON Seasons_i.SeasonID = Matches_i.SeasonID
where Batting_i.batting_position between 1 and 11
GROUP BY seasons_i.eleven, Batting_i.batting_position
;


create or replace view z_i_batting_totals AS
SELECT 
    case when b.num_wickets=10 then (b.bat_runs+i.extras)::varchar
        else concat(b.num_wickets,'/',(b.bat_runs+i.extras)) end as Score
    , i.Ov
    , b.bat_runs+i.extras as runs
    , num_wickets as wickets_i
    , i.inningsno
    , Matches_i.Opponent
    , Seasons_i.Year
    , Matches_i.Round
    , Seasons_i.Eleven
    , Seasons_i.Grade
    , Seasons_i.Association
    , matches_i.MatchID
FROM seasons_i 
INNER JOIN matches_i 
ON seasons_i.SeasonID = matches_i.SeasonID
INNER JOIN (
    SELECT
        MatchID
        , InningsID
        , inningsno
        , concat(Bat_Overs,'.',coalesce(extra_balls,'0')) as Ov
        , extras
    from Innings_i 
    where upper(Innings_Type) = 'BAT'
    and   Bat_Overs > 0
) i
ON Matches_i.MatchID = i.MatchID
INNER JOIN (
    SELECT inningsid
        , sum(score) as bat_runs
        , sum(case when lower(how_out) not in ('dnb','not out','retired','retired hurt','retired not out','forced retirement','0') then 1 else 0 end) as num_wickets
    FROM batting_i 
    group by inningsid
) b
ON i.InningsID = b.inningsid
;



create or replace view z_i_bowling_totals AS
SELECT  
    (CASE WHEN max(z_i_wickin.num_wickets)=10 then '' else max(z_i_wickin.num_wickets) ||'/' end) || Sum(Bowling_i.no_balls)+Sum(Bowling_i.Wides)+Sum(Bowling_i.runs_off_bat)+max(Innings_i.Extras) AS score
    , Sum(bowling_i.overs) ||'.'|| Sum(bowling_i.extra_balls) AS ov
    , 6*(Sum(Bowling_i.no_balls)+Sum(Bowling_i.Wides)+Sum(Bowling_i.runs_off_bat)+max(Innings_i.Extras))/Sum(6*bowling_i.overs+bowling_i.extra_balls) AS run_rate
    , Matches_i.Opponent
    , Sum(Bowling_i.no_balls)+Sum(Bowling_i.Wides)+Sum(Bowling_i.runs_off_bat)+max(Innings_i.Extras) AS runs
    , Matches_i.MatchID
    , Innings_i.InningsNO
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID=Matches_i.SeasonID
INNER JOIN Innings_i
ON Matches_i.MatchID=Innings_i.MatchID
INNER JOIN z_i_wickin 
ON Innings_i.InningsID=z_i_wickin.InningsID
INNER JOIN Bowling_i 
ON Innings_i.InningsID=Bowling_i.InningsID

GROUP BY Matches_i.Opponent, Innings_i.InningsID, Matches_i.MatchID, Innings_i.InningsNO
HAVING Innings_i.InningsNO in (1,2)
ORDER BY Sum(Bowling_i.no_balls)+Sum(Bowling_i.Wides)+Sum(Bowling_i.runs_off_bat)+max(Innings_i.Extras) DESC;

create or replace view z_i_bat_ind_dismissal_types AS
SELECT 
    players.player_name AS Name
    , batting_i_01_summary_ind.Inn-batting_i_01_summary_ind."NO" AS dismissals
    , Sum(CASE WHEN lower(batting_i.how_out)<>'not out' And batting_i.score=0 then 1 else 0 end) AS Ducks
    , Sum(CASE WHEN lower(batting_i.how_out)='lbw' then 1 else 0 end) AS LBW
    , Sum(CASE WHEN lower(batting_i.how_out)='caught' then 1 else 0 end) AS C
    , Sum(CASE WHEN lower(batting_i.how_out)='bowled' then 1 else 0 end) AS B
    , Sum(CASE WHEN lower(batting_i.how_out)='stumped' then 1 else 0 end) AS ST
    , Sum(CASE WHEN lower(batting_i.how_out)='run out' then 1 else 0 end) AS RO
    , Sum(CASE WHEN lower(batting_i.how_out)='retired' then 1 else 0 end) AS Retired
    , Sum(CASE WHEN lower(batting_i.how_out)='hit wicket' then 1 else 0 end) AS HW
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN Innings_i 
ON Matches_i.MatchID = Innings_i.MatchID
INNER JOIN Batting_i 
ON Innings_i.InningsID = Batting_i.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting_i.PlayerID
INNER JOIN z_i_batmax
ON z_i_batmax.PlayerID = Players.PlayerID
INNER JOIN batting_i_01_summary_ind 
ON batting_i_01_summary_ind.PlayerID = z_i_batmax.PlayerID
WHERE batting_i_01_summary_ind.Inn>0
GROUP BY players.player_name, batting_i_01_summary_ind.Inn-batting_i_01_summary_ind."NO"
;


--CREATE EXTENSION tablefunc;
create or replace view z_i_fow_ct as
select * from crosstab(
    'select inningsid, wicket, max(FOW)
    from batting_i
    group by inningsid, wicket
    order by inningsid, wicket',
    'select distinct wicket from batting_i where wicket between 1 and 10 order by wicket'
) as ct (inningsid int, "1" int, "2" int, "3" int, "4" int, "5" int, "6" int, "7" int, "8" int, "9" int, "10" int)
;


create or replace view z_i_bat_partnerships AS
SELECT 
    Batting_i.InningsID
    , Batting_i.PlayerID
    , Batting_i.not_out_batter
    , Batting_i.Wicket
    , CASE WHEN wicket=1 THEN batting_i.fow
        ELSE (CASE WHEN wicket=2  THEN z_i_fow_ct."2" - z_i_fow_ct."1"
        ELSE (CASE WHEN wicket=3  THEN z_i_fow_ct."3" - z_i_fow_ct."2"
        ELSE (CASE WHEN wicket=4  THEN z_i_fow_ct."4" - z_i_fow_ct."3"
        ELSE (CASE WHEN wicket=5  THEN z_i_fow_ct."5" - z_i_fow_ct."4"
        ELSE (CASE WHEN wicket=6  THEN z_i_fow_ct."6" - z_i_fow_ct."5"
        ELSE (CASE WHEN wicket=7  THEN z_i_fow_ct."7" - z_i_fow_ct."6"
        ELSE (CASE WHEN wicket=8  THEN z_i_fow_ct."8" - z_i_fow_ct."7"
        ELSE (CASE WHEN wicket=9  THEN z_i_fow_ct."9" - z_i_fow_ct."8"
        ELSE (CASE WHEN wicket=10 THEN z_i_fow_ct."10"- z_i_fow_ct."9" ELSE 0 END) END) END) END) END) END) END) END) END) END AS p
FROM Batting_i 
INNER JOIN z_i_fow_ct 
ON Batting_i.InningsID=z_i_fow_ct.InningsID
GROUP BY Batting_i.InningsID, Batting_i.PlayerID, Batting_i.not_out_batter, Batting_i.Wicket, p
HAVING (((Batting_i.not_out_batter) Is Not Null) AND ((Batting_i.Wicket) Is Not Null))
ORDER BY p desc, Batting_i.InningsID, Batting_i.Wicket;

create or replace view z_i_bat_part_max AS
SELECT z_i_bat_partnerships.Wicket, Max(z_i_bat_partnerships.p) AS MaxOfp, Seasons_i.Eleven
FROM Seasons_i INNER JOIN (Matches_i INNER JOIN (Players AS Players_1 INNER JOIN (Players INNER JOIN (z_i_bat_partnerships INNER JOIN Innings_i ON z_i_bat_partnerships.InningsID = Innings_i.InningsID) ON Players.PlayerID = z_i_bat_partnerships.PlayerID) ON Players_1.PlayerID = z_i_bat_partnerships.not_out_batter) ON Matches_i.MatchID = Innings_i.MatchID) ON Seasons_i.SeasonID = Matches_i.SeasonID
GROUP BY z_i_bat_partnerships.Wicket, Seasons_i.Eleven
ORDER BY eleven, z_i_bat_partnerships.Wicket, Max(z_i_bat_partnerships.p) DESC;

create or replace view z_i_bat_part_max_season AS
SELECT z_i_bat_partnerships.Wicket, Max(z_i_bat_partnerships.p) AS MaxOfp, Matches_i.SeasonID
FROM Matches_i INNER JOIN (Players AS Players_1 
INNER JOIN (Players INNER JOIN (z_i_bat_partnerships 
INNER JOIN Innings_i ON z_i_bat_partnerships.InningsID = Innings_i.InningsID) 
ON Players.PlayerID = z_i_bat_partnerships.PlayerID) 
ON Players_1.PlayerID = z_i_bat_partnerships.not_out_batter) ON Matches_i.MatchID = Innings_i.MatchID
GROUP BY z_i_bat_partnerships.Wicket, Matches_i.SeasonID
;



CREATE OR REPLACE VIEW z_i_batting_partnerships_highest AS
SELECT 
    z_i_bat_partnerships.p::varchar || (CASE WHEN lower(batting_i.how_out)='not out' And lower(batting_1.how_out)='not out' then '*' else '' end) AS Runs
    , z_i_bat_partnerships.Wicket
    , players.player_name AS "Player 1"
    , players_1.player_name AS "Player 2"
    , Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Seasons_i.Association, z_i_bat_partnerships.p
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN Innings_i
ON Matches_i.MatchID = Innings_i.MatchID

INNER JOIN Batting_i 
ON Innings_i.InningsID = Batting_i.InningsID
INNER JOIN Players 
on Players.PlayerID = Batting_i.PlayerID

INNER JOIN Batting_i AS Batting_1 
on Innings_i.InningsID = Batting_1.InningsID
INNER JOIN Players AS Players_1 
ON Batting_1.PlayerID = Players_1.PlayerID

INNER JOIN z_i_bat_partnerships 
ON z_i_bat_partnerships.InningsID = Innings_i.InningsID
AND Players.PlayerID = z_i_bat_partnerships.PlayerID
AND Players_1.PlayerID = z_i_bat_partnerships.not_out_batter
WHERE z_i_bat_partnerships.p >30
ORDER BY z_i_bat_partnerships.p DESC;


create or replace view z_i_player_season_matches AS
SELECT 
    players.player_name AS Name
    , Sum(CASE WHEN innings_i.inningsno=1 Or innings_i.inningsno=2 then 1 else 0 end) AS Mat
    , Players.PlayerID
    , Seasons_i.SeasonID
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID=Matches_i.SeasonID
INNER JOIN Innings_i
ON Matches_i.MatchID=Innings_i.MatchID
INNER JOIN Batting_i 
ON Innings_i.InningsID=Batting_i.InningsID
INNER JOIN Players 
ON Players.PlayerID=Batting_i.PlayerID
GROUP BY players.player_name, Players.PlayerID, Seasons_i.SeasonID
ORDER BY Sum(CASE WHEN innings_i.inningsno=1 Or innings_i.inningsno=2 then 1 else 0 end) DESC;


create or replace view z_i_player_matches_all AS
SELECT players.player_name AS Name
    , Sum(CASE WHEN innings_i.inningsno=1 Or innings_i.inningsno=2 then 1 else 0 end) AS Mat
    , batting_i_01_summary_ind.Debut
    , batting_i_01_summary_ind."Last Season"
    , Players.PlayerID
FROM Matches_i 
INNER JOIN (Innings_i 
INNER JOIN (batting_i_01_summary_ind 
INNER JOIN (Players 
INNER JOIN Batting_i ON Players.PlayerID = Batting_i.PlayerID) ON batting_i_01_summary_ind.PlayerID = Players.PlayerID) ON Innings_i.InningsID = 
Batting_i.InningsID) ON Matches_i.MatchID = Innings_i.MatchID
GROUP BY players.player_name, batting_i_01_summary_ind.Debut, batting_i_01_summary_ind."Last Season", Players.PlayerID
ORDER BY Sum((CASE WHEN innings_i.inningsno=1 Or innings_i.inningsno=2 then 1 else 0 end)) DESC;
;


create or replace view z_i_Bowling_Figures_All as
SELECT Count(wickets_i.playerid) ||'/'|| (CASE WHEN lower(Seasons_i.nbw_status)='true' THEN bowling_i.no_balls+bowling_i.wides+bowling_i.runs_off_bat ELSE bowling_i.runs_off_bat end) AS Figures
, Bowling_i.PlayerID
, Bowling_i.InningsID
, Count(Wickets_i.playerID) AS w
, Sum(CASE WHEN Wickets_i.batting_position > 1 then Wickets_i.batting_position-1 else 1 END) AS TBD
, (CASE WHEN lower(Seasons_i.nbw_status)='true' THEN bowling_i.no_balls+bowling_i.wides+bowling_i.runs_off_bat ELSE bowling_i.runs_off_bat END) AS runs
, Bowling_i.Overs AS Ov1
, Bowling_i.Extra_Balls
, Bowling_i.Maidens
, bowling_i.overs || (CASE WHEN bowling_i.extra_balls>0 THEN '.' || bowling_i.extra_balls else '' end) AS Ov
, Matches_i.MatchID
, Bowling_i.Wides
, Bowling_i.no_balls
, Seasons_i.SeasonID
FROM Seasons_i 
INNER JOIN (Matches_i INNER JOIN (Innings_i 
INNER JOIN (Wickets_i RIGHT JOIN Bowling_i ON (Wickets_i.playerID = Bowling_i.PlayerID) AND (Wickets_i.InningsID = Bowling_i.InningsID)) 
ON Innings_i.InningsID = Bowling_i.InningsID) ON Matches_i.MatchID = Innings_i.MatchID) ON Seasons_i.SeasonID = Matches_i.SeasonID
GROUP BY Bowling_i.PlayerID, Seasons_i.SeasonID, Bowling_i.InningsID, Bowling_i.Overs, Bowling_i.Extra_Balls, Bowling_i.Maidens, Matches_i.MatchID, bowling_i.no_balls, bowling_i.wides, bowling_i.runs_off_bat, seasons_i.nbw_status
ORDER BY w DESC, runs;




--drop view z_i_Bowling_Career_5WI cascade;
create or replace view z_i_Bowling_Career_5WI AS
SELECT 
    Sum((CASE WHEN z_i_Bowling_Figures_All.w>4 then 1 else 0 end)) AS "5WI"
    , players.player_name AS Name
    , batting_i_01_summary_ind.Mat
    , z_i_Bowling_Figures_All.PlayerID
    , 6*Sum(z_i_Bowling_Figures_All.Ov1) + Sum(z_i_Bowling_Figures_All.extra_balls) as balls
FROM batting_i_01_summary_ind 
INNER JOIN (Players INNER JOIN z_i_Bowling_Figures_All ON Players.PlayerID = z_i_Bowling_Figures_All.PlayerID) ON batting_i_01_summary_ind.PlayerID = Players.PlayerID
GROUP BY players.player_name, batting_i_01_summary_ind.Mat, z_i_Bowling_Figures_All.PlayerID
ORDER BY "5WI" DESC;


-- create or replace view z_i_bbf_A AS
-- SELECT --Min(z_i_Bowling_Figures_All.OrderID) AS OrderID_min, 
--     z_i_Bowling_Figures_All.PlayerID
--     , z_i_Bowling_Career_5WI."5WI"
-- FROM z_i_Bowling_Figures_All 
-- INNER JOIN z_i_Bowling_Career_5WI ON z_i_Bowling_Figures_All.PlayerID = z_i_Bowling_Career_5WI.PlayerID
-- GROUP BY z_i_Bowling_Figures_All.PlayerID, z_i_Bowling_Career_5WI."5WI"
-- ORDER BY Min(z_i_Bowling_Figures_All.OrderID);


create or replace view z_i_bbf AS
select * from (
    SELECT 
        z_i_Bowling_Figures_All.PlayerID
        , z_i_Bowling_Figures_All.Figures
        , Sum((CASE WHEN z_i_Bowling_Figures_All.w>4 then 1 else 0 end)) over (partition by playerid) AS "5WI"
        , z_i_Bowling_Figures_All.InningsID
        , row_number() over (partition by playerid order by w desc, runs) as bowling_figures_rank
    FROM z_i_Bowling_Figures_All
) a
where bowling_figures_rank = 1
order by playerid
;

create or replace view z_i_bbf_season AS
select * from (
    SELECT 
        z_i_Bowling_Figures_All.PlayerID
        , z_i_Bowling_Figures_All.seasonid
        , z_i_Bowling_Figures_All.Figures
        , Sum((CASE WHEN z_i_Bowling_Figures_All.w>4 then 1 else 0 end)) over (partition by playerid) AS "5WI"
        , z_i_Bowling_Figures_All.InningsID
        , row_number() over (partition by playerid, seasonid order by w desc, runs) as bowling_figures_rank
    FROM z_i_Bowling_Figures_All
) a
where bowling_figures_rank = 1
;


create or replace view z_i_bocsa AS
SELECT 
    Players.player_name AS Name
    , z_i_player_matches_all.Mat
    , floor((Sum(overs)*6+Sum(bowling_i.extra_balls))/6)::varchar || 
        CASE WHEN floor((Sum(overs)*6+Sum(bowling_i.extra_balls))/6)=(Sum(overs)*6+Sum(bowling_i.extra_balls))/6 THEN '' 
            ELSE '.' || Round(6*((Sum(overs)*6+Sum(bowling_i.extra_balls))/6-floor((Sum(overs)*6+Sum(bowling_i.extra_balls))/6))) END AS O
    , Sum(overs)*6+Sum(bowling_i.extra_balls) AS Balls
    , Sum(Bowling_i.Maidens) AS Mdns
    , Sum(z_i_Bowling_Figures_All.runs) AS "Total Runs"
    , Sum(z_i_Bowling_Figures_All.w) AS "Total Wickets_i"
    , CASE WHEN Sum(z_i_Bowling_Figures_All.w)=0 THEN -9 ELSE Sum(z_i_Bowling_Figures_All.runs)/Sum(z_i_Bowling_Figures_All.w) END AS Average
    , CASE WHEN Sum(z_i_Bowling_Figures_All.w)=0 THEN -9 ELSE (Sum(overs)*6+Sum(bowling_i.extra_balls))/Sum(z_i_Bowling_Figures_All.w) END AS "Strike Rate"
    , 6*(Sum(z_i_Bowling_Figures_All.runs))/(Sum(overs)*6+Sum(bowling_i.extra_balls)) AS RPO
    , CASE WHEN Sum(z_i_Bowling_Figures_All.w) > 0 then Sum(z_i_Bowling_Figures_All.tbd)/Sum(z_i_Bowling_Figures_All.w) ELSE -9 END AS ABD
    , Sum(Bowling_i._4s_against) AS _4s
    , Sum(Bowling_i._6s_against) AS _6s
    , z_i_bbf.Figures
    , z_i_bbf."5WI"
    , Max(Bowling_i.HighOver) AS "Expensive Over"
    , Players.PlayerID
FROM Matches_i 
INNER JOIN (Innings_i 
INNER JOIN (z_i_player_matches_all 
INNER JOIN (z_i_bbf RIGHT JOIN (z_i_Bowling_Figures_All RIGHT JOIN (Players INNER JOIN Bowling_i ON Players.PlayerID = Bowling_i.PlayerID) 
        ON (z_i_Bowling_Figures_All.InningsID = Bowling_i.InningsID) AND (z_i_Bowling_Figures_All.PlayerID = Bowling_i.PlayerID)) 
    ON z_i_bbf.PlayerID = Bowling_i.PlayerID) 
ON z_i_player_matches_all.PlayerID = Players.PlayerID) 
ON Innings_i.InningsID = Bowling_i.InningsID) 
ON Matches_i.MatchID = Innings_i.MatchID
GROUP BY Players.player_name, z_i_player_matches_all.Mat, z_i_bbf.Figures, z_i_bbf."5WI", Players.PlayerID, z_i_Bowling_Figures_All.PlayerID
ORDER BY Players.player_name, Sum(z_i_Bowling_Figures_All.w) DESC;
;




create or replace view z_i_bcsa AS
SELECT 
    z_i_player_matches_all.Name
    , z_i_player_matches_all.Mat
    , z_i_bocsa.O
    , z_i_bocsa.Balls
    , z_i_bocsa.Mdns
    , z_i_bocsa."Total Runs"
    , z_i_bocsa."Total Wickets_i"
    , z_i_bocsa.Average
    , z_i_bocsa."Strike Rate"
    , z_i_bocsa.RPO
    , z_i_bocsa.ABD
    , z_i_bocsa._4s
    , z_i_bocsa._6s
    , z_i_bocsa.Figures
    , z_i_bocsa."5WI"
    , z_i_bocsa."Expensive Over"
    , Sum(CASE WHEN lower(wickets_i.how_out) in ('caught','stumped') then 1 else 0 end) AS Dismissals
    , Sum(CASE WHEN lower(wickets_i.how_out)='caught' then 1 else 0 end) AS Catches
    , Sum(CASE WHEN lower(wickets_i.how_out)='stumped' then 1 else 0 end) AS Stumpings
    , Players.PlayerID
FROM (Players 
    LEFT JOIN Wickets_i 
    ON Players.PlayerID = Wickets_i.assist) 
INNER JOIN z_i_player_matches_all 
ON Players.PlayerID = z_i_player_matches_all.PlayerID
LEFT JOIN z_i_bocsa 
ON z_i_player_matches_all.Name = z_i_bocsa.Name
GROUP BY z_i_player_matches_all.Name, z_i_player_matches_all.Mat, z_i_bocsa.O, z_i_bocsa.Balls, z_i_bocsa.Mdns, z_i_bocsa."Total Runs", z_i_bocsa."Total Wickets_i", z_i_bocsa.Average, z_i_bocsa."Strike Rate", z_i_bocsa.RPO, z_i_bocsa.ABD, z_i_bocsa._4s, z_i_bocsa._6s, z_i_bocsa.Figures, z_i_bocsa."5WI", z_i_bocsa."Expensive Over", Players.PlayerID, z_i_player_matches_all.Mat
ORDER BY Dismissals DESC , catches DESC;

