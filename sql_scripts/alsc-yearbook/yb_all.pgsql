
CREATE OR REPLACE VIEW yb_01_season_summary AS
SELECT 
    Matches.Round
    , Matches.Ground
    , team_05_scores_highest.Opponent
    , team_05_scores_highest.Score
    , team_07_scores_opp_highest.Score
    , Batting.Score
    , Batting.How_Out
    , left(players.firstname,1) ||' '|| players.Surname AS Name
    , z_z_Bowling_Figures_All.Figures
    , left(players1.firstname,1) ||' '|| players1.Surname AS Name
    , Innings.InningsNO
FROM ((team_07_scores_opp_highest 
INNER JOIN ((team_05_scores_highest 
INNER JOIN Seasons 
ON (team_05_scores_highest.Eleven = Seasons.Eleven) 
AND (team_05_scores_highest.Year = Seasons.Year)) 
INNER JOIN Matches ON (Seasons.SeasonID = Matches.SeasonID) 
AND (team_05_scores_highest.Round = Matches.Round) 
AND (team_05_scores_highest.Opponent = Matches.Opponent)) 
ON (team_07_scores_opp_highest.Eleven = Seasons.Eleven) 
AND (team_07_scores_opp_highest.Round = Matches.Round) 
AND (team_07_scores_opp_highest.Year = Seasons.Year)) 
INNER JOIN ((Players AS players1 
INNER JOIN z_z_Bowling_Figures_All 
ON players1.PlayerID = z_z_Bowling_Figures_All.PlayerID) 
INNER JOIN Innings AS Innings_1 
ON z_z_Bowling_Figures_All.InningsID = Innings_1.InningsID) 
ON Matches.MatchID = Innings_1.MatchID) 
INNER JOIN (Innings 
INNER JOIN (Players 
INNER JOIN Batting 
ON Players.PlayerID = Batting.PlayerID) 
ON Innings.InningsID = Batting.InningsID) 
ON Matches.MatchID = Innings.MatchID
--GROUP BY Matches.Round, Matches.Ground, team_05_scores_highest.Opponent, team_05_scores_highest.Score, team_07_scores_opp_highest.Score, Batting.Score, Batting.How Out, players.Surname ||', '|| players.firstname, z_z_Bowling_Figures_All.Figures, Players_1.Surname, Players_1.First Name, Innings.InningsNO, Seasons.SeasonID, Matches.Date1, z_z_Bowling_Figures_All.w
where (((Innings.InningsNO)=1 Or (Innings.InningsNO)=2) AND ((Seasons.SeasonID)=73) AND ((Batting.Score)>24) AND ((z_z_Bowling_Figures_All.w)>1))
ORDER BY Matches.Date1, Batting.Score DESC , z_z_Bowling_Figures_All.w DESC;


