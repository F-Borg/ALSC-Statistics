


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

-- update date for round 6?
