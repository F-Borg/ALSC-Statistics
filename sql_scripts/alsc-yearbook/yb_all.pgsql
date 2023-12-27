
--drop view yb_01_season_summary;
CREATE OR REPLACE VIEW yb_01_season_summary AS
SELECT 
    Seasons.SeasonID
    , Matches.Round
    , Matches.Ground
    , Matches.result
    , team_05_scores_highest.Opponent
    , team_05_scores_highest.Score AS bat_total
    , team_07_scores_opp_highest.Score AS bowl_total
    , case when Batting.How_Out = 'Not Out' then Batting.Score::varchar || '*'
        else Batting.Score::varchar end as bat_score
    , players.name_fl AS bat_name 
    , z_Bowling_Figures_All.Figures
    , players1.name_fl AS bowl_name 
    , Innings.InningsNO

FROM Seasons
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID

LEFT JOIN team_05_scores_highest 
ON team_05_scores_highest.Eleven = Seasons.Eleven
AND team_05_scores_highest.Year = Seasons.Year
AND team_05_scores_highest.Round = Matches.Round
AND team_05_scores_highest.Opponent = Matches.Opponent

LEFT JOIN  team_07_scores_opp_highest
ON  team_07_scores_opp_highest.Eleven = Seasons.Eleven
AND team_07_scores_opp_highest.Round = Matches.Round
AND team_07_scores_opp_highest.Year = Seasons.Year

LEFT JOIN Innings AS Innings_1
ON Matches.MatchID = Innings_1.MatchID
LEFT JOIN z_Bowling_Figures_All 
ON z_Bowling_Figures_All.InningsID = Innings_1.InningsID
AND z_Bowling_Figures_All.w>1
LEFT JOIN Players AS players1 
ON players1.PlayerID = z_Bowling_Figures_All.PlayerID

LEFT JOIN Innings 
ON Matches.MatchID = Innings.MatchID
LEFT JOIN Batting 
ON Innings.InningsID = Batting.InningsID
AND Batting.Score>24
LEFT JOIN Players 
ON Players.PlayerID = Batting.PlayerID

--where Innings.InningsNO in (1,2) 
ORDER BY Seasons.seasonid, Matches.Date1, Batting.Score DESC , z_Bowling_Figures_All.w DESC;


