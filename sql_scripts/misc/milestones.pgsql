CREATE OR REPLACE VIEW yb_milestones_01_matches AS
SELECT
    "Name",
    "Total Matches" - mod("Total Matches"::int,50) as "Milestone",
    "Season Matches",
    "Total Matches",
    playerid
FROM (
    SELECT 
        name_fl as "Name",
        playerid,
        sum(case when "Year" = (select max(year) from seasons) then "Matches" else 0 end) as "Season Matches", 
        sum("Matches") as "Total Matches"
    FROM yb_02_batting_summary
    group by playerid, name_fl
    having sum(case when "Year" = (select max(year) from seasons) then "Matches" else 0 end) >= 0
    ) a
--WHERE mod("Total Matches"::int,50) <= "Season Matches"
WHERE "Total Matches" - mod("Total Matches"::int,50) >= 0
and "Season Matches" > 0
;


CREATE OR REPLACE VIEW yb_milestones_02_bat AS
SELECT
    "Name",
    "Total Runs" - mod("Total Runs"::int,500) as "Milestone",
    "Season Runs",
    "Total Runs",
    playerid
FROM (
    SELECT 
        name_fl as "Name",
        playerid,
        sum(case when "Year" = (select max(year) from seasons) then "Total Runs" else 0 end) as "Season Runs", 
        sum(case when "Year" <= (select max(year) from seasons) then "Total Runs" else 0 end) as "Total Runs"
    FROM yb_02_batting_summary
    group by playerid, name_fl
    having sum(case when "Year" = (select max(year) from seasons) then "Total Runs" else 0 end) > 0
    ) a
WHERE mod("Total Runs"::int,500) < "Season Runs"
;


--drop view yb_milestones_03_bowl;
CREATE OR REPLACE VIEW yb_milestones_03_bowl AS
SELECT
    "Name",
    "Total Wickets" - mod("Total Wickets"::int,50) as "Milestone",
    "Season Wickets",
    "Total Wickets",
    playerid
FROM (
    SELECT 
        Players.name_fl AS "Name",
        Players.playerid,
        sum(case when Seasons.Year in (select max(year) from seasons) then z_Bowling_Figures_All.w else 0 end) as "Season Wickets", 
        sum(case when Seasons.Year <= (select max(year) from seasons) then z_Bowling_Figures_All.w else 0 end) as "Total Wickets"
    FROM Seasons
    INNER JOIN Matches 
    ON Seasons.SeasonID = Matches.SeasonID 
    INNER JOIN Innings 
    ON Matches.MatchID = Innings.MatchID
    INNER JOIN Bowling 
    ON Innings.InningsID = Bowling.InningsID 

    INNER JOIN Players 
    ON Players.PlayerID = Bowling.PlayerID 

    INNER JOIN z_Bowling_Figures_All 
    ON z_Bowling_Figures_All.PlayerID = Bowling.PlayerID
    AND z_Bowling_Figures_All.InningsID = Bowling.InningsID

    group by Players.playerid, Players.name_fl
    having sum(case when Seasons.Year = (select max(year) from seasons) then z_Bowling_Figures_All.w else 0 end) > 0
    ) a
WHERE mod("Total Wickets"::int,50) < "Season Wickets"
;



-- upcoming milestones
select 
    --batting_01_summary_ind.playerid
    --, batting_01_summary_ind.name
    players.name_fl||': '||
        (case when mod(batting_01_summary_ind.mat,50) > 44 then batting_01_summary_ind.mat::varchar||' games ' else '' end)||
        (case when mod(total::int,500) > 349 then total::text||' runs ' else '' end)||
        (case when mod("Total Wickets",50) > 39 then "Total Wickets"::varchar||' wickets' else '' end) as milestones
    
from batting_01_summary_ind
left join z_bocsa
on batting_01_summary_ind.playerid = z_bocsa.playerid
join players
on batting_01_summary_ind.playerid = players.playerid
where batting_01_summary_ind."Last Season" in ('2024/25','2025/26')
and (
    mod(batting_01_summary_ind.mat,50) > 44
    or mod(total::int,500) > 349
    or mod("Total Wickets",50) > 39
)
order by milestones
;


-- all players this year
select 
    --batting_01_summary_ind.playerid
    --, batting_01_summary_ind.name
    players.name_fl||': '||
        batting_01_summary_ind.mat::varchar||' games ' ||
        total::text||' runs ' ||
        "Total Wickets"::varchar||' wickets' as stats
    
from batting_01_summary_ind
left join z_bocsa
on batting_01_summary_ind.playerid = z_bocsa.playerid
join players
on batting_01_summary_ind.playerid = players.playerid
where batting_01_summary_ind."Last Season" in ((select max(year) from seasons))
order by stats
;


-- Ducks
select name, ducks, inn, round(1.0*ducks/greatest((inn-"NO"),1),2) as ducks_per_dismissal, bf, round(100*ducks/greatest(bf,1)::numeric,2) as ducks_per_100_balls 
, "Last Season"
from batting_01_summary_ind
order by ducks desc, ducks_per_dismissal desc
;

-- Balls Faced
select name, bf, "Average BF", "Runs/100 Balls"
from batting_01_summary_ind
where bf is not null
order by bf desc
;

-- Balls Faced without a 6
select name, bf 
from batting_01_summary_ind
where bf is not null
and sixes = 0
order by bf desc
;

-- balls bowled
select 
b.name, b.balls, b.mdns 
from bowling_01_summary_ind b
join z_all_player_dates z
on z.playerid = b.playerid
where balls > 0   
--and z."Last Season" = '2024/25'
order by balls desc
;

-- catches
select 
b.name, b.catches, b.stumpings 
from bowling_01_summary_ind b
join z_all_player_dates z
on z.playerid = b.playerid
-- where z."Last Season" = '2024/25'
order by catches desc
;



-- nb / w 
-- select name, extras, nb, w, round(6*rate,2) as extras_per_over
-- from bowling_16_p4_extras_high
-- order by extras desc

SELECT players.player_name AS Name
    , floor((Sum(overs)*6+Sum(bowling.extra_balls))/6)::varchar || 
        CASE WHEN floor((Sum(overs)*6+Sum(bowling.extra_balls))/6)=(Sum(overs)*6+Sum(bowling.extra_balls))/6 THEN '' 
            ELSE '.' || Round(6*((Sum(overs)*6+Sum(bowling.extra_balls))/6-floor((Sum(overs)*6+Sum(bowling.extra_balls))/6))) END AS overs
    
    , Sum(bowling.wides)+Sum(bowling.no_balls) AS Extras
    , Sum(Bowling.no_balls) AS NB
    , Sum(Bowling.Wides) AS W
    -- , (Sum(bowling.wides)+Sum(bowling.no_balls))/(Sum(overs)*6+Sum(bowling.extra_balls)) AS Rate
    , round(6*(Sum(bowling.wides)+Sum(bowling.no_balls))/(Sum(overs)*6+Sum(bowling.extra_balls)),2) as extras_per_over
FROM Seasons INNER JOIN (Matches INNER JOIN (Innings INNER JOIN (Players INNER JOIN Bowling ON Players.PlayerID = Bowling.PlayerID) ON Innings.InningsID = Bowling.InningsID) ON Matches.MatchID = Innings.MatchID) ON Seasons.SeasonID = Matches.SeasonID
WHERE (Seasons.SeasonID)>3
GROUP BY players.player_name, Bowling.PlayerID
HAVING (Sum(overs)*6+Sum(bowling.extra_balls))>119
--ORDER BY extras_per_over DESC;
ORDER BY Extras DESC;



select * from bowling_09_p3_best_figs
