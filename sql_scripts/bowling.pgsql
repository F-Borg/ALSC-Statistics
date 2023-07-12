CREATE OR REPLACE VIEW all_bowling_totals_high AS 
SELECT
    case when z_wickin.num_wickets=10 then (b.bowl_runs+innings.extras)::varchar
        else concat(z_wickin.num_wickets,'/',(b.bowl_runs+innings.extras)) end as Score
    , concat(b.tot_overs,'.',b.tot_extra_balls) as Ov
    , 6*(b.bowl_runs+innings.extras)/(6*b.tot_overs + b.tot_extra_balls) as run_rate
    
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Matches.Ground
    , Seasons.Eleven
    , Seasons.Grade
    , Seasons.Association

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
order by (b.bowl_runs+innings.extras) DESC
;


CREATE OR REPLACE VIEW all_bowling_totals_low AS 
SELECT
    case when z_wickin.num_wickets=10 then (b.bowl_runs+innings.extras)::varchar
        else concat(z_wickin.num_wickets,'/',(b.bowl_runs+innings.extras)) end as Score
    , concat(b.tot_overs,'.',b.tot_extra_balls) as Ov
    , 6*(b.bowl_runs+innings.extras)/(6*b.tot_overs + b.tot_extra_balls) as run_rate
    
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Matches.Ground
    , Seasons.Eleven
    , Seasons.Grade
    , Seasons.Association

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
and   z_wickin.num_wickets = 10
order by (b.bowl_runs+innings.extras)
;


