
CREATE OR REPLACE VIEW team_16_ind_most_matches_together AS
select 
    p1.player_name as "Player 1"
    , p2.player_name as "Player 2"
    , aa.matches
from (
    select 
        player1
        , player2
        , count(*) as matches
    from (
        select distinct  
            b1.playerid as player1
            , b2.playerid as player2
            , innings.matchid 
        from batting as b1
        inner join batting as b2 
        on b1.inningsid = b2.inningsid 
        and b1.playerid < b2.playerid
        inner join innings
        on b1.inningsid = innings.inningsid
        --where b1.inningsid < 10 --test
    ) a
    group by player1, player2
) aa
inner join players as p1
on aa.Player1 = p1.playerid
inner join players as p2
on aa.Player2 = p2.playerid
order by matches desc
;


-- run outs
select 
    p1.player_name as "Player 1"
    , p2.player_name as "Player 2"
    , aa.matches
from (
    select 
        player1
        , player2
        , count(*) as matches
    from (
        select distinct  
            case when b1.playerid < b1.not_out_batter then b1.playerid else b1.not_out_batter end as player1
            , case when b1.playerid > b1.not_out_batter then b1.playerid else b1.not_out_batter end as player2
            , innings.inningsid 
        from batting as b1
        inner join innings
        on b1.inningsid = innings.inningsid
        where how_out = 'Run Out'
        --where b1.inningsid < 10 --test
    ) a
    group by player1, player2
) aa
inner join players as p1
on aa.Player1 = p1.playerid
inner join players as p2
on aa.Player2 = p2.playerid
order by matches desc, player1
;

-- run outs involved in
select 
    p1.player_name as "Name"
    , sum(out_batter+not_out_batter) as run_outs
    , sum(out_batter) as out_batter
    , sum(not_out_batter) as not_out_batter
from (
    select  
        b1.playerid as player1
        , count(*) as out_batter
        , 0 as not_out_batter
    from batting as b1
    where how_out = 'Run Out'
    group by player1, not_out_batter

    union all 

    select  
        b1.not_out_batter as player1
        , 0 as out_batter
        , count(*) as not_out_batter
    from batting as b1
    where how_out = 'Run Out'
    group by player1, out_batter
) aa
inner join players as p1
on aa.Player1 = p1.playerid
group by player_name
order by run_outs desc
;




SELECT Name, ro::float/dismissals AS percentage, dismissals, ro
FROM z_bat_ind_dismissal_types
WHERE dismissals > 9
ORDER BY percentage DESC , dismissals DESC;






select how_out, count(*) from batting
group by how_out
order by how_out

--create table zzz_bk_batting as select * from batting

update batting
set how_out = 'Not Out'
where how_out = 'Not out'
;
update batting
set how_out = 'Bowled'
where how_out = 'bowled'
;
update batting
set how_out = 'Caught'
where how_out = 'caught'
;


select * from players order by playerid

select * from batting where playerid = 381;

select distinct how_out from batting

select * from innings 

select * from matches

select * from seasons

select * from yb_02_batting_summary where seasonid = 76