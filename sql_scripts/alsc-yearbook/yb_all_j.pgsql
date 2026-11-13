
--drop view yb_j_01_season_summary;
CREATE OR REPLACE VIEW yb_j_01_season_summary AS
SELECT 
    Seasons_j.SeasonID
    , Matches_j.Round
    , Matches_j.Ground
    , Matches_j.result
    , team_j_05_scores_highest.Opponent
    , team_j_05_scores_highest.Score AS bat_total
    , team_j_07_scores_opp_highest.Score AS bowl_total
    , case when Batting_j.How_Out = 'Not Out' then Batting_j.Score::varchar || '*'
        else Batting_j.Score::varchar end as bat_score
    , players.name_fl AS bat_name 
    , z_j_Bowling_Figures_All.Figures
    , players1.name_fl AS bowl_name 
    , Innings_j.InningsNO

FROM Seasons_j
INNER JOIN Matches_j 
ON Seasons_j.SeasonID = Matches_j.SeasonID

LEFT JOIN team_j_05_scores_highest 
ON team_j_05_scores_highest.Eleven = Seasons_j.Eleven
AND team_j_05_scores_highest.Year = Seasons_j.Year
AND team_j_05_scores_highest.Round = Matches_j.Round
AND team_j_05_scores_highest.Opponent = Matches_j.Opponent

LEFT JOIN  team_j_07_scores_opp_highest
ON  team_j_07_scores_opp_highest.Eleven = Seasons_j.Eleven
AND team_j_07_scores_opp_highest.Round = Matches_j.Round
AND team_j_07_scores_opp_highest.Year = Seasons_j.Year

LEFT JOIN Innings_j AS Innings_1
ON Matches_j.MatchID = Innings_1.MatchID
LEFT JOIN z_j_Bowling_Figures_All 
ON z_j_Bowling_Figures_All.InningsID = Innings_1.InningsID
AND z_j_Bowling_Figures_All.w>1
LEFT JOIN Players AS players1 
ON players1.PlayerID = z_j_Bowling_Figures_All.PlayerID

LEFT JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
LEFT JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
AND Batting_j.Score>24
LEFT JOIN Players 
ON Players.PlayerID = Batting_j.PlayerID

--where Innings_j.InningsNO in (1,2) 
ORDER BY Seasons_j.seasonid, Matches_j.Date1, Batting_j.Score DESC , z_j_Bowling_Figures_All.w DESC;


