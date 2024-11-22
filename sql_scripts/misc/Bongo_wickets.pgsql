SELECT 
    players.player_name AS "Name"
    , Seasons.SeasonID
    , Matches.Date1 --temp
    , Seasons.Eleven AS "XI"
    , Matches.Round AS "Rd"
    , Matches.Opponent as "Opponent"
    , z_Bowling_Figures_All.Ov AS "O"
    , z_Bowling_Figures_All.Maidens AS "M"
    , z_Bowling_Figures_All.runs AS "R"
    , z_Bowling_Figures_All.w AS "W"
    , Innings.InningsNO
FROM Seasons INNER JOIN (Matches INNER JOIN ((Players INNER JOIN z_Bowling_Figures_All ON Players.PlayerID = z_Bowling_Figures_All.PlayerID) INNER JOIN Innings ON z_Bowling_Figures_All.InningsID = Innings.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
WHERE Seasons.SeasonID >= 68
and Players.PlayerID = 48
ORDER BY Seasons.SeasonID, players.player_name, Matches.Date1, Innings.InningsNO;




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
    , Seasons.Year as "Year"
    , players.name_fl
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
where Players.PlayerID = 48
GROUP BY Bowling.PlayerID, Players.player_name, z_bbf_season.Figures, z_player_season_matches.Mat, Seasons.Year, Seasons.Eleven, Seasons.SeasonID, players.name_fl
ORDER BY "Wickets" DESC, "Runs";
