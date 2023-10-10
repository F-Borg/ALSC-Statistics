
-- upcoming milestones
select 
    batting_01_summary_ind.playerid
    , batting_01_summary_ind.name
    , case when mod(batting_01_summary_ind.mat,50) > 44 then 'Games: '||batting_01_summary_ind.mat::varchar end as "Games Played"
    , case when mod(total::int,500) > 399 then 'Runs: '||total::varchar end as Runs
    , case when mod("Total Wickets",50) > 39 then 'Wickets: '||"Total Wickets"::varchar end as Wickets
from batting_01_summary_ind
left join z_bocsa
on batting_01_summary_ind.playerid = z_bocsa.playerid
where batting_01_summary_ind."Last Season" in ('2021/22')
and (
    mod(batting_01_summary_ind.mat,50) > 44
    or mod(total::int,500) > 399
    or mod("Total Wickets",50) > 39
)
order by "Games Played", Runs, wickets, playerid
;





