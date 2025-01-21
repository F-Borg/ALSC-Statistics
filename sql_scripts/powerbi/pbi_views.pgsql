/*
Individual:
    pbi_batting:
        manhattan
        runs/posn
        avg/posn
        avg/season
        avg in wins/losses

        runs in boundaries
        home/away runs/avg

    pbi_partnerships:
        avg pship
        runs with other players

    pbi_bowling:
        avg batter dismissed
        sr/avg per season

    
*/

drop view pbi_batting;
create or replace view pbi_batting as
select
    players.player_name
    , case when b.batting_position in (1,2) then 1 else b.batting_position end as batting_position
    , b.score
    , case when score = 0 then '0'
           when score < 10 then '1-10'
           when score < 20 then '10-19'
           when score < 30 then '20-29'
           when score < 40 then '30-39'
           when score < 50 then '40-49'
           when score < 60 then '50-59'
           when score < 70 then '60-69'
           when score < 80 then '70-79'
           when score < 90 then '80-89'
           when score < 100 then '90-99'
           else '100+' end as score_10
    , b.how_out
    , case when how_out in ('Bowled','Caught','LBW','Run Out','Stumped','c & b','Hit Wicket') then 1 else 0 end as is_out
    , b._4s
    , b._6s
    , b.balls_faced
    , b.fow
    , b.wicket
    , m.nodays
    , case when innings.inningsno in (1,2) then m.date1 else date2 end as match_date
    , m.opponent
    , case when ground like any (array['Bulldog%','Schmidt%','Adelaide Lutheran','Park 21%']) then 'Home' else 'Away' end as home_away
    , m.result
    , s.year
    , s.eleven

FROM players
JOIN Batting b
ON Players.playerid = b.playerid
JOIN Innings 
ON Innings.InningsID = b.InningsID
JOIN Matches m
ON m.MatchID = Innings.MatchID
join Seasons s
on s.seasonid = m.seasonid
;




select * from pbi_batting limit 1000
;


select ground
, case when ground like any (array['Bulldog%','Schmidt%','Adelaide Lutheran','Park 21%']) then 'Home' else 'Away' end as home_away
,  count(*) as _c from matches 
group by ground, home_away
order by home_away desc