CREATE OR REPLACE VIEW yb_02_batting_summary AS
SELECT 
    Batting.PlayerID
    , Matches.seasonid
    , players.player_name AS "Name"
    , Sum(CASE WHEN innings.inningsno=1 Or innings.inningsno=2 then 1 else 0 end) AS "Matches"
    , Count(Batting.Batting_Position) AS "Innings"
    , Sum(case when lower(batting.how_out) in ('not out','retired hurt','forced retirement') then 1 else 0 end) AS "Not Outs"
    , Sum(Batting._4s) AS "Fours"
    , Sum(Batting._6s) AS "Sixes"
    , Sum((CASE WHEN lower(batting.how_out) not in ('not out','retired hurt','forced retirement') And batting.score=0 then 1 else 0 end)) AS "Ducks"
    , Sum((CASE WHEN batting.score Between 50 And 99 then 1 else 0 end)) AS "Fifties"
    , Sum((CASE WHEN batting.score>99 then 1 else 0 end)) AS "Hundreds"
    , z_batmax_season.hs as "Highest Score"
    , Sum(Batting.Score) AS "Total Runs"
    , (CASE WHEN Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','forced retirement') then 1 else 0 end))=0 then -9 
        else Sum(Batting.Score)/(Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','forced retirement') then 1 else 0 end))) end) AS "Average"
    , Sum(batting.balls_faced) AS "Balls Faced"
    , (CASE WHEN Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','forced retirement') then 1 else 0 end))=0 then -9 
        else Sum(Batting.balls_faced)/(Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','forced retirement') then 1 else 0 end))) end) AS "Average Balls Faced/Dismissal"
    , (CASE WHEN Sum(batting.balls_faced)=0 then 0 else 100*Sum(batting.score)/Sum(batting.balls_faced) end) AS "Strike Rate"
    , 100*(Sum(batting._4s)*4+Sum(batting._6s)*6)/(CASE WHEN Sum(batting.score)=0 then 1 else Sum(batting.score) end) AS "% of Runs in Boundaries"

FROM Seasons 
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting 
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting.PlayerID 
INNER JOIN z_batmax_season 
ON Seasons.SeasonID = z_batmax_season.SeasonID
AND z_batmax_season.PlayerID = Players.PlayerID

GROUP BY Batting.PlayerID, players.player_name, z_batmax_season.HS, Seasons.Year, Seasons.Eleven, Matches.SeasonID
ORDER BY Sum(Batting.Score) DESC, "Average" DESC
;


--drop view yb_03_batting_pships;
CREATE OR REPLACE VIEW yb_03_batting_pships AS
SELECT 
    z_bat_partnerships.Wicket
    , z_bat_partnerships.p AS Runs
    , players.player_name AS "Batter 1"
    , players_1.player_name AS "Batter 2"
    , Matches.Opponent
    , Matches.Round
    , Seasons.SeasonID
FROM Seasons
INNER JOIN Matches 
ON Matches.SeasonID = Seasons.SeasonID
INNER JOIN Innings
ON Matches.MatchID = Innings.MatchID

INNER JOIN z_bat_part_max_season 
ON Seasons.SeasonID = z_bat_part_max_season.SeasonID
INNER JOIN z_bat_partnerships
ON z_bat_partnerships.InningsID = Innings.InningsID
AND z_bat_part_max_season.MaxOfp = z_bat_partnerships.p
AND z_bat_part_max_season.Wicket = z_bat_partnerships.Wicket

INNER JOIN Players 
ON Players.PlayerID = z_bat_partnerships.PlayerID
INNER JOIN Players AS Players_1 
ON z_bat_partnerships.not_out_batter = Players_1.PlayerID
 
GROUP BY z_bat_partnerships.Wicket, z_bat_partnerships.p, players.player_name, players_1.player_name, Matches.Opponent, Matches.Round, Seasons.Year, Seasons.Grade, Seasons.SeasonID
--HAVING Seasons.SeasonID=73
ORDER BY z_bat_partnerships.Wicket, Seasons.SeasonID;



CREATE OR REPLACE VIEW yb_04_bowling_summary AS
SELECT 
    Players.player_name AS "Name"
    , z_player_season_matches.mat as "Matches"
    , floor((Sum(overs)*6+Sum(bowling.extra_balls))/6)::varchar || 
        CASE WHEN floor((Sum(overs)*6+Sum(bowling.extra_balls))/6)=(Sum(overs)*6+Sum(bowling.extra_balls))/6 THEN '' 
            ELSE '.' || Round(6*((Sum(overs)*6+Sum(bowling.extra_balls))/6-floor((Sum(overs)*6+Sum(bowling.extra_balls))/6))) END AS "Overs"
    , Sum(overs)*6+Sum(bowling.extra_balls) AS "Balls"
    , Sum(Bowling.Maidens) AS "Maidens"
    , Sum(z_Bowling_Figures_All.runs) AS "Runs"
    , Sum(z_Bowling_Figures_All.w) AS "Wickets"
    , CASE WHEN Sum(z_Bowling_Figures_All.w) > 0 then Sum(z_Bowling_Figures_All.runs)/Sum(z_Bowling_Figures_All.w) ELSE -9 END AS "Average"
    -- , Sum(z_Bowling_Figures_All.wides) AS "Total Wides"
    -- , Sum(z_Bowling_Figures_All.no_balls) AS "Total no balls"
    -- , Sum((CASE WHEN z_Bowling_Figures_All.w Between 2 And 4 then 1 else 0 end)) AS wick24
    -- , Sum((CASE WHEN z_Bowling_Figures_All.w Between 5 And 10 then 1 else 0 end)) AS wick5
    , z_bbf_season.Figures AS "Best Bowling Figures"
    , CASE WHEN Sum(z_Bowling_Figures_All.w) > 0 then (Sum(overs)*6+Sum(bowling.extra_balls))/Sum(z_Bowling_Figures_All.w) ELSE -9 END AS "Strike Rate"
    , 6*Sum(z_Bowling_Figures_All.runs)/(Sum(overs)*6+Sum(bowling.extra_balls)) AS "Economy Rate"
    , CASE WHEN Sum(z_Bowling_Figures_All.w) > 0 then Sum(z_Bowling_Figures_All.tbd)/Sum(z_Bowling_Figures_All.w) ELSE -9 END AS "ABD"
    , Seasons.SeasonID
    , Bowling.PlayerID
FROM Seasons
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID 
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Bowling 
ON Innings.InningsID = Bowling.InningsID 

INNER JOIN Players 
ON Players.PlayerID = Bowling.PlayerID 

INNER JOIN z_bbf_season 
ON z_bbf_season.PlayerID = Players.PlayerID 
AND Seasons.SeasonID = z_bbf_season.SeasonID

INNER JOIN z_Bowling_Figures_All 
ON z_Bowling_Figures_All.PlayerID = Bowling.PlayerID
AND z_Bowling_Figures_All.InningsID = Bowling.InningsID

INNER JOIN z_player_season_matches 
ON Seasons.SeasonID = z_player_season_matches.SeasonID
AND Players.PlayerID = z_player_season_matches.PlayerID

--where Matches.SeasonID=73
GROUP BY Bowling.PlayerID, Players.player_name, z_bbf_season.Figures, z_player_season_matches.Mat, Seasons.Year, Seasons.Eleven, Seasons.SeasonID
ORDER BY "Wickets" DESC, "Runs";




CREATE OR REPLACE VIEW yb_05_fielding_summary AS
SELECT 
    Players.player_name AS "Name"
    , z_player_season_matches.Mat as "Matches"
    , Sum(CASE WHEN lower(wickets.how_out)='caught' then 1 else 0 end) AS "Catches"
    , Sum(CASE WHEN lower(wickets.how_out)='stumped' then 1 else 0 end) AS "Stumpings"
    , Sum(CASE WHEN lower(wickets.how_out)='run out' then 1 else 0 end) AS "Run Outs"
    , Seasons.seasonid
FROM Matches 
INNER JOIN (Innings INNER JOIN (Seasons INNER JOIN ((Players INNER JOIN Wickets ON Players.PlayerID = Wickets.assist) INNER JOIN z_player_season_matches ON Players.PlayerID = z_player_season_matches.PlayerID) ON 
Seasons.SeasonID = z_player_season_matches.SeasonID) ON Innings.InningsID = Wickets.InningsID) ON (Seasons.SeasonID = Matches.SeasonID) AND (Matches.MatchID = Innings.MatchID)
GROUP BY Players.player_name, z_player_season_matches.Mat, Seasons.Year, Seasons.Eleven, Matches.SeasonID, z_player_season_matches.Mat, Seasons.seasonid
ORDER BY "Catches" DESC, "Stumpings" DESC, "Run Outs" DESC, z_player_season_matches.Mat DESC;


--CREATE OR REPLACE VIEW yb_06_season_summary_2ndXI AS
--CREATE OR REPLACE VIEW yb_07_batting_summary_2ndXI AS
--CREATE OR REPLACE VIEW yb_08_batting_pships_2ndXI AS
--CREATE OR REPLACE VIEW yb_09_bowling_summary_2ndXI AS
--CREATE OR REPLACE VIEW yb_10_fielding_summary_2ndXI AS
--CREATE OR REPLACE VIEW yb_11_season_summary_3rdXI AS
--CREATE OR REPLACE VIEW yb_12_batting_summary_3rdXI AS
--CREATE OR REPLACE VIEW yb_13_batting_pships_3rdXI AS
--CREATE OR REPLACE VIEW yb_14_bowling_summary_3rdXI AS
--CREATE OR REPLACE VIEW yb_15_fielding_summary_3rdXI AS


--CREATE OR REPLACE VIEW yb_16_batting_ind AS
--CREATE OR REPLACE VIEW yb_17_bowling_ind AS



--drop table zz_temp_yb_batting;
CREATE TABLE zz_temp_yb_batting AS
SELECT 
    players.player_name AS Name
    , Matches.Date1
    , Seasons.Eleven
    , Matches.Round
    , Matches.Opponent
    , batting.score::varchar || (CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt') then '*' else '' end) AS Score
    , Batting.Balls_Faced as "Balls Faced", Batting._4s, Batting._6s, Batting.Batting_Position
FROM Seasons INNER JOIN (Matches INNER JOIN (Innings INNER JOIN (Players INNER JOIN Batting ON Players.PlayerID = Batting.PlayerID) ON Innings.InningsID = Batting.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
WHERE Seasons.SeasonID in (76,77,78)
--GROUP BY players.surname ||', '|| players.firstname, Seasons.Eleven, Matches.Round, Matches.Opponent, batting.score & (CASE WHEN batting.how_out="not out" Or batting.how_out="retired hurt" Or batting.how_out="forced retirement","*",""), Batting.Balls Faced, Batting.4s, Batting.6s, Batting.Batting Position, Seasons.Grade, Seasons.Year, Seasons.Grade, Matches.Date1, Matches.MatchID, Innings.InningsNO, Matches.Round, Batting.Score, Players.PlayerID 
and Batting.Balls_Faced Is Not Null
ORDER BY players.player_name, Matches.Date1, Matches.MatchID, Innings.InningsNO, Matches.Round
;

--drop table zz_temp_yb_bowling;
CREATE TABLE zz_temp_yb_bowling AS
SELECT 
    players.player_name AS Name
    , Matches.Date1 --temp
    , Seasons.Eleven
    , Matches.Round
    , Matches.Opponent
    , z_z_Bowling_Figures_All_All.Ov AS Overs
    , z_z_Bowling_Figures_All_All.Maidens
    , z_z_Bowling_Figures_All_All.runs AS Runs
    , z_z_Bowling_Figures_All_All.w AS Wickets
    , Innings.InningsNO
FROM Seasons INNER JOIN (Matches INNER JOIN ((Players INNER JOIN z_z_Bowling_Figures_All_All ON Players.PlayerID = z_z_Bowling_Figures_All_All.PlayerID) INNER JOIN Innings ON z_z_Bowling_Figures_All_All.InningsID = Innings.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
--GROUP BY players.surname ||', '|| players.firstname, Seasons.Eleven, Matches.Round, Matches.Opponent, z_z_Bowling_Figures_All_All.Ov, z_z_Bowling_Figures_All_All.Maidens, z_z_Bowling_Figures_All_All.runs, z_z_Bowling_Figures_All_All.w, Innings.InningsNO, Matches.Date1, Matches.Date1, Seasons.Year, Seasons.Grade, Seasons.Eleven, z_z_Bowling_Figures_All_All.w, z_z_Bowling_Figures_All_All.runs, Players.PlayerID, Seasons.SeasonID, Matches.MatchID
WHERE Seasons.SeasonID in (76,77,78)
ORDER BY players.player_name, Matches.Date1, Innings.InningsNO;


