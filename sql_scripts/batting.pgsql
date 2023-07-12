CREATE OR REPLACE VIEW all_batting_totals_fast AS 
SELECT 
    6*(b.bat_runs+i.extras) / i.num_balls as "Run Rate"
    , i.Ov
    , case when b.num_wickets=10 then (b.bat_runs+i.extras)::varchar
        else concat(b.num_wickets,'/',(b.bat_runs+i.extras)) end as Score
    
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Seasons.Eleven
    , Seasons.Grade
    , Seasons.Association

FROM seasons 
INNER JOIN matches 
ON seasons.SeasonID = matches.SeasonID
INNER JOIN (
    SELECT
        MatchID
        , InningsID
        , concat(Bat_Overs,'.',coalesce(extra_balls,'0')) as Ov
        , 6*Bat_Overs + coalesce(extra_balls,'0') as num_balls
        , extras
    from Innings 
    where Innings_Type = 'Bat'
    and   Bat_Overs > 15
) i
ON Matches.MatchID = i.MatchID
INNER JOIN (
    SELECT inningsid
        , max(FOW)::DOUBLE PRECISION as batting_tot
        , sum(score) as bat_runs
        , sum(case when upper(how_out) not in ('DNB','NOT OUT','RETIRED','RETIRED HURT','FORCED RETIREMENT','0') then 1 else 0 end) as num_wickets
    FROM batting 
    group by inningsid
) b
ON i.InningsID = b.inningsid

order by (b.bat_runs+i.extras) / i.num_balls desc
;



CREATE OR REPLACE VIEW all_batting_totals_high AS 
SELECT 
    case when b.num_wickets=10 then (b.bat_runs+i.extras)::varchar
        else concat(b.num_wickets,'/',(b.bat_runs+i.extras)) end as Score
    , i.Ov
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Seasons.Eleven
    , Seasons.Grade
    , Seasons.Association

FROM seasons 
INNER JOIN matches 
ON seasons.SeasonID = matches.SeasonID
INNER JOIN (
    SELECT
        MatchID
        , InningsID
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

order by (b.bat_runs+i.extras) desc
;



CREATE OR REPLACE VIEW all_batting_totals_low AS 
SELECT 
    (b.bat_runs+i.extras) as Score
    , i.Ov
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Seasons.Eleven
    , Seasons.Grade
    , Seasons.Association

FROM seasons 
INNER JOIN matches 
ON seasons.SeasonID = matches.SeasonID
INNER JOIN (
    SELECT
        MatchID
        , InningsID
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
where b.num_wickets >= 10
order by (b.bat_runs+i.extras)
;



CREATE OR REPLACE VIEW all_batting_totals_slow AS 
SELECT 
    6*(b.bat_runs+i.extras) / i.num_balls as "Run Rate"
    , i.Ov
    , case when b.num_wickets=10 then (b.bat_runs+i.extras)::varchar
        else concat(b.num_wickets,'/',(b.bat_runs+i.extras)) end as Score
    
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Seasons.Eleven
    , Seasons.Grade
    , Seasons.Association

FROM seasons 
INNER JOIN matches 
ON seasons.SeasonID = matches.SeasonID
INNER JOIN (
    SELECT
        MatchID
        , InningsID
        , concat(Bat_Overs,'.',coalesce(extra_balls,'0')) as Ov
        , 6*Bat_Overs + coalesce(extra_balls,'0') as num_balls
        , extras
    from Innings 
    where Innings_Type = 'Bat'
    and   Bat_Overs > 15
) i
ON Matches.MatchID = i.MatchID
INNER JOIN (
    SELECT inningsid
        , max(FOW)::DOUBLE PRECISION as batting_tot
        , sum(score) as bat_runs
        , sum(case when upper(how_out) not in ('DNB','NOT OUT','RETIRED','RETIRED HURT','FORCED RETIREMENT','0') then 1 else 0 end) as num_wickets
    FROM batting 
    group by inningsid
) b
ON i.InningsID = b.inningsid

order by (b.bat_runs+i.extras) / i.num_balls
;




