create or replace view z_wickin AS
SELECT
    innings.inningsid
    , sum(case when upper(how_out) not in ('DNB','NOT OUT','RETIRED','RETIRED HURT','FORCED RETIREMENT','0') then 1 else 0 end) as num_wickets
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
    case when z_wickin.num_wickets=10 then (b.bowl_runs+innings.extras)::varchar
        else concat(z_wickin.num_wickets,'/',(b.bowl_runs+innings.extras)) end as Score
    , concat(b.tot_overs,'.',b.tot_extra_balls) as Ov
    , 6*(b.bowl_runs+innings.extras)/(6*b.tot_overs + b.tot_extra_balls) as run_rate
    , b.bowl_runs+innings.extras as runs
    , z_wickin.num_wickets as wickets
    , innings.inningsno
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Matches.Ground
    , Seasons.Eleven
    , Seasons.Grade
    , Seasons.Association
    , matches.MatchID
FROM seasons
inner join matches
ON seasons.SeasonID = matches.SeasonID
INNER JOIN innings
on Matches.MatchID = Innings.MatchID
inner join (
    SELECT inningsid
        , sum(wides+no_balls+runs_off_bat) as bowl_runs
        , sum(overs) as tot_overs
        , sum(extra_balls) as tot_extra_balls
    FROM bowling
    GROUP BY inningsid
) b
on innings.inningsid = b.inningsid
inner join z_wickin
on innings.inningsid = z_wickin.inningsid
where innings.innings_type = 'Bowl'
and   b.tot_overs > 0
;