CREATE OR REPLACE VIEW yb_02_batting_summary AS
SELECT 
    Batting.PlayerID
    , players.player_name AS Name
    , Sum((CASE WHEN innings.inningsno=1 Or innings.inningsno=2 then 1 else 0 end)) AS Mat
    , Count(Batting.Batting_Position) AS Inn
    , Sum(Batting.Score) AS Total
    , Sum(case when lower(batting.how_out) in ('not out','retired hurt','forced retirement') then 0 else 1 end) AS "NO"
    , Sum(batting.balls_faced) AS BF
    --, Sum((CASE WHEN batting.score Between 25 And 49 then 1 else 0 end)) AS Twentyfive
    , Sum((CASE WHEN batting.score Between 50 And 99 then 1 else 0 end)) AS Fifties
    , Sum((CASE WHEN batting.score>99 then 1 else 0 end)) AS Hundreds
    , Sum((CASE WHEN lower(batting.how_out) not in ('not out','retired hurt','forced retirement') And batting.score=0 then 1 else 0 end)) AS Ducks
    , z_batmax_season.HS
    , Sum(Batting._4s) AS Fours
    , Sum(Batting._6s) AS Sixes
    , (CASE WHEN Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','forced retirement') then 1 else 0 end))=0 then -9 
        else Sum(Batting.Score)/(Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','forced retirement') then 1 else 0 end))) end) AS Average
    , (CASE WHEN Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','forced retirement') then 1 else 0 end))=0 then -9 
        else Sum(Batting.balls_faced)/(Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','forced retirement') then 1 else 0 end))) end) AS "Ave BF"
    , (CASE WHEN Sum(batting.balls_faced)=0 then 0 else 100*Sum(batting.score)/Sum(batting.balls_faced) end) AS "Runs/100 Balls"
    , 100*(Sum(batting._4s)*4+Sum(batting._6s)*6)/(CASE WHEN Sum(batting.score)=0 then 1 else Sum(batting.score) end) AS "% of Runs in Boundaries"
FROM Matches INNER JOIN (Innings INNER JOIN ((Seasons INNER JOIN z_batmax_season ON Seasons.SeasonID = z_batmax_season.SeasonID) INNER JOIN (Players INNER JOIN Batting ON Players.PlayerID = Batting.PlayerID) ON z_batmax_season.PlayerID = Players.PlayerID) ON Innings.InningsID = Batting.InningsID) ON (Matches.MatchID = Innings.MatchID) AND (Seasons.SeasonID = Matches.SeasonID)
WHERE (((Matches.SeasonID)=73))
GROUP BY Batting.PlayerID, players.player_name, z_batmax_season.HS, Seasons.Year, Seasons.Eleven, Matches.SeasonID
ORDER BY Sum(Batting.Score) DESC, Average DESC
;


CREATE OR REPLACE VIEW yb_03_batting_pships AS
SELECT 
    z_bat_partnerships.Wicket
    , z_bat_partnerships.p AS Runs
    , players.player_name AS "Batsman 1"
    , players_1.player_name AS "Batsman 2"
    , Matches.Opponent
    , Matches.Round
FROM Matches 
INNER JOIN ((Seasons INNER JOIN z_bat_part_max_season ON Seasons.SeasonID = z_bat_part_max_season.SeasonID) 
INNER JOIN (((Players INNER JOIN z_bat_partnerships ON Players.PlayerID = z_bat_partnerships.PlayerID) 
INNER JOIN Players AS Players_1 ON z_bat_partnerships.not_out_batter = Players_1.PlayerID) 
INNER JOIN Innings ON z_bat_partnerships.InningsID = Innings.InningsID) 
ON (z_bat_part_max_season.MaxOfp = z_bat_partnerships.p) AND (z_bat_part_max_season.Wicket = z_bat_partnerships.Wicket)) 
ON (Matches.MatchID = Innings.MatchID) AND (Matches.SeasonID = Seasons.SeasonID)
GROUP BY z_bat_partnerships.Wicket, z_bat_partnerships.p, players.player_name, players_1.player_name, Matches.Opponent, Matches.Round, Seasons.Year, Seasons.Grade, Seasons.SeasonID
HAVING Seasons.SeasonID=73
ORDER BY z_bat_partnerships.Wicket, Seasons.SeasonID;


CREATE OR REPLACE VIEW yb_04_bowling_summary AS
SELECT 
    Bowling.PlayerID
    , Players.player_name AS Name
    , floor((Sum(overs)*6+Sum(bowling.extra_balls))/6)::varchar || 
        CASE WHEN floor((Sum(overs)*6+Sum(bowling.extra_balls))/6)=(Sum(overs)*6+Sum(bowling.extra_balls))/6 THEN '' 
            ELSE '.' || Round(6*((Sum(overs)*6+Sum(bowling.extra_balls))/6-floor((Sum(overs)*6+Sum(bowling.extra_balls))/6))) END AS O
    , Sum(Bowling.Maidens) AS Mdns
    , Sum(z_Bowling_Figures_All.runs) AS "Total Runs"
    , Sum(z_Bowling_Figures_All.w) AS "Total Wickets"
    , Sum(z_Bowling_Figures_All.wides) AS "Total Wides"
    , Sum(z_Bowling_Figures_All.no_balls) AS "Total no balls"
    , Sum((CASE WHEN z_Bowling_Figures_All.w Between 2 And 4 then 1 else 0 end)) AS wick24
    , Sum((CASE WHEN z_Bowling_Figures_All.w Between 5 And 10 then 1 else 0 end)) AS wick5
    , z_bbf_season.Figures AS "Best Bowling"
FROM Matches INNER JOIN (Innings INNER JOIN ((Seasons INNER JOIN (z_bbf_season INNER JOIN (
    z_Bowling_Figures_All INNER JOIN (Players INNER JOIN Bowling ON Players.PlayerID = Bowling.PlayerID) ON (z_Bowling_Figures_All.PlayerID = 
    Bowling.PlayerID) AND (z_Bowling_Figures_All.InningsID = Bowling.InningsID)) 
ON z_bbf_season.PlayerID = Players.PlayerID) ON Seasons.SeasonID = z_bbf_season.SeasonID) 
INNER JOIN z_player_season_matches ON (Seasons.SeasonID = z_player_season_matches.SeasonID) AND (Players.PlayerID = z_player_season_matches.PlayerID)) 
ON Innings.InningsID = Bowling.InningsID) ON (Seasons.SeasonID = Matches.SeasonID) AND (Matches.MatchID = Innings.MatchID)
where Matches.SeasonID=73
GROUP BY Bowling.PlayerID, Players.player_name, z_bbf_season.Figures, z_player_season_matches.Mat, Seasons.Year, Seasons.Eleven
ORDER BY "Total Wickets" DESC, "Total Runs", "Total Wides";



CREATE OR REPLACE VIEW yb_05_fielding_summary AS
SELECT 
    Players.player_name AS Name
    , z_player_season_matches.Mat
    , Sum(CASE WHEN lower(wickets.how_out)='caught' then 1 else 0 end) AS Catches
    , Sum(CASE WHEN lower(wickets.how_out)='stumped' then 1 else 0 end) AS Stumpings
    , Sum(CASE WHEN lower(wickets.how_out)='run out' then 1 else 0 end) AS "Run Outs"
FROM Matches INNER JOIN (Innings INNER JOIN (Seasons INNER JOIN ((Players INNER JOIN Wickets ON Players.PlayerID = Wickets.assist) INNER JOIN z_player_season_matches ON Players.PlayerID = z_player_season_matches.PlayerID) ON 
Seasons.SeasonID = z_player_season_matches.SeasonID) ON Innings.InningsID = Wickets.InningsID) ON (Seasons.SeasonID = Matches.SeasonID) AND (Matches.MatchID = Innings.MatchID)
WHERE Matches.SeasonID=73
GROUP BY Players.player_name, z_player_season_matches.Mat, Seasons.Year, Seasons.Eleven, Matches.SeasonID, z_player_season_matches.Mat
ORDER BY Catches DESC, Stumpings DESC, "Run Outs" DESC, z_player_season_matches.Mat DESC;


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
WHERE (((Seasons.SeasonID)=73 Or (Seasons.SeasonID)=74 Or (Seasons.SeasonID)=75))
--GROUP BY players.surname ||', '|| players.firstname, Seasons.Eleven, Matches.Round, Matches.Opponent, batting.score & (CASE WHEN batting.how_out="not out" Or batting.how_out="retired hurt" Or batting.how_out="forced retirement","*",""), Batting.Balls Faced, Batting.4s, Batting.6s, Batting.Batting Position, Seasons.Grade, Seasons.Year, Seasons.Grade, Matches.Date1, Matches.MatchID, Innings.InningsNO, Matches.Round, Batting.Score, Players.PlayerID 
and Batting.Balls_Faced Is Not Null
ORDER BY players.player_name, Matches.Date1, Matches.MatchID, Innings.InningsNO, Matches.Round
;

--drop table zz_temp_yb_batting;
CREATE TABLE zz_temp_yb_bowling AS
SELECT 
    players.player_name AS Name
    , Matches.Date1 --temp
    , Seasons.Eleven
    , Matches.Round
    , Matches.Opponent
    , z_z_z_Bowling_Figures_All_All.Ov AS Overs
    , z_z_z_Bowling_Figures_All_All.Maidens
    , z_z_z_Bowling_Figures_All_All.runs AS Runs
    , z_z_z_Bowling_Figures_All_All.w AS Wickets
    , Innings.InningsNO
FROM Seasons INNER JOIN (Matches INNER JOIN ((Players INNER JOIN z_z_z_Bowling_Figures_All_All ON Players.PlayerID = z_z_z_Bowling_Figures_All_All.PlayerID) INNER JOIN Innings ON z_z_z_Bowling_Figures_All_All.InningsID = Innings.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
--GROUP BY players.surname ||', '|| players.firstname, Seasons.Eleven, Matches.Round, Matches.Opponent, z_z_z_Bowling_Figures_All_All.Ov, z_z_z_Bowling_Figures_All_All.Maidens, z_z_z_Bowling_Figures_All_All.runs, z_z_z_Bowling_Figures_All_All.w, Innings.InningsNO, Matches.Date1, Matches.Date1, Seasons.Year, Seasons.Grade, Seasons.Eleven, z_z_z_Bowling_Figures_All_All.w, z_z_z_Bowling_Figures_All_All.runs, Players.PlayerID, Seasons.SeasonID, Matches.MatchID
WHERE (((Seasons.SeasonID)=73 Or (Seasons.SeasonID)=74 Or (Seasons.SeasonID)=75))
ORDER BY players.player_name, Matches.Date1, Innings.InningsNO;


