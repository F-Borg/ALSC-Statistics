select max(inningsid) from batting


--batting
select players.name_fl as player_name
    , case when length(bowler_name)>0
        then how_out||': '||bowler_name
      else how_out end as how_out
    , batting.score
    , batting.balls_faced
    , batting._4s
    , batting._6s
    , case when balls_faced > 0 then round((100*score/balls_faced)::numeric,1) end as strike_rate

from batting 
join players
on players.playerid = batting.playerid
where batting.inningsid = 1926
order by batting_position;



select * from wickets where inningsid = 1922;

select lower(how_out), count(*) from wickets group by 1;

--opposition batting
select 
    batter_name
    , case when lower(how_out) in ('caught')
        then 'c: '||COALESCE(assist.name_fl,'')||' b: '||players.name_fl
      when lower(how_out) in ('stumped')
        then 'st: '||COALESCE(assist.name_fl,'')||' b: '||players.name_fl
      when lower(how_out) in ('bowled','lbw','hit wicket','c & b')
        then lower(how_out)||': '||players.name_fl
      when lower(how_out) in ('run out') 
        then 'run out: '||COALESCE(assist.name_fl,'')
      else how_out
      end as how_out
from wickets 
left join players
on players.playerid = wickets.playerid
left join players as assist
on assist.playerid = wickets.assist
where inningsid = 1925
and not (batting_position>11 and how_out = 'DNB')
order by batting_position;

select * from bowling
where inningsid = 1922;

--bowling
select players.name_fl as player_name
    , case when extra_balls > 0 then round(overs+(extra_balls::numeric/10),1)
        else overs end as overs
    , maidens
    , wides+no_balls+runs_off_bat as runs
    , coalesce(w.w,0) as wickets
    , round(6*(wides+no_balls+runs_off_bat)::numeric/(6*overs+extra_balls),1)
    , wides
    , no_balls    
from bowling
join players
on players.playerid = bowling.playerid
left join (select playerid, inningsid, count(*) as w from wickets group by 1,2) w
on w.playerid = bowling.playerid
and w.inningsid = bowling.inningsid
where bowling.inningsid = 1925


