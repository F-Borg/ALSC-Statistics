
CREATE OR REPLACE VIEW fielding_01_p1_career_dismissals AS
SELECT 
    z_player_matches_all.Name as "Name"
    , Sum(CASE WHEN lower(wickets.how_out) in ('caught','stumped') then 1 else 0 end) AS "Dismissals"
    , Sum(CASE WHEN lower(wickets.how_out) in ('caught') then 1 else 0 end) AS "Catches"
    , Sum(CASE WHEN lower(wickets.how_out) in ('stumped') then 1 else 0 end) AS "Stumpings"
    , z_player_matches_all.Mat as "Matches"
    --, Players.PlayerID
FROM Seasons INNER JOIN (Matches INNER JOIN (Innings INNER JOIN ((Players INNER JOIN Wickets ON Players.PlayerID = Wickets.assist) INNER JOIN z_player_matches_all ON Players.PlayerID = z_player_matches_all.PlayerID) ON Innings.InningsID = Wickets.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
GROUP BY z_player_matches_all.Name, z_player_matches_all.Mat, Players.PlayerID, Players.PlayerID
ORDER BY "Dismissals" DESC , "Catches" DESC; 


CREATE OR REPLACE VIEW fielding_02_p1_season_dismissals AS
SELECT 
    z_player_matches_all.Name as "Name"
    , Sum(CASE WHEN lower(wickets.how_out) in ('caught','stumped') then 1 else 0 end) AS "Dismissals"
    , Sum(CASE WHEN lower(wickets.how_out) in ('caught') then 1 else 0 end) AS "Catches"
    , Sum(CASE WHEN lower(wickets.how_out) in ('stumped') then 1 else 0 end) AS "Stumpings"
    , max(z_player_matches_all.Mat) AS "Matches"
    --, Players.PlayerID
    , Seasons.Year as "Season"
FROM Seasons INNER JOIN (Matches INNER JOIN (Innings INNER JOIN ((Players INNER JOIN Wickets ON Players.PlayerID = Wickets.assist) INNER JOIN z_player_matches_all ON Players.PlayerID = z_player_matches_all.PlayerID) ON Innings.InningsID = Wickets.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
GROUP BY z_player_matches_all.Name, Players.PlayerID, Players.PlayerID, Seasons.Year
ORDER BY "Dismissals" DESC , "Catches" DESC;   


CREATE OR REPLACE VIEW fielding_03_p1_innings_dismissals AS
SELECT players.player_name AS "Name"
    , Sum(CASE WHEN lower(wickets.how_out) in ('caught','stumped') then 1 else 0 end) AS "Dismissals"
    , Sum(CASE WHEN lower(wickets.how_out) in ('caught') then 1 else 0 end) AS "Catches"
    , Sum(CASE WHEN lower(wickets.how_out) in ('stumped') then 1 else 0 end) AS "Stumpings"
    , Seasons.Year, Matches.Opponent, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons INNER JOIN (Matches INNER JOIN (Innings INNER JOIN (Players INNER JOIN Wickets ON Players.PlayerID = Wickets.assist) ON Innings.InningsID = Wickets.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
GROUP BY players.player_name, Seasons.Year, Matches.Opponent, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association, Wickets.InningsID
ORDER BY "Dismissals" DESC , "Catches" DESC, Year, Round;   


CREATE OR REPLACE VIEW fielding_04_p1_ct_b_combos AS
SELECT 
    Count(Wickets.how_out) AS  "Dismissals"
    , players_1.player_name AS "Fielder"
    , players.player_name AS   "Bowler"
FROM Wickets 
INNER JOIN Players 
ON Wickets.playerID = Players.PlayerID
INNER JOIN Players AS Players_1 
ON Players_1.PlayerID = Wickets.assist
WHERE lower(wickets.how_out) in ('caught')
GROUP BY "Fielder", "Bowler", Wickets.assist, Wickets.playerID
HAVING (Wickets.assist) Is Not Null
ORDER BY Count(Wickets.how_out) DESC, "Bowler";

