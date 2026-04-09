
--drop view yb_i_01_season_summary;
CREATE OR REPLACE VIEW yb_i_01_season_summary AS
SELECT 
    Seasons_i.SeasonID
    , Matches_i.Round
    , Matches_i.Ground
    , Matches_i.result
    , team_i_05_scores_highest.Opponent
    , team_i_05_scores_highest.Score AS bat_total
    , team_i_07_scores_opp_highest.Score AS bowl_total
    , case when Batting_i.How_Out = 'Not Out' then Batting_i.Score::varchar || '*'
        else Batting_i.Score::varchar end as bat_score
    , players.name_fl AS bat_name 
    , z_i_Bowling_Figures_All.Figures
    , players1.name_fl AS bowl_name 
    , Innings_i.InningsNO

FROM Seasons_i
INNER JOIN Matches_i 
ON Seasons_i.SeasonID = Matches_i.SeasonID

LEFT JOIN team_i_05_scores_highest 
ON team_i_05_scores_highest.Eleven = Seasons_i.Eleven
AND team_i_05_scores_highest.Year = Seasons_i.Year
AND team_i_05_scores_highest.Round = Matches_i.Round
AND team_i_05_scores_highest.Opponent = Matches_i.Opponent

LEFT JOIN  team_i_07_scores_opp_highest
ON  team_i_07_scores_opp_highest.Eleven = Seasons_i.Eleven
AND team_i_07_scores_opp_highest.Round = Matches_i.Round
AND team_i_07_scores_opp_highest.Year = Seasons_i.Year

LEFT JOIN Innings_i AS Innings_1
ON Matches_i.MatchID = Innings_1.MatchID
LEFT JOIN z_i_Bowling_Figures_All 
ON z_i_Bowling_Figures_All.InningsID = Innings_1.InningsID
AND z_i_Bowling_Figures_All.w>1
LEFT JOIN Players AS players1 
ON players1.PlayerID = z_i_Bowling_Figures_All.PlayerID

LEFT JOIN Innings_i 
ON Matches_i.MatchID = Innings_i.MatchID
LEFT JOIN Batting_i 
ON Innings_i.InningsID = Batting_i.InningsID
AND Batting_i.Score>19
LEFT JOIN Players 
ON Players.PlayerID = Batting_i.PlayerID

--where Innings_i.InningsNO in (1,2) 
ORDER BY Seasons_i.seasonid, Matches_i.Date1, Batting_i.Score DESC , z_i_Bowling_Figures_All.w DESC;

--select * from yb_i_01_season_summary


