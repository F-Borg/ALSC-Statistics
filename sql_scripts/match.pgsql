CREATE OR REPLACE VIEW all_matches_by_season AS
SELECT 
    z_batting_totals.Eleven
    , z_batting_totals.Year
    , Matches.Round
    , z_batting_totals.runs-z_bowling_totals.runs AS Margin
    , z_batting_totals.Score AS score_for
    , z_bowling_totals.Score AS score_against
    , Matches.Opponent
    , z_batting_totals.Grade
    , Matches.Result
FROM z_batting_totals 
INNER JOIN z_bowling_totals 
ON z_batting_totals.MatchID = z_bowling_totals.MatchID
INNER JOIN Matches 
ON z_bowling_totals.MatchID = Matches.MatchID

WHERE z_batting_totals.inningsno in (1,2)
and   z_bowling_totals.inningsno in (1,2)

ORDER BY z_batting_totals.Eleven, Matches.Date1, z_batting_totals.Grade
;



CREATE OR REPLACE VIEW all_matches_losses AS

SELECT Margin
, w_batting_totals.Score AS runs_for
, w_bowling_totals.Score AS runs_against
, Matches.Opponent
, Matches.Round
, Seasons.Year
, Seasons.Grade
, Seasons.Eleven
FROM all_matches_by_season
GROUP BY w_batting_totals.Score, w_bowling_totals.Score, Matches.Opponent, Matches.Round, Seasons.Year, Seasons.Grade, Seasons.Eleven, Matches.MatchID, w_bowling_totals.totala, w_batting_totals.totalf
ORDER BY -[w_batting_totals]![totalf]+[w_bowling_totals]![totala] DESC;