--DROP VIEW yb_j_02_batting_summary;
CREATE OR REPLACE VIEW yb_j_02_batting_summary AS
SELECT 
    Batting_j.PlayerID
    , players.name_fl
    , Matches_j.seasonid
    , Seasons_j.Year as "Year"
    , players.player_name AS "Name"
    , Sum(CASE WHEN innings_j.inningsno=1 Or innings_j.inningsno=2 then 1 else 0 end) AS "Matches"
    , Sum(CASE WHEN lower(coalesce(Batting_j.how_out,'0')) in ('dnb','0','absent out') then 0 else 1 end) AS "Innings"
    , Sum(case when lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end) AS "Not Outs"
    , Sum(Batting_j._4s) AS "Fours"
    , Sum(Batting_j._6s) AS "Sixes"
    , Sum(CASE WHEN lower(batting_j.how_out) not in ('dnb','0','absent out','not out','forced retirement','retired hurt','retired not out','retired') And batting_j.score=0 then 1 else 0 end) AS "Ducks"
    , Sum((CASE WHEN batting_j.score Between 50 And 99 then 1 else 0 end)) AS "Fifties"
    , Sum((CASE WHEN batting_j.score>99 then 1 else 0 end)) AS "Hundreds"
    , z_j_batmax_season.hs as "Highest Score"
    , Sum(Batting_j.Score) AS "Total Runs"
    , (CASE WHEN Count(Batting_j.Score)-Sum((CASE WHEN lower(batting_j.how_out) in ('dnb','0','not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))=0 then -9 
        else Sum(Batting_j.Score)/(Count(Batting_j.Score)-Sum((CASE WHEN lower(batting_j.how_out) in ('dnb','0','not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))) end) AS "Average"
    , Sum(batting_j.balls_faced) AS "Balls Faced"
    , (CASE WHEN Count(Batting_j.Score)-Sum((CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))=0 then -9 
        else Sum(Batting_j.balls_faced)/(Count(Batting_j.Score)-Sum((CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))) end) AS "Average Balls Faced/Dismissal"
    , (CASE WHEN Sum(batting_j.balls_faced)=0 then 0 else 100*Sum(batting_j.score)/Sum(batting_j.balls_faced) end) AS "Strike Rate"
    , 100*(Sum(batting_j._4s)*4+Sum(batting_j._6s)*6)/(CASE WHEN Sum(batting_j.score)=0 then 1 else Sum(batting_j.score) end) AS "% of Runs in Boundaries"

FROM Seasons_j 
INNER JOIN Matches_j 
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting_j.PlayerID 
INNER JOIN z_j_batmax_season 
ON Seasons_j.SeasonID = z_j_batmax_season.SeasonID
AND z_j_batmax_season.PlayerID = Players.PlayerID

GROUP BY Batting_j.PlayerID, players.player_name, z_j_batmax_season.HS, Seasons_j.Year, Seasons_j.Eleven, Matches_j.SeasonID, players.name_fl
ORDER BY Sum(Batting_j.Score) DESC, "Average" DESC
;


--drop view yb_j_03_batting_pships;
CREATE OR REPLACE VIEW yb_j_03_batting_pships AS
SELECT 
    z_j_bat_partnerships.Wicket
    , z_j_bat_partnerships.p AS Runs
    , players.player_name AS "Batter 1"
    , players_1.player_name AS "Batter 2"
    , Matches_j.Opponent
    , Matches_j.Round
    , Seasons_j.SeasonID
FROM Seasons_j
INNER JOIN Matches_j 
ON Matches_j.SeasonID = Seasons_j.SeasonID
INNER JOIN Innings_j
ON Matches_j.MatchID = Innings_j.MatchID

INNER JOIN z_j_bat_part_max_season 
ON Seasons_j.SeasonID = z_j_bat_part_max_season.SeasonID
INNER JOIN z_j_bat_partnerships
ON z_j_bat_partnerships.InningsID = Innings_j.InningsID
AND z_j_bat_part_max_season.MaxOfp = z_j_bat_partnerships.p
AND z_j_bat_part_max_season.Wicket = z_j_bat_partnerships.Wicket

INNER JOIN Players 
ON Players.PlayerID = z_j_bat_partnerships.PlayerID
INNER JOIN Players AS Players_1 
ON z_j_bat_partnerships.not_out_batter = Players_1.PlayerID
 
GROUP BY z_j_bat_partnerships.Wicket, z_j_bat_partnerships.p, players.player_name, players_1.player_name, Matches_j.Opponent, Matches_j.Round, Seasons_j.Year, Seasons_j.Grade, Seasons_j.SeasonID
--HAVING Seasons_j.SeasonID=73
ORDER BY z_j_bat_partnerships.Wicket, Seasons_j.SeasonID;


--DROP VIEW yb_j_04_bowling_summary;
CREATE OR REPLACE VIEW yb_j_04_bowling_summary AS
SELECT 
    Players.player_name AS "Name"
    , z_j_player_season_matches.mat as "Matches"
    , floor((Sum(overs)*6+Sum(bowling_j.extra_balls))/6)::varchar || 
        CASE WHEN floor((Sum(overs)*6+Sum(bowling_j.extra_balls))/6)=(Sum(overs)*6+Sum(bowling_j.extra_balls))/6 THEN '' 
            ELSE '.' || Round(6*((Sum(overs)*6+Sum(bowling_j.extra_balls))/6-floor((Sum(overs)*6+Sum(bowling_j.extra_balls))/6))) END AS "Overs"
    , Sum(overs)*6+Sum(bowling_j.extra_balls) AS "Balls"
    , Sum(Bowling_j.Maidens) AS "Maidens"
    , Sum(z_j_Bowling_Figures_All.runs) AS "Runs"
    , Sum(z_j_Bowling_Figures_All.w) AS "Wickets"
    , CASE WHEN Sum(z_j_Bowling_Figures_All.w) > 0 then Sum(z_j_Bowling_Figures_All.runs)/Sum(z_j_Bowling_Figures_All.w) ELSE -9 END AS "Average"
    -- , Sum(z_j_Bowling_Figures_All.wides) AS "Total Wides"
    -- , Sum(z_j_Bowling_Figures_All.no_balls) AS "Total no balls"
    -- , Sum((CASE WHEN z_j_Bowling_Figures_All.w Between 2 And 4 then 1 else 0 end)) AS wick24
    -- , Sum((CASE WHEN z_j_Bowling_Figures_All.w Between 5 And 10 then 1 else 0 end)) AS wick5
    , z_j_bbf_season.Figures AS "Best Bowling_j Figures"
    , CASE WHEN Sum(z_j_Bowling_Figures_All.w) > 0 then (Sum(overs)*6+Sum(bowling_j.extra_balls))/Sum(z_j_Bowling_Figures_All.w) ELSE -9 END AS "Strike Rate"
    , 6*Sum(z_j_Bowling_Figures_All.runs)/(Sum(overs)*6+Sum(bowling_j.extra_balls)) AS "Economy Rate"
    , CASE WHEN Sum(z_j_Bowling_Figures_All.w) > 0 then Sum(z_j_Bowling_Figures_All.tbd)/Sum(z_j_Bowling_Figures_All.w) ELSE -9 END AS "ABD"
    , Seasons_j.SeasonID
    , Bowling_j.PlayerID
    , Seasons_j.Year as "Year"
    , players.name_fl
FROM Seasons_j
INNER JOIN Matches_j 
ON Seasons_j.SeasonID = Matches_j.SeasonID 
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Bowling_j 
ON Innings_j.InningsID = Bowling_j.InningsID 

INNER JOIN Players 
ON Players.PlayerID = Bowling_j.PlayerID 

INNER JOIN z_j_bbf_season 
ON z_j_bbf_season.PlayerID = Players.PlayerID 
AND Seasons_j.SeasonID = z_j_bbf_season.SeasonID

INNER JOIN z_j_Bowling_Figures_All 
ON z_j_Bowling_Figures_All.PlayerID = Bowling_j.PlayerID
AND z_j_Bowling_Figures_All.InningsID = Bowling_j.InningsID

INNER JOIN z_j_player_season_matches 
ON Seasons_j.SeasonID = z_j_player_season_matches.SeasonID
AND Players.PlayerID = z_j_player_season_matches.PlayerID

--where Matches_j.SeasonID=73
GROUP BY Bowling_j.PlayerID, Players.player_name, z_j_bbf_season.Figures, z_j_player_season_matches.Mat, Seasons_j.Year, Seasons_j.Eleven, Seasons_j.SeasonID, players.name_fl
ORDER BY "Wickets" DESC, "Runs";



--DROP VIEW yb_j_05_fielding_summary;
CREATE OR REPLACE VIEW yb_j_05_fielding_summary AS
SELECT 
    Players.player_name AS "Name"
    , z_j_player_season_matches.Mat as "Matches"
    , Sum(CASE WHEN lower(wickets_j.how_out)='caught' then 1 else 0 end) AS "Catches"
    , Sum(CASE WHEN lower(wickets_j.how_out)='stumped' then 1 else 0 end) AS "Stumpings"
    , Sum(CASE WHEN lower(wickets_j.how_out)='run out' then 1 else 0 end) AS "Run Outs"
    , Seasons_j.seasonid
FROM Matches_j 
INNER JOIN (Innings_j INNER JOIN (Seasons_j INNER JOIN ((Players INNER JOIN Wickets_j ON Players.PlayerID = Wickets_j.assist) INNER JOIN z_j_player_season_matches ON Players.PlayerID = z_j_player_season_matches.PlayerID) ON 
Seasons_j.SeasonID = z_j_player_season_matches.SeasonID) ON Innings_j.InningsID = Wickets_j.InningsID) ON (Seasons_j.SeasonID = Matches_j.SeasonID) AND (Matches_j.MatchID = Innings_j.MatchID)
GROUP BY Players.player_name, z_j_player_season_matches.Mat, Seasons_j.Year, Seasons_j.Eleven, Matches_j.SeasonID, z_j_player_season_matches.Mat, Seasons_j.seasonid
ORDER BY "Catches" DESC, "Stumpings" DESC, "Run Outs" DESC, z_j_player_season_matches.Mat DESC;



--drop table zz_temp_yb_batting;
CREATE OR REPLACE VIEW zz_temp_yb_batting AS
SELECT 
    players.player_name AS "Name"
    , Matches_j.Date1
    , Seasons_j.Eleven AS "XI"
    , Matches_j.Round AS "Rd"
    , Matches_j.Opponent as "Opponent"
    , batting_j.score::varchar || (CASE WHEN lower(batting_j.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS "Runs"
    , Batting_j.Balls_Faced::int as "Balls"
    , Batting_j._4s::int as "4s"
    , Batting_j._6s::int as "6s"
    , Batting_j.Batting_Position::int as "Pos"
FROM Seasons_j INNER JOIN (Matches_j INNER JOIN (Innings_j INNER JOIN (Players INNER JOIN Batting_j ON Players.PlayerID = Batting_j.PlayerID) ON Innings_j.InningsID = Batting_j.InningsID) ON Matches_j.MatchID = Innings_j.MatchID) ON Seasons_j.SeasonID = Matches_j.SeasonID
where seasons_j.year in (select max(year) from seasons_j)
and Batting_j.how_out != 'DNB'
ORDER BY players.player_name, Matches_j.Date1, Innings_j.InningsNO
;

--drop table zz_temp_yb_bowling;
CREATE OR REPLACE VIEW zz_temp_yb_bowling AS
SELECT 
    players.player_name AS "Name"
    , Matches_j.Date1 --temp
    , Seasons_j.Eleven AS "XI"
    , Matches_j.Round AS "Rd"
    , Matches_j.Opponent as "Opponent"
    , z_j_Bowling_Figures_All.Ov AS "O"
    , z_j_Bowling_Figures_All.Maidens AS "M"
    , z_j_Bowling_Figures_All.runs AS "R"
    , z_j_Bowling_Figures_All.w AS "W"
    , Innings_j.InningsNO
FROM Seasons_j INNER JOIN (Matches_j INNER JOIN ((Players INNER JOIN z_j_Bowling_Figures_All ON Players.PlayerID = z_j_Bowling_Figures_All.PlayerID) INNER JOIN Innings_j ON z_j_Bowling_Figures_All.InningsID = Innings_j.InningsID) ON Matches_j.MatchID = Innings_j.MatchID) ON Seasons_j.SeasonID = Matches_j.SeasonID
where seasons_j.year in (select max(year) from seasons_j)
ORDER BY players.player_name, Matches_j.Date1, Innings_j.InningsNO;


