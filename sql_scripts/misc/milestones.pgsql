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
        sum(case when "Year" = '2022/23' then "Matches" else 0 end) as "Season Matches", 
        sum(case when "Year" <= '2022/23' then "Matches" else 0 end) as "Total Matches"
    FROM yb_02_batting_summary
    group by playerid, name_fl
    having sum(case when "Year" = '2022/23' then "Matches" else 0 end) > 0
    ) a
WHERE mod("Total Matches"::int,50) < "Season Matches"
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
        sum(case when "Year" = '2022/23' then "Total Runs" else 0 end) as "Season Runs", 
        sum(case when "Year" <= '2022/23' then "Total Runs" else 0 end) as "Total Runs"
    FROM yb_02_batting_summary
    group by playerid, name_fl
    having sum(case when "Year" = '2022/23' then "Total Runs" else 0 end) > 0
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
        sum(case when Seasons.Year = '2022/23' then z_Bowling_Figures_All.w else 0 end) as "Season Wickets", 
        sum(case when Seasons.Year <= '2022/23' then z_Bowling_Figures_All.w else 0 end) as "Total Wickets"
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
    having sum(case when Seasons.Year = '2022/23' then z_Bowling_Figures_All.w else 0 end) > 0
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
where batting_01_summary_ind."Last Season" in ('2024/25','2023/24')
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
where batting_01_summary_ind."Last Season" in ('2024/25')
order by stats
;