--DROP VIEW yb_i_02_batting_summary;
CREATE OR REPLACE VIEW yb_i_02_batting_summary AS
SELECT 
    Batting_i.PlayerID
    , players.name_fl
    , Matches_i.seasonid
    , Seasons_i.Year as "Year"
    , players.player_name AS "Name"
    , Sum(CASE WHEN innings_i.inningsno=1 Or innings_i.inningsno=2 then 1 else 0 end) AS "Matches"
    , Sum(CASE WHEN lower(coalesce(Batting_i.how_out,'0')) in ('dnb','0','absent out') then 0 else 1 end) AS "Innings"
    , Sum(case when lower(batting_i.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end) AS "Not Outs"
    , Sum(Batting_i._4s) AS "Fours"
    , Sum(Batting_i._6s) AS "Sixes"
    , Sum(CASE WHEN lower(batting_i.how_out) not in ('dnb','0','absent out','not out','forced retirement','retired hurt','retired not out','retired') And batting_i.score=0 then 1 else 0 end) AS "Ducks"
    , Sum((CASE WHEN batting_i.score>19 then 1 else 0 end)) AS "20s"
    , z_i_batmax_season.hs as "Highest Score"
    , Sum(Batting_i.Score) AS "Total Runs"
    , (CASE WHEN Count(Batting_i.Score)-Sum((CASE WHEN lower(batting_i.how_out) in ('dnb','0','not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))=0 then -9 
        else Sum(Batting_i.Score)/(Count(Batting_i.Score)-Sum((CASE WHEN lower(batting_i.how_out) in ('dnb','0','not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))) end) AS "Average"
    , 100*(Sum(batting_i._4s)*4+Sum(batting_i._6s)*6)/(CASE WHEN Sum(batting_i.score)=0 then 1 else Sum(batting_i.score) end) AS "% of Runs in Boundaries"

FROM Seasons_i 
INNER JOIN Matches_i 
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN Innings_i 
ON Matches_i.MatchID = Innings_i.MatchID
INNER JOIN Batting_i 
ON Innings_i.InningsID = Batting_i.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting_i.PlayerID 
INNER JOIN z_i_batmax_season 
ON Seasons_i.SeasonID = z_i_batmax_season.SeasonID
AND z_i_batmax_season.PlayerID = Players.PlayerID

GROUP BY Batting_i.PlayerID, players.player_name, z_i_batmax_season.HS, Seasons_i.Year, Seasons_i.Eleven, Matches_i.SeasonID, players.name_fl
ORDER BY Sum(Batting_i.Score) DESC, "Average" DESC
;

--select * from yb_i_02_batting_summary;

--no partnership info for inclusive

--DROP VIEW yb_i_04_bowling_summary;
CREATE OR REPLACE VIEW yb_i_04_bowling_summary AS
SELECT 
    Players.player_name AS "Name"
    , z_i_player_season_matches.mat as "Matches"
    , floor((Sum(overs)*6+Sum(bowling_i.extra_balls))/6)::varchar || 
        CASE WHEN floor((Sum(overs)*6+Sum(bowling_i.extra_balls))/6)=(Sum(overs)*6+Sum(bowling_i.extra_balls))/6 THEN '' 
            ELSE '.' || Round(6*((Sum(overs)*6+Sum(bowling_i.extra_balls))/6-floor((Sum(overs)*6+Sum(bowling_i.extra_balls))/6))) END AS "Overs"
    , Sum(overs)*6+Sum(bowling_i.extra_balls) AS "Balls"
    , Sum(Bowling_i.Maidens) AS "Maidens"
    , Sum(z_i_Bowling_Figures_All.runs) AS "Runs"
    , Sum(z_i_Bowling_Figures_All.w) AS "Wickets"
    , CASE WHEN Sum(z_i_Bowling_Figures_All.w) > 0 then Sum(z_i_Bowling_Figures_All.runs)/Sum(z_i_Bowling_Figures_All.w) ELSE -9 END AS "Average"
    , z_i_bbf_season.Figures AS "Best Bowling Figures"
    , CASE WHEN Sum(z_i_Bowling_Figures_All.w) > 0 then (Sum(overs)*6+Sum(bowling_i.extra_balls))/Sum(z_i_Bowling_Figures_All.w) ELSE -9 END AS "Strike Rate"
    , 6*Sum(z_i_Bowling_Figures_All.runs)/(Sum(overs)*6+Sum(bowling_i.extra_balls)) AS "Economy Rate"
    , Seasons_i.SeasonID
    , Bowling_i.PlayerID
    , Seasons_i.Year as "Year"
    , players.name_fl
FROM Seasons_i
INNER JOIN Matches_i 
ON Seasons_i.SeasonID = Matches_i.SeasonID 
INNER JOIN Innings_i 
ON Matches_i.MatchID = Innings_i.MatchID
INNER JOIN Bowling_i 
ON Innings_i.InningsID = Bowling_i.InningsID 

INNER JOIN Players 
ON Players.PlayerID = Bowling_i.PlayerID 

INNER JOIN z_i_bbf_season 
ON z_i_bbf_season.PlayerID = Players.PlayerID 
AND Seasons_i.SeasonID = z_i_bbf_season.SeasonID

INNER JOIN z_i_Bowling_Figures_All 
ON z_i_Bowling_Figures_All.PlayerID = Bowling_i.PlayerID
AND z_i_Bowling_Figures_All.InningsID = Bowling_i.InningsID

INNER JOIN z_i_player_season_matches 
ON Seasons_i.SeasonID = z_i_player_season_matches.SeasonID
AND Players.PlayerID = z_i_player_season_matches.PlayerID

--where Matches_i.SeasonID=73
GROUP BY Bowling_i.PlayerID, Players.player_name, z_i_bbf_season.Figures, z_i_player_season_matches.Mat, Seasons_i.Year, Seasons_i.Eleven, Seasons_i.SeasonID, players.name_fl
ORDER BY "Wickets" DESC, Sum(overs)*6+Sum(bowling_i.extra_balls) desc;

--select * from yb_i_04_bowling_summary;


CREATE OR REPLACE VIEW yb_i_05_fielding_summary AS
SELECT 
    Players.player_name AS "Name"
    , z_i_player_season_matches.Mat as "Matches_i"
    , Sum(CASE WHEN lower(wickets_i.how_out)='caught' then 1 else 0 end) AS "Catches"
    , Sum(CASE WHEN lower(wickets_i.how_out)='stumped' then 1 else 0 end) AS "Stumpings"
    , Sum(CASE WHEN lower(wickets_i.how_out)='run out' then 1 else 0 end) AS "Run Outs"
    , Seasons_i.seasonid
FROM Matches_i 
INNER JOIN (Innings_i INNER JOIN (Seasons_i INNER JOIN ((Players INNER JOIN Wickets_i ON Players.PlayerID = Wickets_i.assist) INNER JOIN z_i_player_season_matches ON Players.PlayerID = z_i_player_season_matches.PlayerID) ON 
Seasons_i.SeasonID = z_i_player_season_matches.SeasonID) ON Innings_i.InningsID = Wickets_i.InningsID) ON (Seasons_i.SeasonID = Matches_i.SeasonID) AND (Matches_i.MatchID = Innings_i.MatchID)
GROUP BY Players.player_name, z_i_player_season_matches.Mat, Seasons_i.Year, Seasons_i.Eleven, Matches_i.SeasonID, z_i_player_season_matches.Mat, Seasons_i.seasonid
ORDER BY "Catches" DESC, "Stumpings" DESC, "Run Outs" DESC, z_i_player_season_matches.Mat DESC;


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



--drop table zz_temp_yb_i_batting;
CREATE OR REPLACE VIEW zz_temp_yb_i_batting AS
SELECT 
    players.player_name AS "Name"
    , Matches_i.Date1
    , Seasons_i.Eleven AS "XI"
    , Matches_i.Round AS "Rd"
    , Matches_i.Opponent as "Opponent"
    , batting_i.score::varchar || (CASE WHEN lower(batting_i.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS "Runs"
    , Batting_i._4s::int as "4s"
    , Batting_i._6s::int as "6s"
    , Batting_i.Batting_Position::int as "Pos"
FROM Seasons_i INNER JOIN (Matches_i INNER JOIN (Innings_i INNER JOIN (Players INNER JOIN Batting_i ON Players.PlayerID = Batting_i.PlayerID) ON Innings_i.InningsID = Batting_i.InningsID) ON Matches_i.MatchID = Innings_i.MatchID) ON Seasons_i.SeasonID = Matches_i.SeasonID
where Seasons_i.year in (select max(year) from Seasons_i)
and Batting_i.how_out != 'DNB'
ORDER BY players.player_name, Matches_i.Date1, Innings_i.InningsNO
;

--drop table zz_temp_yb_i_bowling;
CREATE OR REPLACE VIEW zz_temp_yb_i_bowling AS
SELECT 
    players.player_name AS "Name"
    , Matches_i.Date1 --temp
    , Seasons_i.Eleven AS "XI"
    , Matches_i.Round AS "Rd"
    , Matches_i.Opponent as "Opponent"
    , z_i_Bowling_Figures_All.Ov AS "O"
    , z_i_Bowling_Figures_All.Maidens AS "M"
    , z_i_Bowling_Figures_All.runs AS "R"
    , z_i_Bowling_Figures_All.w AS "W"
    , Innings_i.InningsNO
FROM Seasons_i INNER JOIN (Matches_i INNER JOIN ((Players INNER JOIN z_i_Bowling_Figures_All ON Players.PlayerID = z_i_Bowling_Figures_All.PlayerID) INNER JOIN Innings_i ON z_i_Bowling_Figures_All.InningsID = Innings_i.InningsID) ON Matches_i.MatchID = Innings_i.MatchID) ON Seasons_i.SeasonID = Matches_i.SeasonID
where Seasons_i.year in (select max(year) from Seasons_i)
ORDER BY players.player_name, Matches_i.Date1, Innings_i.InningsNO;


