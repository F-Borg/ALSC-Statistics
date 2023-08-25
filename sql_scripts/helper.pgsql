create or replace view z_wickin AS
SELECT
    innings.inningsid
    , sum(case when upper(how_out) not in ('NOT OUT','RETIRED HURT') then 1 else 0 end) as num_wickets
FROM Innings 
INNER JOIN Wickets 
ON Innings.InningsID = Wickets.InningsID
GROUP BY Innings.InningsID
;


create or replace view z_batting_totals AS
SELECT 
    case when b.num_wickets=10 then (b.bat_runs+i.extras)::varchar
        else concat(b.num_wickets,'/',(b.bat_runs+i.extras)) end as Score
    , i.Ov
    , b.bat_runs+i.extras as runs
    , num_wickets as wickets
    , i.inningsno
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Seasons.Eleven
    , Seasons.Grade
    , Seasons.Association
    , matches.MatchID
FROM seasons 
INNER JOIN matches 
ON seasons.SeasonID = matches.SeasonID
INNER JOIN (
    SELECT
        MatchID
        , InningsID
        , inningsno
        , concat(Bat_Overs,'.',coalesce(extra_balls,'0')) as Ov
        , extras
    from Innings 
    where Innings_Type = 'Bat'
    and   Bat_Overs > 0
) i
ON Matches.MatchID = i.MatchID
INNER JOIN (
    SELECT inningsid
        , sum(score) as bat_runs
        , sum(case when upper(how_out) not in ('DNB','NOT OUT','RETIRED','RETIRED HURT','FORCED RETIREMENT','0') then 1 else 0 end) as num_wickets
    FROM batting 
    group by inningsid
) b
ON i.InningsID = b.inningsid
;



create or replace view z_bowling_totals AS
SELECT  
    (CASE WHEN max(z_wickin.num_wickets)=10 then '' else max(z_wickin.num_wickets) ||'/' end) || Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras) AS score
    , Sum(bowling.overs) ||'.'|| Sum(bowling.extra_balls) AS ov
    , 6*(Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras))/Sum(6*bowling.overs+bowling.extra_balls) AS run_rate
    , Matches.Opponent
    , Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras) AS runs
    , Matches.MatchID
    , Innings.InningsNO
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID=Matches.SeasonID
INNER JOIN Innings
ON Matches.MatchID=Innings.MatchID
INNER JOIN z_wickin 
ON Innings.InningsID=z_wickin.InningsID
INNER JOIN Bowling 
ON Innings.InningsID=Bowling.InningsID

GROUP BY Matches.Opponent, Innings.InningsID, Matches.MatchID, Innings.InningsNO
HAVING Innings.InningsNO in (1,2)
ORDER BY Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras) DESC;