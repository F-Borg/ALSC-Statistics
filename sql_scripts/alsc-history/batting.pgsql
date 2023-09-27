CREATE OR REPLACE VIEW batting_01_summary_ind AS
SELECT 
    players.Surname ||', '|| players.firstname AS Name
    --, Players.Real playerid AS Real ID
    , z_all_player_dates."First Season" AS Debut
    , z_all_player_dates."Last Season"
    , Sum(CASE WHEN innings.inningsno=1 Or innings.inningsno=2 then 1 else 0 end) AS Mat
    , Count(Batting.Batting_Position) AS Inn
    , Sum(CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then 1 else 0 end) AS "NO"
    , Sum(CASE WHEN lower(batting.how_out)<>'not out' And batting.score=0 then 1 else 0 end) AS Ducks
    , Sum(Batting._4s) AS Fours
    , Sum(Batting._6s) AS Sixes
    , Sum(CASE WHEN batting.score Between 50 And 99 then 1 else 0 end) AS Fifties
    , Sum(CASE WHEN batting.score>99 then 1 else 0 end) AS Hundreds
    , z_batmax.HS
    , Sum(Batting.Score) AS Total
    , CASE WHEN Count(Batting.Score)-Sum(CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then 1 else 0 end)=0 then -9 
        else Sum(Batting.Score)/(Count(Batting.Score)-Sum(CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then 1 else 0 end)) end AS "Average"
    , Sum(batting.balls_faced) AS BF
    , CASE WHEN Count(Batting.Score)-Sum(CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then 1 else 0 end)=0 then -9
        else Sum(Batting.balls_faced)/(Count(Batting.Score)-Sum(CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then 1 else 0 end)) end AS "Average BF"
    , case when Sum(batting.balls_faced)>0 then 100*Sum(batting.score)/Sum(batting.balls_faced) else null end AS "Runs/100 Balls"
    , 100*(Sum(batting._4s)*4+Sum(batting._6s)*6)/(CASE WHEN Sum(batting.score)=0 then 1 else Sum(batting.score) end) AS "Pct Runs in Boundaries"
    , Players.playerid
FROM Matches 
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
RIGHT JOIN Players 
ON Players.playerid = Batting.playerid
INNER JOIN z_all_player_dates 
ON z_all_player_dates.playerid = Players.playerid
INNER JOIN z_batmax 
ON z_batmax.playerid = Players.playerid

GROUP BY players.Surname ||', '|| players.firstname
    , z_all_player_dates."First Season"
    , z_all_player_dates."Last Season"
    , z_batmax.HS
    , Players.playerid
HAVING (((Players.playerid)<>999))
ORDER BY players.Surname ||', '|| players.firstname, Sum(Batting.Score) DESC;



CREATE OR REPLACE VIEW batting_02_career_runs AS 
SELECT batting_01_summary_ind.Total AS Runs, batting_01_summary_ind.Name, batting_01_summary_ind.Inn, batting_01_summary_ind."Average"
FROM batting_01_summary_ind
GROUP BY batting_01_summary_ind.Total, batting_01_summary_ind.Name, batting_01_summary_ind.Inn, batting_01_summary_ind."Average"
HAVING (((batting_01_summary_ind.Total)>100))
ORDER BY batting_01_summary_ind.Total DESC
;


CREATE OR REPLACE VIEW batting_03_career_ave AS 
SELECT batting_01_summary_ind."Average", batting_01_summary_ind.Name, batting_01_summary_ind.Total AS Runs, batting_01_summary_ind.Inn
FROM batting_01_summary_ind
GROUP BY batting_01_summary_ind."Average", batting_01_summary_ind.Name, batting_01_summary_ind.Total, batting_01_summary_ind.Inn
HAVING (((batting_01_summary_ind.Total)>199))
ORDER BY batting_01_summary_ind."Average" DESC
;


CREATE OR REPLACE VIEW batting_04_career_sr_high AS 
SELECT batting_01_summary_ind."Runs/100 Balls", batting_01_summary_ind.Name, batting_01_summary_ind.Total, batting_01_summary_ind.BF
FROM batting_01_summary_ind
WHERE (((batting_01_summary_ind.Total)>99))
ORDER BY batting_01_summary_ind."Runs/100 Balls" DESC;


CREATE OR REPLACE VIEW batting_05_career_sr_low AS 
SELECT batting_01_summary_ind."Runs/100 Balls", batting_01_summary_ind.Name, batting_01_summary_ind.Total AS Runs, batting_01_summary_ind.BF
FROM batting_01_summary_ind
WHERE (((batting_01_summary_ind.BF)>99))
ORDER BY batting_01_summary_ind."Runs/100 Balls";


