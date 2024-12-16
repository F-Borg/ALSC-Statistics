
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
update matches
set seasonid = 79 
where matchid in (813,814,815,816,817,818)



update wickets
set hat_trick = 1
where inningsid = 1827 and batting_position = 10




select * from players order by playerid

select * from batting -- where playerid = 381;
order by inningsid

select distinct how_out from batting

select * from wickets where inningsid = 1813

select * from innings where inningsid = 1814

select * from innings      where matchid = 813

select * from matches      --where matchid = 813
order by date1 desc

select * from seasons

select * from wickets where hat_trick > 0

select * from yb_02_batting_summary where seasonid = 76




select * from seasons where playhq_season='Section 6 Blackwood Sound Cup' and year='20'||replace('23-24','-','/')



-- update batting
-- set batting_position = NULL
--     , bowler_name = NULL
--     , score = NULL
--     , _4s = NULL
--     , _6s = NULL
--     , balls_faced = NULL
-- where how_out = 'DNB'

update batting
set how_out = 'DNB'
where how_out = '0'
and inningsid = 1695
and batting_position in (12,13)

select * from batting 
where how_out = 'Absent Out'

where playerid = 386
order by score

select * from innings where inningsid = 1695
select * from matches where matchid = 756
select * from seasons where seasonid = 74


SELECT 
    players.Surname ||', '|| players.firstname AS Name
    , Sum(CASE WHEN innings.inningsno=1 Or innings.inningsno=2 then 1 else 0 end) AS Mat
    , Sum(CASE WHEN lower(coalesce(Batting.how_out,'0')) in ('dnb','0','absent out') then 0 else 1 end) AS Inn
    , Sum(CASE WHEN lower(batting.how_out) in ('not out','forced retirement','retired hurt','retired not out') then 1 else 0 end) AS "NO"
    , Sum(CASE WHEN lower(batting.how_out) not in ('dnb','0','absent out','not out','forced retirement','retired hurt','retired not out','retired') And batting.score=0 then 1 else 0 end) AS Ducks
    , Sum(Batting.Score) AS Total
    , Count(Batting.Score) AS count_bat_score
    , (CASE WHEN Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))=0 then -9 
        else Sum(Batting.Score)/(Count(Batting.Score)-Sum((CASE WHEN lower(batting.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))) end) AS "Average"
    , Sum(batting.balls_faced) AS BF
    , CASE WHEN Count(Batting.Score)-Sum(CASE WHEN lower(batting.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0 then -9
        else Sum(Batting.balls_faced)/(Count(Batting.Score)-Sum(CASE WHEN lower(batting.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) end AS "Average BF"
    , players.playerid
FROM Players
LEFT JOIN Batting
ON Players.playerid = Batting.playerid
LEFT JOIN Innings 
ON Innings.InningsID = Batting.InningsID
LEFT JOIN Matches 
ON Matches.MatchID = Innings.MatchID
LEFT JOIN z_all_player_dates 
ON z_all_player_dates.playerid = Players.playerid
LEFT JOIN z_batmax 
ON z_batmax.playerid = Players.playerid

GROUP BY Name
    , z_all_player_dates."First Season"
    , z_all_player_dates."Last Season"
    , z_batmax.HS
    , Players.playerid
HAVING (((Players.playerid)<>999))
ORDER BY Name, Sum(Batting.Score) DESC;

