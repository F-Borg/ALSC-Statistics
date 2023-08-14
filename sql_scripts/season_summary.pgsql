create or replace view season_summary as
SELECT 
    Seasons.Eleven
    , Seasons.Year
    , Count(Matches.MatchID) AS Played
    , Sum(case when matches.result='W2' then 1 else 0 end) AS WO
    , Sum(case when matches.result='W1' then 1 else 0 end) AS W1
    , Sum(case when matches.result= 'D' then 1 else 0 end) AS D
    , Sum(case when matches.result='L1' then 1 else 0 end) AS L1
    , Sum(case when matches.result='L2' then 1 else 0 end) AS LO
    , Seasons.posn as "Position"
    , Seasons.Grade
    , players.surname || ', ' || players.firstname AS Captain
    , players_1.surname || ', ' || players_1.firstname AS "Vice Captain"
    , Seasons.Association

FROM Seasons
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN players 
ON Players.PlayerID = Seasons.Captain
LEFT JOIN players AS players_1 
ON Players_1.PlayerID = Seasons.vice_captain

GROUP BY Seasons.Eleven, Seasons.Year, Seasons.posn, Seasons.Grade, players.surname || ', ' || players.firstname, players_1.surname || ', ' || players_1.firstname, Seasons.Association
ORDER BY Seasons.Eleven;





