

-- Yash games check
/*
23/24 - 15 -> 13 games - 2 forfeits
21/22 - 18 -> 14 games - 4xT20s
20/21 - 17 -> 13 games - 3xT20s, 1 forfeit
winter 2022 - 3 T20s




*/
SELECT 
    players.Surname ||', '|| players.firstname AS Name
    , seasons.year
    , seasons.grade
    , seasons.association
    , Sum(CASE WHEN innings.inningsno=1 Or innings.inningsno=2 then 1 else 0 end) AS Mat

    , Sum(CASE WHEN lower(coalesce(Batting.how_out,'0')) in ('dnb','0','absent out') then 0 else 1 end) AS Inn
    , Sum(CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt','retired not out') then 1 else 0 end) AS "NO"
    , Sum(CASE WHEN lower(batting.how_out) not in ('dnb','0','absent out','not out','forced retirement','retired hurt','retired not out','retired') And batting.score=0 then 1 else 0 end) AS Ducks
    , Sum(Batting._4s) AS Fours
    , Sum(Batting._6s) AS Sixes
    , Sum(CASE WHEN batting.score Between 50 And 99 then 1 else 0 end) AS Fifties
    , Sum(CASE WHEN batting.score>99 then 1 else 0 end) AS Hundreds
    , z_batmax.HS
    , Sum(Batting.Score) AS Total
    , (CASE WHEN Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))=0 then -9 
        else Sum(Batting.Score)/(Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))) end) AS "Average"
    , Sum(batting.balls_faced) AS BF
    , CASE WHEN Count(Batting.Score)-Sum(CASE WHEN lower(batting.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0 then -9
        else Sum(Batting.balls_faced)/(Count(Batting.Score)-Sum(CASE WHEN lower(batting.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) end AS "Average BF"
    , case when Sum(batting.balls_faced)>0 then 100*Sum(batting.score)/Sum(batting.balls_faced) else null end AS "Runs/100 Balls"
    , 100*(Sum(batting._4s)*4+Sum(batting._6s)*6)/(CASE WHEN Sum(batting.score)=0 then 1 else Sum(batting.score) end) AS "Pct Runs in Boundaries"
    , Players.playerid
FROM Players
LEFT JOIN Batting
ON Players.playerid = Batting.playerid
LEFT JOIN Innings 
ON Innings.InningsID = Batting.InningsID
LEFT JOIN Matches 
ON Matches.MatchID = Innings.MatchID
LEFT JOIN z_all_player_dates 
ON z_all_player_dates.playerid = Players.playerid
LEFT JOIN z_batmax 
ON z_batmax.playerid = Players.playerid
left join seasons
on matches.seasonid = seasons.seasonid

where players.Surname = 'Sandhu'

GROUP BY Name
    , z_all_player_dates."First Season"
    , z_all_player_dates."Last Season"
    , z_batmax.HS
    , Players.playerid
    , seasons.year
    , seasons.grade
    , seasons.association
HAVING (((Players.playerid)<>999))
ORDER BY year desc;