CREATE OR REPLACE VIEW batting_06_milestones_100 AS 
SELECT batting_01_summary_ind.Name, batting_01_summary_ind.Hundreds, batting_01_summary_ind.Inn, 100*batting_01_summary_ind.Hundreds::float/batting_01_summary_ind.Inn AS "Percentage 100s"
FROM batting_01_summary_ind
GROUP BY batting_01_summary_ind.Name, batting_01_summary_ind.Hundreds, batting_01_summary_ind.Inn
HAVING (((batting_01_summary_ind.Hundreds)>0))
ORDER BY batting_01_summary_ind.Hundreds DESC , batting_01_summary_ind.Hundreds/batting_01_summary_ind.Inn DESC;


CREATE OR REPLACE VIEW batting_07_milestones_50 AS 
SELECT batting_01_summary_ind.Name, batting_01_summary_ind.Fifties, batting_01_summary_ind.Inn, 100*batting_01_summary_ind.Fifties::float/batting_01_summary_ind.Inn AS "Percentage 50s"
FROM batting_01_summary_ind
GROUP BY batting_01_summary_ind.Name, batting_01_summary_ind.Fifties, batting_01_summary_ind.Inn
HAVING (((batting_01_summary_ind.Fifties)>0))
ORDER BY batting_01_summary_ind.Fifties DESC , batting_01_summary_ind.Fifties/batting_01_summary_ind.Inn DESC;


CREATE OR REPLACE VIEW batting_08_milestones_ducks AS 
SELECT batting_01_summary_ind.Name, batting_01_summary_ind.Ducks, batting_01_summary_ind.Inn, 100*batting_01_summary_ind.ducks::float/batting_01_summary_ind.inn AS "Percentage Ducks"
FROM batting_01_summary_ind
WHERE (((batting_01_summary_ind.Ducks)>0))
ORDER BY batting_01_summary_ind.Ducks DESC , batting_01_summary_ind.Inn;

CREATE OR REPLACE VIEW batting_09_milestones_runs_season AS 
SELECT 
    players.player_name AS Name
    , coalesce(Sum(Batting.Score),0) AS Runs
    , z_player_season_matches.Mat
    , CASE WHEN Count(Batting.Score)-Sum(CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then 1 else 0 end)=0
        THEN -9 ELSE Sum(Batting.Score)::float/(Count(Batting.Score)-Sum(CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then 1 else 0 end)) END AS Average
    , Seasons.Year
    , Seasons.Eleven
    , Seasons.Association
    , Seasons.Grade
FROM Seasons
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting 
ON Innings.InningsID = Batting.InningsID
INNER JOIN players
ON Players.PlayerID = Batting.PlayerID
INNER JOIN z_player_season_matches
ON z_player_season_matches.PlayerID = Players.PlayerID
AND Seasons.SeasonID = z_player_season_matches.SeasonID
GROUP BY players.player_name, z_player_season_matches.Mat, Seasons.Year, Seasons.Eleven, Seasons.Association, Seasons.Grade
ORDER BY Runs DESC;


CREATE OR REPLACE VIEW batting_10_high_score_ind AS 
SELECT players.player_name AS Name
    , batting.score::varchar || (CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then '*' else '' end) AS Score
    , Batting.balls_faced, Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting.PlayerID
where batting.score > 0
ORDER BY Batting.Score DESC, (CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then 1 else 0 end) desc;


CREATE OR REPLACE VIEW batting_11_high_score_sixes AS 
SELECT 
    players.player_name AS Name
    , Batting._6s
    , batting.score::varchar || (CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then '*' else '' end) AS Score
    , Batting.balls_faced
    , Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting.PlayerID
where batting._6s > 0
ORDER BY Batting._6s DESC;


CREATE OR REPLACE VIEW batting_12_score_by_posn_1stXI AS
SELECT 
    Batting.batting_position
    , z_batpos_max.MaxOfScore
    , Batting.balls_faced
    , players.player_name AS Batter, Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting.PlayerID
INNER JOIN z_batpos_max
ON Batting.batting_position = z_batpos_max.batting_position
AND Batting.Score = z_batpos_max.MaxOfScore
where z_batpos_max.eleven = '1st'
and seasons.eleven = '1st'
ORDER BY Batting.batting_position;


CREATE OR REPLACE VIEW batting_13_score_by_posn_2ndXI AS 
SELECT 
    Batting.batting_position
    , z_batpos_max.MaxOfScore
    , Batting.balls_faced
    , players.player_name AS Batter, Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting.PlayerID
INNER JOIN z_batpos_max
ON Batting.batting_position = z_batpos_max.batting_position
AND Batting.Score = z_batpos_max.MaxOfScore
where z_batpos_max.eleven = '2nd'
and seasons.eleven = '2nd'
ORDER BY Batting.batting_position;


CREATE OR REPLACE VIEW batting_14_score_by_posn_3rdXI AS 
SELECT 
    Batting.batting_position
    , z_batpos_max.MaxOfScore
    , Batting.balls_faced
    , players.player_name AS Batter, Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting.PlayerID
