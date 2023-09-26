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