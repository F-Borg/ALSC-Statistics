-- Mostly just a sandpit now - python file is the main one

select * from players order by playerid desc;



/*
Individual Summary
*/

-- Games

-- player id
-- Games played
select playerid, mat from team_13_ind_most_matches
where name = 'Borgas, Finley'
;

-- time between first and last Game
select "Name", debut, "Final Game", AGE("Final Game", debut)::text as "Career Span" from z_all_player_dates where "Name" = 'Borgas, Finley'

-- wins and losses
SELECT 
    Count(matches.matchid) AS Played
    , Sum(case when upper(matches.result)='W2' then 1 else 0 end) AS WO
    , Sum(case when upper(matches.result)='W1' then 1 else 0 end) AS W1
    , Sum(case when upper(matches.result) in ('D','T') then 1 else 0 end) AS D
    , Sum(case when upper(matches.result)='L1' then 1 else 0 end) AS L1
    , Sum(case when upper(matches.result)='L2' then 1 else 0 end) AS LO
    , (0.00+(Sum(case when upper(matches.result) in ('W1','W2') then 1 else 0 end)))/Count(matches.matchid) AS "Win %"
FROM seasons 
INNER JOIN matches 
ON seasons.seasonID = matches.seasonID
INNER JOIN (select distinct matchid 
    from innings
    INNER JOIN Batting
    ON Innings.InningsID = Batting.InningsID
    WHERE batting.playerid = 269
) ind_matches
ON Matches.MatchID = ind_matches.MatchID
--WHERE (((seasons.year)<>'1994/95'))


--get first game
select * --year, round, eleven, opponent, date1, batting_position, score, balls_faced 
from (
    select
    *
    , row_number() over (partition by batting.playerid order by matches.date1) as tmp
    FROM seasons
    INNER JOIN Matches 
    on seasons.seasonid = matches.seasonid
    INNER JOIN Innings 
    ON Matches.MatchID = Innings.MatchID
    INNER JOIN Batting
    ON Innings.InningsID = Batting.InningsID
    where batting.playerid = 269
    ) a
where a.tmp = 1
;

-- first game bowling
select * from z_bowling_figures_all
where matchid = 373


--players played with the most
select 
case when "Player 1" = 'Borgas, Finley' then "Player 2" else "Player 1" end as "Team-mate",
matches
from team_16_ind_most_matches_together
where "Player 1" = 'Borgas, Finley'
or "Player 2" = 'Borgas, Finley'
order by matches desc
limit 20


-- count of players played with
select count(*) as "Number of Players Played With"
from team_16_ind_most_matches_together
where "Player 1" = 'Borgas, Finley'
or "Player 2" = 'Borgas, Finley'


-- who played in first game?
select 
players.player_name
from (
    --get first game
    select
    batting.inningsid, matches.date1
    , row_number() over (partition by batting.playerid order by matches.date1) as tmp
    FROM Matches
    INNER JOIN Innings 
    ON Matches.MatchID = Innings.MatchID
    INNER JOIN Batting
    ON Innings.InningsID = Batting.InningsID
    where batting.playerid = 269
    ) a
inner join batting
on a.inningsid = batting.inningsid
inner join players
on batting.playerid = players.playerid
where a.tmp = 1
order by batting.batting_position
;

-- who played in last game?
select 
players.player_name
from (
    --get first game
    select
    batting.inningsid, matches.date1
    , row_number() over (partition by batting.playerid order by matches.date1 desc) as tmp
    FROM Matches
    INNER JOIN Innings 
    ON Matches.MatchID = Innings.MatchID
    INNER JOIN Batting
    ON Innings.InningsID = Batting.InningsID
    where batting.playerid = 269
    ) a
inner join batting
on a.inningsid = batting.inningsid
inner join players
on batting.playerid = players.playerid
where a.tmp = 1
order by batting.batting_position
;

/*
-- Bat
runs
ave
best year
runs made with others
*/
select *
from batting_01_summary_ind
where playerid = 269
;


select 
matches.date1
--, batting.* 
, batting.score
, seasons.year
, row_number() over (order by matches.date1, innings.inningsno) as inn_order
from batting
join innings
on batting.inningsid = innings.inningsid
join matches
ON Matches.MatchID = Innings.MatchID
join seasons
on seasons.seasonid = matches.seasonid
where batting.playerid = 269
and how_out not in ('DNB','Absent Out')
order by inn_order
;



/*
-- Bowl
wickets
ave
best year

-- Field


*/


