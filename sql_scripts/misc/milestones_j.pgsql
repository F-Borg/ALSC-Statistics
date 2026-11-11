CREATE OR REPLACE VIEW yb_milestones_01_matches AS
SELECT
    "Name",
    "Total Matches_j" - mod("Total Matches_j"::int,50) as "Milestone",
    "Season Matches_j",
    "Total Matches_j",
    playerid
FROM (
    SELECT 
        name_fl as "Name",
        playerid,
        sum(case when "Year" = (select max(year) from seasons_j) then "Matches_j" else 0 end) as "Season Matches_j", 
        sum("Matches_j") as "Total Matches_j"
    FROM yb_02_batting_summary
    group by playerid, name_fl
    having sum(case when "Year" = (select max(year) from seasons_j) then "Matches_j" else 0 end) >= 0
    ) a
--WHERE mod("Total Matches_j"::int,50) <= "Season Matches_j"
WHERE "Total Matches_j" - mod("Total Matches_j"::int,50) >= 0
and "Season Matches_j" > 0
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
        sum(case when "Year" = (select max(year) from seasons_j) then "Total Runs" else 0 end) as "Season Runs", 
        sum(case when "Year" <= (select max(year) from seasons_j) then "Total Runs" else 0 end) as "Total Runs"
    FROM yb_02_batting_summary
    group by playerid, name_fl
    having sum(case when "Year" = (select max(year) from seasons_j) then "Total Runs" else 0 end) > 0
    ) a
WHERE mod("Total Runs"::int,500) < "Season Runs"
;


--drop view yb_milestones_03_bowl;
CREATE OR REPLACE VIEW yb_milestones_03_bowl AS
SELECT
    "Name",
    "Total Wickets_j" - mod("Total Wickets_j"::int,50) as "Milestone",
    "Season Wickets_j",
    "Total Wickets_j",
    playerid
FROM (
    SELECT 
        Players.name_fl AS "Name",
        Players.playerid,
        sum(case when Seasons_j.Year in (select max(year) from seasons_j) then z_j_Bowling_Figures_All.w else 0 end) as "Season Wickets_j", 
        sum(case when Seasons_j.Year <= (select max(year) from seasons_j) then z_j_Bowling_Figures_All.w else 0 end) as "Total Wickets_j"
    FROM Seasons_j
    INNER JOIN Matches_j 
    ON Seasons_j.SeasonID = Matches_j.SeasonID 
    INNER JOIN Innings_j 
    ON Matches_j.MatchID = Innings_j.MatchID
    INNER JOIN Bowling_j 
    ON Innings_j.InningsID = Bowling_j.InningsID 

    INNER JOIN Players 
    ON Players.PlayerID = Bowling_j.PlayerID 

    INNER JOIN z_j_Bowling_Figures_All 
    ON z_j_Bowling_Figures_All.PlayerID = Bowling_j.PlayerID
    AND z_j_Bowling_Figures_All.InningsID = Bowling_j.InningsID

    group by Players.playerid, Players.name_fl
    having sum(case when Seasons_j.Year = (select max(year) from seasons_j) then z_j_Bowling_Figures_All.w else 0 end) > 0
    ) a
WHERE mod("Total Wickets_j"::int,50) < "Season Wickets_j"
;


-- upcoming milestones
select 
    players.name_fl||': '||
        (case when mod(batting_j_01_summary_ind.mat,50) > 44 then batting_j_01_summary_ind.mat::varchar||' games ' else '' end)||
        (case when mod(total::int,500) > 349 then total::text||' runs ' else '' end)||
        (case when mod("Total Wickets_j",50) > 39 then "Total Wickets_j"::varchar||' wickets_j' else '' end) as milestones
    
from batting_j_01_summary_ind
left join z_j_bocsa
on batting_j_01_summary_ind.playerid = z_j_bocsa.playerid
join players
on batting_j_01_summary_ind.playerid = players.playerid
where batting_j_01_summary_ind."Last Season" in ('2026/27','2025/26')
and (
    mod(batting_j_01_summary_ind.mat,50) > 44
    or mod(total::int,500) > 349
    or mod("Total Wickets_j",50) > 39
)
and players.name_fl not in ('Mitesh Shah','Jack Bury')
order by milestones
;

--inclusive also
select 
    name_fl||': '||
        (case when mod(mat,50) > 44 then mat::varchar||' games ' else '' end)||
        (case when mod(runs,500) > 349 then runs::text||' runs ' else '' end)||
        (case when mod(a.wickets_j,50) > 39 then wickets_j::varchar||' wickets_j' else '' end) as milestones