INNER JOIN z_batpos_max
ON Batting.batting_position = z_batpos_max.batting_position
AND Batting.Score = z_batpos_max.MaxOfScore
where z_batpos_max.eleven = '3rd'
and seasons.eleven = '3rd'
ORDER BY Batting.batting_position;


CREATE OR REPLACE VIEW batting_15_fast_slow_longest AS
SELECT players.player_name AS Name
, Batting.balls_faced
, batting.score::varchar || (CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then '*' else '' end) AS Score
, Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting.PlayerID
where Batting.balls_faced > 0
ORDER BY Batting.balls_faced DESC , Batting.Score DESC;


CREATE OR REPLACE VIEW batting_16_fast_slow_fastest AS
SELECT 
    Players.player_name AS Name
    , 100*batting.score::float/batting.balls_faced AS "Strike Rate"
    , batting.score::varchar || (CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then '*' else '' end) AS Runs
    , Batting.balls_faced
    , Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting.PlayerID
WHERE Batting.Score > 29
and Batting.balls_faced > 0
ORDER BY "Strike Rate" DESC;

CREATE OR REPLACE VIEW batting_17_fast_slow_slowest AS
SELECT 
    Players.player_name AS Name
    , 100*batting.score::float/batting.balls_faced AS "Strike Rate"
    , batting.score::varchar || (CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then '*' else '' end) AS Runs
    , Batting.balls_faced
    , Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting.PlayerID
WHERE Batting.balls_faced > 59
ORDER BY "Strike Rate";


CREATE OR REPLACE VIEW batting_18_dismissals_ct AS
SELECT Name, C::float/dismissals AS percentage, dismissals, C as caught
FROM z_bat_ind_dismissal_types
WHERE dismissals > 9
ORDER BY percentage DESC , dismissals DESC;


CREATE OR REPLACE VIEW batting_19_dismissals_b AS
SELECT Name, B::float/dismissals AS percentage, dismissals, B as bowled
FROM z_bat_ind_dismissal_types
WHERE dismissals > 9
ORDER BY percentage DESC , dismissals DESC;


CREATE OR REPLACE VIEW batting_20_dismissals_lbw AS
SELECT Name, LBW::float/dismissals AS percentage, dismissals, LBW
FROM z_bat_ind_dismissal_types
WHERE dismissals > 9
ORDER BY percentage DESC , dismissals DESC;

CREATE OR REPLACE VIEW batting_21_dismissals_no_lbw AS
SELECT dismissals, Name
FROM z_bat_ind_dismissal_types
WHERE LBW = 0
ORDER BY dismissals DESC;

CREATE OR REPLACE VIEW batting_22_dismissals_st AS
SELECT ST as stumpings, Name
FROM z_bat_ind_dismissal_types
WHERE dismissals > 0
ORDER BY stumpings DESC;


CREATE OR REPLACE VIEW batting_23_partnerships_highest AS
SELECT 
    Runs
    , Wicket
    , "Player 1"
    , "Player 2"
    , Opponent, Year, Round, Eleven, Grade, Association
FROM z_batting_partnerships_highest 
ORDER BY p DESC;


-- change from overall to 1st XI
CREATE OR REPLACE VIEW batting_24_partnerships_wicket_1stXI AS
SELECT 
    a.Runs
    , a.Wicket
    , a."Player 1"
    , a."Player 2"
    , a.Opponent, a.Year, a.Round, a.Eleven, a.Grade, a.Association
FROM z_batting_partnerships_highest a
INNER JOIN (
    SELECT wicket
        , max(p) as p
    FROM z_batting_partnerships_highest
    where eleven = '1st'
    group by wicket
) max_part
on a.p = max_part.p
and a.wicket = max_part.wicket
WHERE a.eleven = '1st'
order by a.wicket
;


CREATE OR REPLACE VIEW batting_25_partnerships_wicket_2ndXI AS
SELECT 
    a.Runs
    , a.Wicket
    , a."Player 1"
    , a."Player 2"
    , a.Opponent, a.Year, a.Round, a.Eleven, a.Grade, a.Association
FROM z_batting_partnerships_highest a
INNER JOIN (
    SELECT wicket
        , max(p) as p
    FROM z_batting_partnerships_highest
    where eleven = '2nd'
    group by wicket
) max_part
on a.p = max_part.p
and a.wicket = max_part.wicket
WHERE a.eleven = '2nd'
order by a.wicket


CREATE OR REPLACE VIEW batting_26_partnerships_wicket_3rdXI AS
SELECT 
    a.Runs
    , a.Wicket
    , a."Player 1"
    , a."Player 2"
    , a.Opponent, a.Year, a.Round, a.Eleven, a.Grade, a.Association
FROM z_batting_partnerships_highest a
INNER JOIN (
    SELECT wicket
        , max(p) as p
    FROM z_batting_partnerships_highest
    where eleven = '3rd'
    group by wicket
) max_part
on a.p = max_part.p
and a.wicket = max_part.wicket
WHERE a.eleven = '3rd'
order by a.wicket


