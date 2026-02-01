CREATE OR REPLACE VIEW batting_i_01_summary_ind AS
SELECT 
    players.Surname ||', '|| players.firstname AS Name
    --, Players.Real playerid AS Real ID
    , z_all_player_dates."First Season" AS Debut
    , z_all_player_dates."Last Season"
    , Sum(CASE WHEN innings_i.inningsno=1 Or innings_i.inningsno=2 then 1 else 0 end) AS Mat
    , Sum(CASE WHEN lower(coalesce(batting_i.how_out,'0')) in ('dnb','0','absent out') then 0 else 1 end) AS Inn
    , Sum(CASE WHEN lower(batting_i.how_out) in ('not out','forced retirement','retired hurt','retired not out') then 1 else 0 end) AS "NO"
    , Sum(CASE WHEN lower(batting_i.how_out) not in ('dnb','0','absent out','not out','forced retirement','retired hurt','retired not out','retired') And batting_i.score=0 then 1 else 0 end) AS Ducks
    , Sum(batting_i._4s) AS Fours
    , Sum(batting_i._6s) AS Sixes
    , Sum(CASE WHEN batting_i.score Between 50 And 99 then 1 else 0 end) AS Fifties
    , Sum(CASE WHEN batting_i.score>99 then 1 else 0 end) AS Hundreds
    , z_batmax.HS
    , Sum(batting_i.Score) AS Total
    , (CASE WHEN Count(batting_i.Score)-Sum((CASE WHEN lower(batting_i.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))=0 then -9 
        else Sum(batting_i.Score)/(Count(batting_i.Score)-Sum((CASE WHEN lower(batting_i.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))) end) AS "Average"
    , Sum(batting_i.balls_faced) AS BF
    , CASE WHEN Count(batting_i.Score)-Sum(CASE WHEN lower(batting_i.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0 then -9
        else Sum(batting_i.balls_faced)/(Count(batting_i.Score)-Sum(CASE WHEN lower(batting_i.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) end AS "Average BF"
    , case when Sum(batting_i.balls_faced)>0 then 100*Sum(batting_i.score)/Sum(batting_i.balls_faced) else null end AS "Runs/100 Balls"
    , 100*(Sum(batting_i._4s)*4+Sum(batting_i._6s)*6)/(CASE WHEN Sum(batting_i.score)=0 then 1 else Sum(batting_i.score) end) AS "Pct Runs in Boundaries"
    , Players.playerid
FROM Players
LEFT JOIN batting_i
ON Players.playerid = batting_i.playerid
LEFT JOIN innings_i 
ON innings_i.InningsID = batting_i.InningsID
LEFT JOIN matches_i 
ON matches_i.MatchID = innings_i.MatchID
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
ORDER BY Name, Sum(batting_i.Score) DESC;


--drop view batting_02_career_runs;
CREATE OR REPLACE VIEW batting_02_career_runs AS 
SELECT batting_01_summary_ind.Total AS "Runs", batting_01_summary_ind.Name as "Name", batting_01_summary_ind.Inn as "Inn", batting_01_summary_ind."Average"
FROM batting_01_summary_ind
GROUP BY batting_01_summary_ind.Total, batting_01_summary_ind.Name, batting_01_summary_ind.Inn, batting_01_summary_ind."Average"
HAVING (((batting_01_summary_ind.Total)>100))
ORDER BY batting_01_summary_ind.Total DESC
;


CREATE OR REPLACE VIEW batting_03_career_ave AS 
SELECT batting_01_summary_ind."Average", batting_01_summary_ind.Name as "Name", batting_01_summary_ind.Total AS "Runs", batting_01_summary_ind.Inn as "Inn"
FROM batting_01_summary_ind
GROUP BY batting_01_summary_ind."Average", batting_01_summary_ind.Name, batting_01_summary_ind.Total, batting_01_summary_ind.Inn
HAVING (((batting_01_summary_ind.Total)>199))
ORDER BY batting_01_summary_ind."Average" DESC
;


CREATE OR REPLACE VIEW batting_04_career_sr_high AS 
SELECT batting_01_summary_ind."Runs/100 Balls", batting_01_summary_ind.Name as "Name", batting_01_summary_ind.Total AS "Runs", batting_01_summary_ind.BF as "Balls"
FROM batting_01_summary_ind
WHERE (((batting_01_summary_ind.Total)>99))
ORDER BY batting_01_summary_ind."Runs/100 Balls" DESC;


CREATE OR REPLACE VIEW batting_05_career_sr_low AS 
SELECT batting_01_summary_ind."Runs/100 Balls", batting_01_summary_ind.Name as "Name", batting_01_summary_ind.Total AS "Runs", batting_01_summary_ind.BF as "Balls"
FROM batting_01_summary_ind
WHERE (((batting_01_summary_ind.BF)>99))
ORDER BY batting_01_summary_ind."Runs/100 Balls";


CREATE OR REPLACE VIEW batting_06_milestones_100 AS 
SELECT batting_01_summary_ind.Name, batting_01_summary_ind.Hundreds, batting_01_summary_ind.Inn, 100*batting_01_summary_ind.Hundreds::float/batting_01_summary_ind.Inn AS "Percentage 100s"
FROM batting_01_summary_ind
GROUP BY batting_01_summary_ind.Name, batting_01_summary_ind.Hundreds, batting_01_summary_ind.Inn
HAVING (((batting_01_summary_ind.Hundreds)>0))
ORDER BY batting_01_summary_ind.Hundreds DESC , batting_01_summary_ind.Hundreds/batting_01_summary_ind.Inn DESC;


CREATE OR REPLACE VIEW batting_07_milestones_50 AS 
SELECT batting_01_summary_ind.Name, batting_01_summary_ind.Fifties, batting_01_summary_ind.Inn, 100*batting_01_summary_ind.Fifties::float/batting_01_summary_ind.Inn AS "Percentage 50s"
FROM batting_01_summary_ind
GROUP BY batting_01_summary_ind.Name, batting_01_summary_ind.Fifties, batting_01_summary_ind.Inn
HAVING (((batting_01_summary_ind.Fifties)>0))
ORDER BY batting_01_summary_ind.Fifties DESC , batting_01_summary_ind.Fifties/batting_01_summary_ind.Inn DESC;


CREATE OR REPLACE VIEW batting_08_milestones_ducks AS 
SELECT batting_01_summary_ind.Name, batting_01_summary_ind.Ducks, batting_01_summary_ind.Inn, 100*batting_01_summary_ind.ducks::float/batting_01_summary_ind.inn AS "Percentage Ducks"
FROM batting_01_summary_ind
WHERE (((batting_01_summary_ind.Ducks)>0))
ORDER BY batting_01_summary_ind.Ducks DESC , batting_01_summary_ind.Inn;

CREATE OR REPLACE VIEW batting_09_milestones_runs_season AS 
SELECT 
    players.player_name AS Name
    , coalesce(Sum(batting_i.Score),0) AS Runs
    , z_player_season_matches.Mat
    , CASE WHEN Count(batting_i.Score)-Sum(CASE WHEN lower(batting_i.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0
        THEN -9 ELSE Sum(batting_i.Score)::float/(Count(batting_i.Score)-Sum(CASE WHEN lower(batting_i.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) END AS Average
    , Seasons.Year
    , Seasons.Eleven
    , Seasons.Association
    , Seasons.Grade
FROM Seasons
INNER JOIN matches_i
ON Seasons.SeasonID = matches_i.SeasonID
INNER JOIN innings_i 
ON matches_i.MatchID = innings_i.MatchID
INNER JOIN batting_i 
ON innings_i.InningsID = batting_i.InningsID
INNER JOIN players
ON Players.PlayerID = batting_i.PlayerID
INNER JOIN z_player_season_matches
ON z_player_season_matches.PlayerID = Players.PlayerID
AND Seasons.SeasonID = z_player_season_matches.SeasonID
GROUP BY players.player_name, z_player_season_matches.Mat, Seasons.Year, Seasons.Eleven, Seasons.Association, Seasons.Grade
ORDER BY Runs DESC;


CREATE OR REPLACE VIEW batting_10_high_score_ind AS 
SELECT players.player_name AS Name
    , batting_i.score::varchar || (CASE WHEN lower(batting_i.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS Score
    , batting_i.balls_faced, matches_i.Opponent, Seasons.Year, matches_i.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN matches_i
ON Seasons.SeasonID = matches_i.SeasonID
INNER JOIN innings_i 
ON matches_i.MatchID = innings_i.MatchID
INNER JOIN batting_i
ON innings_i.InningsID = batting_i.InningsID
INNER JOIN Players 
ON Players.PlayerID = batting_i.PlayerID
where batting_i.score > 0
ORDER BY batting_i.Score DESC, (CASE WHEN lower(batting_i.how_out) in ('not out','forced retirement','retired hurt','retired not out') then 1 else 0 end) desc;


CREATE OR REPLACE VIEW batting_11_high_score_sixes AS 
SELECT 
    players.player_name AS Name
    , batting_i._6s
    , batting_i.score::varchar || (CASE WHEN lower(batting_i.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS Score
    , batting_i.balls_faced
    , matches_i.Opponent, Seasons.Year, matches_i.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN matches_i
ON Seasons.SeasonID = matches_i.SeasonID
INNER JOIN innings_i 
ON matches_i.MatchID = innings_i.MatchID
INNER JOIN batting_i
ON innings_i.InningsID = batting_i.InningsID
INNER JOIN Players 
ON Players.PlayerID = batting_i.PlayerID
where batting_i._6s > 0
ORDER BY batting_i._6s DESC;


--drop view batting_12_score_by_posn_1stXI;
CREATE OR REPLACE VIEW batting_12_score_by_posn_1stXI AS
select * from (
    SELECT 
        batting_i.batting_position
        , case when batting_i.batting_position in (1,2) then '1 or 2' else batting_i.batting_position::varchar end as bat_pos
        , z_batpos_max.MaxOfScore
        , batting_i.balls_faced
        , players.player_name AS Batter, matches_i.Opponent, Seasons.Year, matches_i.Round, Seasons.Grade, Seasons.Association
        , rank() over (partition by (case when batting_i.batting_position in (1,2) then '1 or 2' else batting_i.batting_position::varchar end) order by MaxOfScore desc) as tmp
    FROM Seasons 
    INNER JOIN matches_i
    ON Seasons.SeasonID = matches_i.SeasonID
    INNER JOIN innings_i 
    ON matches_i.MatchID = innings_i.MatchID
    INNER JOIN batting_i
    ON innings_i.InningsID = batting_i.InningsID
    INNER JOIN Players 
    ON Players.PlayerID = batting_i.PlayerID
    INNER JOIN z_batpos_max
    ON batting_i.batting_position = z_batpos_max.batting_position
    AND batting_i.Score = z_batpos_max.MaxOfScore
    where z_batpos_max.eleven = '1st'
    and seasons.eleven = '1st'
) a
where tmp=1
ORDER BY batting_position;

--drop view batting_13_score_by_posn_2ndXI;
CREATE OR REPLACE VIEW batting_13_score_by_posn_2ndXI AS 
select * from (
    SELECT 
        batting_i.batting_position
        , case when batting_i.batting_position in (1,2) then '1 or 2' else batting_i.batting_position::varchar end as bat_pos
        , z_batpos_max.MaxOfScore
        , batting_i.balls_faced
        , players.player_name AS Batter, matches_i.Opponent, Seasons.Year, matches_i.Round, Seasons.Grade, Seasons.Association
        , rank() over (partition by (case when batting_i.batting_position in (1,2) then '1 or 2' else batting_i.batting_position::varchar end) order by MaxOfScore desc) as tmp
    FROM Seasons 
    INNER JOIN matches_i
    ON Seasons.SeasonID = matches_i.SeasonID
    INNER JOIN innings_i 
    ON matches_i.MatchID = innings_i.MatchID
    INNER JOIN batting_i
    ON innings_i.InningsID = batting_i.InningsID
    INNER JOIN Players 
    ON Players.PlayerID = batting_i.PlayerID
    INNER JOIN z_batpos_max
    ON batting_i.batting_position = z_batpos_max.batting_position
    AND batting_i.Score = z_batpos_max.MaxOfScore
    where z_batpos_max.eleven = '2nd'
    and seasons.eleven = '2nd'
) a
where tmp=1
ORDER BY batting_position;

--drop view batting_14_score_by_posn_3rdXI;
CREATE OR REPLACE VIEW batting_14_score_by_posn_3rdXI AS 
select * from (
    SELECT 
        batting_i.batting_position
        , case when batting_i.batting_position in (1,2) then '1 or 2' else batting_i.batting_position::varchar end as bat_pos
        , z_batpos_max.MaxOfScore
        , batting_i.balls_faced
        , players.player_name AS Batter, matches_i.Opponent, Seasons.Year, matches_i.Round, Seasons.Grade, Seasons.Association
        , rank() over (partition by (case when batting_i.batting_position in (1,2) then '1 or 2' else batting_i.batting_position::varchar end) order by MaxOfScore desc) as tmp
    FROM Seasons 
    INNER JOIN matches_i
    ON Seasons.SeasonID = matches_i.SeasonID
    INNER JOIN innings_i 
    ON matches_i.MatchID = innings_i.MatchID
    INNER JOIN batting_i
    ON innings_i.InningsID = batting_i.InningsID
    INNER JOIN Players 
    ON Players.PlayerID = batting_i.PlayerID
    INNER JOIN z_batpos_max
    ON batting_i.batting_position = z_batpos_max.batting_position
    AND batting_i.Score = z_batpos_max.MaxOfScore
    where z_batpos_max.eleven = '3rd'
    and seasons.eleven = '3rd'
) a
where tmp=1
ORDER BY batting_position;


CREATE OR REPLACE VIEW batting_15_fast_slow_longest AS
SELECT players.player_name AS Name
, batting_i.balls_faced
, batting_i.score::varchar || (CASE WHEN lower(batting_i.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS Score
, matches_i.Opponent, Seasons.Year, matches_i.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN matches_i
ON Seasons.SeasonID = matches_i.SeasonID
INNER JOIN innings_i 
ON matches_i.MatchID = innings_i.MatchID
INNER JOIN batting_i
ON innings_i.InningsID = batting_i.InningsID
INNER JOIN Players 
ON Players.PlayerID = batting_i.PlayerID
where batting_i.balls_faced > 100
ORDER BY batting_i.balls_faced DESC , batting_i.Score DESC;


CREATE OR REPLACE VIEW batting_16_fast_slow_fastest AS
SELECT 
    Players.player_name AS Name
    , 100*batting_i.score::float/batting_i.balls_faced AS strike_rate
    , batting_i.score::varchar || (CASE WHEN lower(batting_i.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS Runs
    , batting_i.balls_faced
    , matches_i.Opponent, Seasons.Year, matches_i.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN matches_i
ON Seasons.SeasonID = matches_i.SeasonID
INNER JOIN innings_i 
ON matches_i.MatchID = innings_i.MatchID
INNER JOIN batting_i
ON innings_i.InningsID = batting_i.InningsID
INNER JOIN Players 
ON Players.PlayerID = batting_i.PlayerID
WHERE batting_i.Score > 29
and batting_i.balls_faced > 0
ORDER BY strike_rate DESC;

CREATE OR REPLACE VIEW batting_17_fast_slow_slowest AS
SELECT 
    Players.player_name AS Name
    , 100*batting_i.score::float/batting_i.balls_faced AS strike_rate
    , batting_i.score::varchar || (CASE WHEN lower(batting_i.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS Runs
    , batting_i.balls_faced
    , matches_i.Opponent, Seasons.Year, matches_i.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association
FROM Seasons 
INNER JOIN matches_i
ON Seasons.SeasonID = matches_i.SeasonID
INNER JOIN innings_i 
ON matches_i.MatchID = innings_i.MatchID
INNER JOIN batting_i
ON innings_i.InningsID = batting_i.InningsID
INNER JOIN Players 
ON Players.PlayerID = batting_i.PlayerID
WHERE batting_i.balls_faced > 59
ORDER BY strike_rate;


CREATE OR REPLACE VIEW batting_18_dismissals_ct AS
SELECT Name, C::float/dismissals AS percentage, dismissals, C as caught
FROM z_bat_ind_dismissal_types
WHERE dismissals > 9
ORDER BY percentage DESC , dismissals DESC;


CREATE OR REPLACE VIEW batting_19_dismissals_b AS
SELECT Name, B::float/dismissals AS percentage, dismissals, B as bowled
FROM z_bat_ind_dismissal_types
WHERE dismissals > 9
ORDER BY percentage DESC , dismissals DESC;


CREATE OR REPLACE VIEW batting_20_dismissals_lbw AS
SELECT Name, LBW::float/dismissals AS percentage, dismissals, LBW
FROM z_bat_ind_dismissal_types
WHERE dismissals > 9
ORDER BY percentage DESC , dismissals DESC;

CREATE OR REPLACE VIEW batting_21_dismissals_no_lbw AS
SELECT dismissals, Name
FROM z_bat_ind_dismissal_types
WHERE LBW = 0
ORDER BY dismissals DESC;

CREATE OR REPLACE VIEW batting_22_dismissals_st AS
SELECT ST as stumpings, Name
FROM z_bat_ind_dismissal_types
WHERE dismissals > 0
ORDER BY stumpings DESC;


CREATE OR REPLACE VIEW batting_23_partnerships_highest AS
SELECT 
    Runs
    , Wicket
    , "Player 1"
    , "Player 2"
    , Opponent, Year, Round, Eleven, Grade, Association
FROM z_batting_partnerships_highest 
ORDER BY p DESC;


-- change from overall to 1st XI
CREATE OR REPLACE VIEW batting_24_partnerships_wicket_1stXI AS
SELECT 
    a.Runs
    , a.Wicket
    , a."Player 1"
    , a."Player 2"
    , a.Opponent, a.Year, a.Round, a.Eleven, a.Grade, a.Association
FROM z_batting_partnerships_highest a
INNER JOIN (
    SELECT wicket
        , max(p) as p
    FROM z_batting_partnerships_highest
    where eleven = '1st'
    group by wicket
) max_part
on a.p = max_part.p
and a.wicket = max_part.wicket
WHERE a.eleven = '1st'
order by a.wicket
;


CREATE OR REPLACE VIEW batting_25_partnerships_wicket_2ndXI AS
SELECT 
    a.Runs
    , a.Wicket
    , a."Player 1"
    , a."Player 2"
    , a.Opponent, a.Year, a.Round, a.Eleven, a.Grade, a.Association
FROM z_batting_partnerships_highest a
INNER JOIN (
    SELECT wicket
        , max(p) as p
    FROM z_batting_partnerships_highest
    where eleven = '2nd'
    group by wicket
) max_part
on a.p = max_part.p
and a.wicket = max_part.wicket
WHERE a.eleven = '2nd'
order by a.wicket
;


CREATE OR REPLACE VIEW batting_26_partnerships_wicket_3rdXI AS
SELECT 
    a.Runs
    , a.Wicket
    , a."Player 1"
    , a."Player 2"
    , a.Opponent, a.Year, a.Round, a.Eleven, a.Grade, a.Association
FROM z_batting_partnerships_highest a
INNER JOIN (
    SELECT wicket
        , max(p) as p
    FROM z_batting_partnerships_highest
    where eleven = '3rd'
    group by wicket
) max_part
on a.p = max_part.p
and a.wicket = max_part.wicket
WHERE a.eleven = '3rd'
order by a.wicket
;


CREATE OR REPLACE VIEW batting_27_run_out_involvements AS
select 
    p1.player_name as "Name"
    , b.inn as innings_i
    , sum(out_batter+not_out_batter) as run_outs
    , sum(out_batter) as out_batter
    , sum(not_out_batter) as not_out_batter
    , to_char(100*sum(out_batter+not_out_batter)/b.inn, '990D9%') as "r/o per innings_i"
from (
    select  
        b1.playerid as player1
        , count(*) as out_batter
        , 0 as not_out_batter
    from batting_i as b1
    where how_out = 'Run Out'
    group by player1, not_out_batter

    union all 

    select  
        b1.not_out_batter as player1
        , 0 as out_batter
        , count(*) as not_out_batter
    from batting_i as b1
    where how_out = 'Run Out'
    group by player1, out_batter
) aa
inner join players as p1
on aa.Player1 = p1.playerid
inner join batting_01_summary_ind b
on aa.player1 = b.playerid
group by player_name, b.inn
order by run_outs desc, out_batter desc, player_name
;


CREATE OR REPLACE VIEW batting_28_finals_runs AS
SELECT 
    players.player_name AS Name
    , Count(batting_i.Score) as innings_i
    , coalesce(Sum(batting_i.Score),0) AS Runs
    , CASE WHEN Count(batting_i.Score)-Sum(CASE WHEN lower(batting_i.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0
        THEN -9 ELSE Sum(batting_i.Score)::float/(Count(batting_i.Score)-Sum(CASE WHEN lower(batting_i.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) END AS Average
FROM matches_i
INNER JOIN innings_i 
ON matches_i.MatchID = innings_i.MatchID
INNER JOIN batting_i 
ON innings_i.InningsID = batting_i.InningsID
INNER JOIN players
ON Players.PlayerID = batting_i.PlayerID
where matches_i.round in ('SF','GF')
GROUP BY players.player_name
HAVING coalesce(Sum(batting_i.Score),0) > 99
ORDER BY Runs DESC;

CREATE OR REPLACE VIEW batting_29_finals_ave AS
SELECT 
    players.player_name AS Name
    , Count(batting_i.Score) as innings_i
    , coalesce(Sum(batting_i.Score),0) AS Runs
    , CASE WHEN Count(batting_i.Score)-Sum(CASE WHEN lower(batting_i.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0
        THEN -9 ELSE Sum(batting_i.Score)::float/(Count(batting_i.Score)-Sum(CASE WHEN lower(batting_i.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) END AS Average
FROM matches_i
INNER JOIN innings_i 
ON matches_i.MatchID = innings_i.MatchID
INNER JOIN batting_i 
ON innings_i.InningsID = batting_i.InningsID
INNER JOIN players
ON Players.PlayerID = batting_i.PlayerID
where matches_i.round in ('SF','GF')
GROUP BY players.player_name
HAVING coalesce(Sum(batting_i.Score),0) > 99
ORDER BY Average DESC;