from (
    select 
        --batting_j_01_summary_ind.playerid
        --, batting_j_01_summary_ind.name
        players.name_fl
        , coalesce(batting_j_01_summary_ind.mat,0)+coalesce(batting_i_01_summary_ind.mat,0) as mat
        , coalesce(batting_j_01_summary_ind.total,0)::int+coalesce(batting_i_01_summary_ind.total,0)::int as runs
        , coalesce(z_j_bocsa."Total Wickets_j",0)+coalesce(z_j_i_bocsa."Total Wickets_j",0) as wickets_j

    from players 
    left join batting_j_01_summary_ind
    on players.playerid = batting_j_01_summary_ind.playerid
    left join  z_j_bocsa
    on players.playerid = z_j_bocsa.playerid

    left join batting_i_01_summary_ind
    on players.playerid = batting_i_01_summary_ind.playerid
    left join  z_j_i_bocsa
    on players.playerid = z_j_i_bocsa.playerid

    where (batting_j_01_summary_ind."Last Season" in ('2026/27','2025/26') or batting_i_01_summary_ind."Last Season" in ('2026/27','2025/26'))
    and players.name_fl not in ('Mitesh Shah','Jack Bury')
) a
where (
    mod(mat,50) > 44
    or mod(runs::int,500) > 349
    or mod(wickets_j,50) > 39
)
order by milestones
;




-- all players this year
select 
    --batting_j_01_summary_ind.playerid
    --, batting_j_01_summary_ind.name
    players.name_fl||': '||
        batting_j_01_summary_ind.mat::varchar||' games ' ||
        total::text||' runs ' ||
        coalesce("Total Wickets_j"::varchar,'0')||' wickets_j' as stats
    
from batting_j_01_summary_ind
left join z_j_bocsa
on batting_j_01_summary_ind.playerid = z_j_bocsa.playerid
left join players
on batting_j_01_summary_ind.playerid = players.playerid
where batting_j_01_summary_ind."Last Season" in ((select max(year) from seasons_j))
order by stats
;


-- Ducks
select name, ducks, inn, round(1.0*ducks/greatest((inn-"NO"),1),2) as ducks_per_dismissal, bf, round(100*ducks/greatest(bf,1)::numeric,2) as ducks_per_100_balls 
, "Last Season"
from batting_j_01_summary_ind
order by ducks desc, ducks_per_dismissal desc
;

-- Balls Faced
select name, bf, "Average BF", "Runs/100 Balls"
from batting_j_01_summary_ind
where bf is not null
order by bf desc
;

-- Balls Faced without a 6
select name, bf 
from batting_j_01_summary_ind
where bf is not null
and sixes = 0
order by bf desc
;

-- balls bowled
select 
b.name, b.balls, b.mdns 
from bowling_j_01_summary_ind b
join z_j_all_player_dates z
on z.playerid = b.playerid
where balls > 0   
--and z."Last Season" = '2024/25'
order by balls desc
;

-- catches
select 
b.name, b.catches, b.stumpings 
from bowling_j_01_summary_ind b
join z_j_all_player_dates z
on z.playerid = b.playerid
-- where z."Last Season" = '2024/25'
order by catches desc
;



-- nb / w 
-- select name, extras, nb, w, round(6*rate,2) as extras_per_over
-- from bowling_j_16_p4_extras_high
-- order by extras desc

SELECT players.player_name AS Name
    , floor((Sum(overs)*6+Sum(bowling_j.extra_balls))/6)::varchar || 
        CASE WHEN floor((Sum(overs)*6+Sum(bowling_j.extra_balls))/6)=(Sum(overs)*6+Sum(bowling_j.extra_balls))/6 THEN '' 
            ELSE '.' || Round(6*((Sum(overs)*6+Sum(bowling_j.extra_balls))/6-floor((Sum(overs)*6+Sum(bowling_j.extra_balls))/6))) END AS overs
    
    , Sum(bowling_j.wides)+Sum(bowling_j.no_balls) AS Extras
    , Sum(Bowling_j.no_balls) AS NB
    , Sum(Bowling_j.Wides) AS W
    -- , (Sum(bowling_j.wides)+Sum(bowling_j.no_balls))/(Sum(overs)*6+Sum(bowling_j.extra_balls)) AS Rate
    , round(6*(Sum(bowling_j.wides)+Sum(bowling_j.no_balls))/(Sum(overs)*6+Sum(bowling_j.extra_balls)),2) as extras_per_over
FROM Seasons_j INNER JOIN (Matches_j INNER JOIN (Innings_j INNER JOIN (Players INNER JOIN Bowling_j ON Players.PlayerID = Bowling_j.PlayerID) ON Innings_j.InningsID = Bowling_j.InningsID) ON Matches_j.MatchID = Innings_j.MatchID) ON Seasons_j.SeasonID = Matches_j.SeasonID
WHERE (Seasons_j.SeasonID)>3
GROUP BY players.player_name, Bowling_j.PlayerID
HAVING (Sum(overs)*6+Sum(bowling_j.extra_balls))>119
--ORDER BY extras_per_over DESC;
ORDER BY Extras DESC;



select * from bowling_j_09_p3_best_figs;

select * from batting_j_02_career_runs

select * from yb_milestones_01_matches 
order by "Total Matches_j" desc


select * from innings_j;


select * from fielding_j_04_p1_ct_b_combos
where "Fielder" = 'Taylor, Peter'

select "Fielder", count(*) as _count from fielding_j_04_p1_ct_b_combos
group by "Fielder"
order by _count desc


select "name", mat  from z_j_player_matches_all