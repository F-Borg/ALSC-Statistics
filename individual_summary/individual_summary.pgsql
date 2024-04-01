

select * from players order by playerid desc;


/*
Individual Summary
*/

-- Games

-- player id
-- Games played
select playerid, mat from team_13_ind_most_matches
where name = 'Borgas, Finley'

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

-- time between first and last Game
select "Name", debut, "Final Game", AGE("Final Game", debut)::text as "Career Span" from z_all_player_dates where "Name" = 'Borgas, Finley'

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
*/
select *
from batting_01_summary_ind
where playerid = 269



/*
-- Bowl
wickets
ave
best year

-- Field


*/


