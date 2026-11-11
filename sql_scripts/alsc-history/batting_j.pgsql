CREATE OR REPLACE VIEW batting_j_01_summary_ind AS
SELECT 
    players.Surname ||', '|| players.firstname AS Name
    --, Players.Real playerid AS Real ID
    , z_j_all_player_dates."First Season" AS Debut
    , z_j_all_player_dates."Last Season"
    , Sum(CASE WHEN innings_j.inningsno=1 Or innings_j.inningsno=2 then 1 else 0 end) AS Mat
    , Sum(CASE WHEN lower(coalesce(Batting_j.how_out,'0')) in ('dnb','0','absent out') then 0 else 1 end) AS Inn
    , Sum(CASE WHEN lower(batting_j.how_out) in ('not out','forced retirement','retired hurt','retired not out') then 1 else 0 end) AS "NO"
    , Sum(CASE WHEN lower(batting_j.how_out) not in ('dnb','0','absent out','not out','forced retirement','retired hurt','retired not out','retired') And batting_j.score=0 then 1 else 0 end) AS Ducks
    , Sum(Batting_j._4s) AS Fours
    , Sum(Batting_j._6s) AS Sixes
    , Sum(CASE WHEN batting_j.score Between 50 And 99 then 1 else 0 end) AS Fifties
    , Sum(CASE WHEN batting_j.score>99 then 1 else 0 end) AS Hundreds
    , z_j_batmax.HS
    , Sum(Batting_j.Score) AS Total
    , (CASE WHEN Count(Batting_j.Score)-Sum((CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))=0 then -9 
        else Sum(Batting_j.Score)/(Count(Batting_j.Score)-Sum((CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end))) end) AS "Average"
    , Sum(batting_j.balls_faced) AS BF
    , CASE WHEN Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0 then -9
        else Sum(Batting_j.balls_faced)/(Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) end AS "Average BF"
    , case when Sum(batting_j.balls_faced)>0 then 100*Sum(batting_j.score)/Sum(batting_j.balls_faced) else null end AS "Runs/100 Balls"
    , 100*(Sum(batting_j._4s)*4+Sum(batting_j._6s)*6)/(CASE WHEN Sum(batting_j.score)=0 then 1 else Sum(batting_j.score) end) AS "Pct Runs in Boundaries"
    , Players.playerid
FROM Players
LEFT JOIN Batting_j
ON Players.playerid = Batting_j.playerid
LEFT JOIN Innings_j 
ON Innings_j.InningsID = Batting_j.InningsID
LEFT JOIN Matches_j 
ON Matches_j.MatchID = Innings_j.MatchID
LEFT JOIN z_j_all_player_dates 
ON z_j_all_player_dates.playerid = Players.playerid
LEFT JOIN z_j_batmax 
ON z_j_batmax.playerid = Players.playerid

GROUP BY Name
    , z_j_all_player_dates."First Season"
    , z_j_all_player_dates."Last Season"
    , z_j_batmax.HS
    , Players.playerid
HAVING (((Players.playerid)<>999))
ORDER BY Name, Sum(Batting_j.Score) DESC;


--drop view batting_j_02_career_runs;
CREATE OR REPLACE VIEW batting_j_02_career_runs AS 
SELECT batting_j_01_summary_ind.Total AS "Runs", batting_j_01_summary_ind.Name as "Name", batting_j_01_summary_ind.Inn as "Inn", batting_j_01_summary_ind."Average"
FROM batting_j_01_summary_ind
GROUP BY batting_j_01_summary_ind.Total, batting_j_01_summary_ind.Name, batting_j_01_summary_ind.Inn, batting_j_01_summary_ind."Average"
HAVING (((batting_j_01_summary_ind.Total)>100))
ORDER BY batting_j_01_summary_ind.Total DESC
;


CREATE OR REPLACE VIEW batting_j_03_career_ave AS 
SELECT batting_j_01_summary_ind."Average", batting_j_01_summary_ind.Name as "Name", batting_j_01_summary_ind.Total AS "Runs", batting_j_01_summary_ind.Inn as "Inn"
FROM batting_j_01_summary_ind
GROUP BY batting_j_01_summary_ind."Average", batting_j_01_summary_ind.Name, batting_j_01_summary_ind.Total, batting_j_01_summary_ind.Inn
HAVING (((batting_j_01_summary_ind.Total)>199))
ORDER BY batting_j_01_summary_ind."Average" DESC
;


CREATE OR REPLACE VIEW batting_j_04_career_sr_high AS 
SELECT batting_j_01_summary_ind."Runs/100 Balls", batting_j_01_summary_ind.Name as "Name", batting_j_01_summary_ind.Total AS "Runs", batting_j_01_summary_ind.BF as "Balls"
FROM batting_j_01_summary_ind
WHERE (((batting_j_01_summary_ind.Total)>99))
ORDER BY batting_j_01_summary_ind."Runs/100 Balls" DESC;


CREATE OR REPLACE VIEW batting_j_05_career_sr_low AS 
SELECT batting_j_01_summary_ind."Runs/100 Balls", batting_j_01_summary_ind.Name as "Name", batting_j_01_summary_ind.Total AS "Runs", batting_j_01_summary_ind.BF as "Balls"
FROM batting_j_01_summary_ind
WHERE (((batting_j_01_summary_ind.BF)>99))
ORDER BY batting_j_01_summary_ind."Runs/100 Balls";


CREATE OR REPLACE VIEW batting_j_06_milestones_100 AS 
SELECT batting_j_01_summary_ind.Name, batting_j_01_summary_ind.Hundreds, batting_j_01_summary_ind.Inn, 100*batting_j_01_summary_ind.Hundreds::float/batting_j_01_summary_ind.Inn AS "Percentage 100s"
FROM batting_j_01_summary_ind
GROUP BY batting_j_01_summary_ind.Name, batting_j_01_summary_ind.Hundreds, batting_j_01_summary_ind.Inn
HAVING (((batting_j_01_summary_ind.Hundreds)>0))
ORDER BY batting_j_01_summary_ind.Hundreds DESC , batting_j_01_summary_ind.Hundreds/batting_j_01_summary_ind.Inn DESC;


CREATE OR REPLACE VIEW batting_j_07_milestones_50 AS 
SELECT batting_j_01_summary_ind.Name, batting_j_01_summary_ind.Fifties, batting_j_01_summary_ind.Inn, 100*batting_j_01_summary_ind.Fifties::float/batting_j_01_summary_ind.Inn AS "Percentage 50s"
FROM batting_j_01_summary_ind
GROUP BY batting_j_01_summary_ind.Name, batting_j_01_summary_ind.Fifties, batting_j_01_summary_ind.Inn
HAVING (((batting_j_01_summary_ind.Fifties)>0))
ORDER BY batting_j_01_summary_ind.Fifties DESC , batting_j_01_summary_ind.Fifties/batting_j_01_summary_ind.Inn DESC;


CREATE OR REPLACE VIEW batting_j_08_milestones_ducks AS 
SELECT batting_j_01_summary_ind.Name, batting_j_01_summary_ind.Ducks, batting_j_01_summary_ind.Inn, 100*batting_j_01_summary_ind.ducks::float/batting_j_01_summary_ind.inn AS "Percentage Ducks"
FROM batting_j_01_summary_ind
WHERE (((batting_j_01_summary_ind.Ducks)>0))
ORDER BY batting_j_01_summary_ind.Ducks DESC , batting_j_01_summary_ind.Inn;

CREATE OR REPLACE VIEW batting_j_09_milestones_runs_season AS 
SELECT 
    players.player_name AS Name
    , coalesce(Sum(Batting_j.Score),0) AS Runs
    , z_j_player_season_matches.Mat
    , CASE WHEN Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0
        THEN -9 ELSE Sum(Batting_j.Score)::float/(Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) END AS Average
    , Seasons_j.Year
    , Seasons_j.Eleven
    , Seasons_j.Association
    , Seasons_j.Grade
FROM Seasons_j
INNER JOIN Matches_j
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN players
ON Players.PlayerID = Batting_j.PlayerID
INNER JOIN z_j_player_season_matches
ON z_j_player_season_matches.PlayerID = Players.PlayerID
AND Seasons_j.SeasonID = z_j_player_season_matches.SeasonID
GROUP BY players.player_name, z_j_player_season_matches.Mat, Seasons_j.Year, Seasons_j.Eleven, Seasons_j.Association, Seasons_j.Grade
ORDER BY Runs DESC;


CREATE OR REPLACE VIEW batting_j_10_high_score_ind AS 
SELECT players.player_name AS Name
    , batting_j.score::varchar || (CASE WHEN lower(batting_j.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS Score
    , Batting_j.balls_faced, Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting_j.PlayerID
where batting_j.score > 0
ORDER BY Batting_j.Score DESC, (CASE WHEN lower(batting_j.how_out) in ('not out','forced retirement','retired hurt','retired not out') then 1 else 0 end) desc;


CREATE OR REPLACE VIEW batting_j_11_high_score_sixes AS 
SELECT 
    players.player_name AS Name
    , Batting_j._6s
    , batting_j.score::varchar || (CASE WHEN lower(batting_j.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS Score
    , Batting_j.balls_faced
    , Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting_j.PlayerID
where batting_j._6s > 0
ORDER BY Batting_j._6s DESC;


--drop view batting_j_12_score_by_posn_1stXI;
CREATE OR REPLACE VIEW batting_j_12_score_by_posn_1stXI AS
select * from (
    SELECT 
        Batting_j.batting_position
        , case when Batting_j.batting_position in (1,2) then '1 or 2' else Batting_j.batting_position::varchar end as bat_pos
        , z_j_batpos_max.MaxOfScore
        , Batting_j.balls_faced
        , players.player_name AS Batter, Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Grade, Seasons_j.Association
        , rank() over (partition by (case when Batting_j.batting_position in (1,2) then '1 or 2' else Batting_j.batting_position::varchar end) order by MaxOfScore desc) as tmp
    FROM Seasons_j 
    INNER JOIN Matches_j
    ON Seasons_j.SeasonID = Matches_j.SeasonID
    INNER JOIN Innings_j 
    ON Matches_j.MatchID = Innings_j.MatchID
    INNER JOIN Batting_j
    ON Innings_j.InningsID = Batting_j.InningsID
    INNER JOIN Players 
    ON Players.PlayerID = Batting_j.PlayerID
    INNER JOIN z_j_batpos_max
    ON Batting_j.batting_position = z_j_batpos_max.batting_position
    AND Batting_j.Score = z_j_batpos_max.MaxOfScore
    where z_j_batpos_max.eleven = '1st'
    and seasons_j.eleven = '1st'
) a
where tmp=1
ORDER BY batting_position;

--drop view batting_j_13_score_by_posn_2ndXI;
CREATE OR REPLACE VIEW batting_j_13_score_by_posn_2ndXI AS 
select * from (
    SELECT 
        Batting_j.batting_position
        , case when Batting_j.batting_position in (1,2) then '1 or 2' else Batting_j.batting_position::varchar end as bat_pos
        , z_j_batpos_max.MaxOfScore
        , Batting_j.balls_faced
        , players.player_name AS Batter, Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Grade, Seasons_j.Association
        , rank() over (partition by (case when Batting_j.batting_position in (1,2) then '1 or 2' else Batting_j.batting_position::varchar end) order by MaxOfScore desc) as tmp
    FROM Seasons_j 
    INNER JOIN Matches_j
    ON Seasons_j.SeasonID = Matches_j.SeasonID
    INNER JOIN Innings_j 
    ON Matches_j.MatchID = Innings_j.MatchID
    INNER JOIN Batting_j
    ON Innings_j.InningsID = Batting_j.InningsID
    INNER JOIN Players 
    ON Players.PlayerID = Batting_j.PlayerID
    INNER JOIN z_j_batpos_max
    ON Batting_j.batting_position = z_j_batpos_max.batting_position
    AND Batting_j.Score = z_j_batpos_max.MaxOfScore
    where z_j_batpos_max.eleven = '2nd'
    and seasons_j.eleven = '2nd'
) a
where tmp=1
ORDER BY batting_position;

--drop view batting_j_14_score_by_posn_3rdXI;
CREATE OR REPLACE VIEW batting_j_14_score_by_posn_3rdXI AS 
select * from (
    SELECT 
        Batting_j.batting_position
        , case when Batting_j.batting_position in (1,2) then '1 or 2' else Batting_j.batting_position::varchar end as bat_pos
        , z_j_batpos_max.MaxOfScore
        , Batting_j.balls_faced
        , players.player_name AS Batter, Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Grade, Seasons_j.Association
        , rank() over (partition by (case when Batting_j.batting_position in (1,2) then '1 or 2' else Batting_j.batting_position::varchar end) order by MaxOfScore desc) as tmp
    FROM Seasons_j 
    INNER JOIN Matches_j
    ON Seasons_j.SeasonID = Matches_j.SeasonID
    INNER JOIN Innings_j 
    ON Matches_j.MatchID = Innings_j.MatchID
    INNER JOIN Batting_j
    ON Innings_j.InningsID = Batting_j.InningsID
    INNER JOIN Players 
    ON Players.PlayerID = Batting_j.PlayerID
    INNER JOIN z_j_batpos_max
    ON Batting_j.batting_position = z_j_batpos_max.batting_position
    AND Batting_j.Score = z_j_batpos_max.MaxOfScore
    where z_j_batpos_max.eleven = '3rd'
    and seasons_j.eleven = '3rd'
) a
where tmp=1
ORDER BY batting_position;


CREATE OR REPLACE VIEW batting_j_15_fast_slow_longest AS
SELECT players.player_name AS Name
, Batting_j.balls_faced
, batting_j.score::varchar || (CASE WHEN lower(batting_j.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS Score
, Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting_j.PlayerID
where Batting_j.balls_faced > 100
ORDER BY Batting_j.balls_faced DESC , Batting_j.Score DESC;


CREATE OR REPLACE VIEW batting_j_16_fast_slow_fastest AS
SELECT 
    Players.player_name AS Name
    , 100*batting_j.score::float/batting_j.balls_faced AS strike_rate
    , batting_j.score::varchar || (CASE WHEN lower(batting_j.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS Runs
    , Batting_j.balls_faced
    , Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting_j.PlayerID
WHERE Batting_j.Score > 29
and Batting_j.balls_faced > 0
ORDER BY strike_rate DESC;

CREATE OR REPLACE VIEW batting_j_17_fast_slow_slowest AS
SELECT 
    Players.player_name AS Name
    , 100*batting_j.score::float/batting_j.balls_faced AS strike_rate
    , batting_j.score::varchar || (CASE WHEN lower(batting_j.how_out) in ('not out','forced retirement','retired hurt','retired not out') then '*' else '' end) AS Runs
    , Batting_j.balls_faced
    , Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting_j.PlayerID
WHERE Batting_j.balls_faced > 59
ORDER BY strike_rate;


CREATE OR REPLACE VIEW batting_j_18_dismissals_ct AS
SELECT Name, C::float/dismissals AS percentage, dismissals, C as caught
FROM z_j_bat_ind_dismissal_types
WHERE dismissals > 9
ORDER BY percentage DESC , dismissals DESC;


CREATE OR REPLACE VIEW batting_j_19_dismissals_b AS
SELECT Name, B::float/dismissals AS percentage, dismissals, B as bowled
FROM z_j_bat_ind_dismissal_types
WHERE dismissals > 9
ORDER BY percentage DESC , dismissals DESC;


CREATE OR REPLACE VIEW batting_j_20_dismissals_lbw AS
SELECT Name, LBW::float/dismissals AS percentage, dismissals, LBW
FROM z_j_bat_ind_dismissal_types
WHERE dismissals > 9
ORDER BY percentage DESC , dismissals DESC;

CREATE OR REPLACE VIEW batting_j_21_dismissals_no_lbw AS
SELECT dismissals, Name
FROM z_j_bat_ind_dismissal_types
WHERE LBW = 0
ORDER BY dismissals DESC;

CREATE OR REPLACE VIEW batting_j_22_dismissals_st AS
SELECT ST as stumpings, Name
FROM z_j_bat_ind_dismissal_types
WHERE dismissals > 0
ORDER BY stumpings DESC;


CREATE OR REPLACE VIEW batting_j_23_partnerships_highest AS
SELECT 
    Runs
    , Wicket
    , "Player 1"
    , "Player 2"
    , Opponent, Year, Round, Eleven, Grade, Association
FROM z_j_batting_partnerships_highest 
ORDER BY p DESC;


-- change from overall to 1st XI
CREATE OR REPLACE VIEW batting_j_24_partnerships_wicket_1stXI AS
SELECT 
    a.Runs
    , a.Wicket
    , a."Player 1"
    , a."Player 2"
    , a.Opponent, a.Year, a.Round, a.Eleven, a.Grade, a.Association
FROM z_j_batting_partnerships_highest a
INNER JOIN (
    SELECT wicket
        , max(p) as p
    FROM z_j_batting_partnerships_highest
    where eleven = '1st'
    group by wicket
) max_part
on a.p = max_part.p
and a.wicket = max_part.wicket
WHERE a.eleven = '1st'
order by a.wicket
;


CREATE OR REPLACE VIEW batting_j_25_partnerships_wicket_2ndXI AS
SELECT 
    a.Runs
    , a.Wicket
    , a."Player 1"
    , a."Player 2"
    , a.Opponent, a.Year, a.Round, a.Eleven, a.Grade, a.Association
FROM z_j_batting_partnerships_highest a
INNER JOIN (
    SELECT wicket
        , max(p) as p
    FROM z_j_batting_partnerships_highest
    where eleven = '2nd'
    group by wicket
) max_part
on a.p = max_part.p
and a.wicket = max_part.wicket
WHERE a.eleven = '2nd'
order by a.wicket
;


CREATE OR REPLACE VIEW batting_j_26_partnerships_wicket_3rdXI AS
SELECT 
    a.Runs
    , a.Wicket
    , a."Player 1"
    , a."Player 2"
    , a.Opponent, a.Year, a.Round, a.Eleven, a.Grade, a.Association
FROM z_j_batting_partnerships_highest a
INNER JOIN (
    SELECT wicket
        , max(p) as p
    FROM z_j_batting_partnerships_highest
    where eleven = '3rd'
    group by wicket
) max_part
on a.p = max_part.p
and a.wicket = max_part.wicket
WHERE a.eleven = '3rd'
order by a.wicket
;

-- drop view batting_j_27_run_out_involvements;
CREATE OR REPLACE VIEW batting_j_27_run_out_involvements AS
select 
    p1.player_name as "Name"
    , b.inn as innings_j
    , sum(out_batter+not_out_batter) as run_outs
    , sum(out_batter) as out_batter
    , sum(not_out_batter) as not_out_batter
    , to_char(100*sum(out_batter+not_out_batter)/b.inn, '990D9%') as "R/O per Inn"
from (
    select  
        b1.playerid as player1
        , count(*) as out_batter
        , 0 as not_out_batter
    from batting_j as b1
    where how_out = 'Run Out'
    group by player1, not_out_batter

    union all 

    select  
        b1.not_out_batter as player1
        , 0 as out_batter
        , count(*) as not_out_batter
    from batting_j as b1
    where how_out = 'Run Out'
    group by player1, out_batter
) aa
inner join players as p1
on aa.Player1 = p1.playerid
inner join batting_j_01_summary_ind b
on aa.player1 = b.playerid
group by player_name, b.inn
order by run_outs desc, out_batter desc, player_name
;


CREATE OR REPLACE VIEW batting_j_28_finals_runs AS
SELECT 
    players.player_name AS Name
    , Count(Batting_j.Score) as innings_j
    , coalesce(Sum(Batting_j.Score),0) AS Runs
    , CASE WHEN Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0
        THEN -9 ELSE Sum(Batting_j.Score)::float/(Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) END AS Average
FROM Matches_j
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN players
ON Players.PlayerID = Batting_j.PlayerID
where matches_j.round in ('SF','GF')
GROUP BY players.player_name
HAVING coalesce(Sum(Batting_j.Score),0) > 99
ORDER BY Runs DESC;

CREATE OR REPLACE VIEW batting_j_29_finals_ave AS
SELECT 
    players.player_name AS Name
    , Count(Batting_j.Score) as innings_j
    , coalesce(Sum(Batting_j.Score),0) AS Runs
    , CASE WHEN Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0
        THEN -9 ELSE Sum(Batting_j.Score)::float/(Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) END AS Average
FROM Matches_j
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN players
ON Players.PlayerID = Batting_j.PlayerID
where matches_j.round in ('SF','GF')
GROUP BY players.player_name
HAVING coalesce(Sum(Batting_j.Score),0) > 99
ORDER BY Average DESC;

-- per opponent
CREATE OR REPLACE VIEW batting_j_30_opp_runs AS
SELECT 
    players.player_name AS Name
    , regexp_replace(matches_j.Opponent,' (II|III|IV|V|VI)$','',1,1,'c') AS opponent
    , Count(Batting_j.Score) as innings_j
    , coalesce(Sum(Batting_j.Score),0) AS Runs
    , CASE WHEN Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0
        THEN -9 ELSE Sum(Batting_j.Score)::float/(Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) END AS Average
FROM Matches_j
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN players
ON Players.PlayerID = Batting_j.PlayerID
--where matches_j.round in ('SF','GF')
GROUP BY players.player_name, opponent
HAVING coalesce(Sum(Batting_j.Score),0) > 199
ORDER BY Runs DESC;

CREATE OR REPLACE VIEW batting_j_31_opp_ave AS
SELECT 
    players.player_name AS Name
    , regexp_replace(matches_j.Opponent,' (II|III|IV|V|VI)$','',1,1,'c') AS opponent
    , Count(Batting_j.Score) as innings_j
    , coalesce(Sum(Batting_j.Score),0) AS Runs
    , CASE WHEN Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0
        THEN -9 ELSE Sum(Batting_j.Score)::float/(Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) END AS Average
FROM Matches_j
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN players
ON Players.PlayerID = Batting_j.PlayerID
--where matches_j.round in ('SF','GF')
GROUP BY players.player_name, opponent
--HAVING coalesce(Sum(Batting_j.Score),0) > 299
having Count(Batting_j.Score) > 4
ORDER BY Average DESC;

--select 
--ground ,
--case when ground similar to '(Bulldog Park|Park 21|Adelaide Lutheran|Schmidt Oval)%' then 'home' else 'away' end as ha
--, count(*)  as _c
--from matches_j
--group by  ground ,ha
--order by ha, _c desc;

-- venue
CREATE OR REPLACE VIEW batting_j_32_ha_runs AS
SELECT 
    players.player_name AS Name
    , case when ground similar to '(Bulldog Park|Park 21|Adelaide Lutheran|Schmidt Oval)%' then 'home' else 'away' end as ha
    , Count(Batting_j.Score) as innings_j
    , coalesce(Sum(Batting_j.Score),0) AS Runs
    , CASE WHEN Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0
        THEN -9 ELSE Sum(Batting_j.Score)::float/(Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) END AS Average
FROM Matches_j
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN players
ON Players.PlayerID = Batting_j.PlayerID
where matches_j.ground is not null
GROUP BY players.player_name, opponent
HAVING coalesce(Sum(Batting_j.Score),0) > 199
ORDER BY Runs DESC;

CREATE OR REPLACE VIEW tmp_batting_33_ha_ave AS
SELECT 
    players.player_name AS Name
    , case when ground similar to '(Bulldog Park|Park 21|Adelaide Lutheran|Schmidt Oval)%' then 'home' else 'away' end as ha
    , Count(Batting_j.Score) as innings_j
    , coalesce(Sum(Batting_j.Score),0) AS Runs
    , CASE WHEN Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)=0
        THEN -9 ELSE Sum(Batting_j.Score)::float/(Count(Batting_j.Score)-Sum(CASE WHEN lower(batting_j.how_out) in ('not out','retired hurt','retired not out','forced retirement') then 1 else 0 end)) END AS Average
FROM Matches_j
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN players
ON Players.PlayerID = Batting_j.PlayerID
--where matches_j.round in ('SF','GF')
GROUP BY players.player_name, ha
HAVING coalesce(Sum(Batting_j.Score),0) > 100
ORDER BY Average DESC;

CREATE OR REPLACE VIEW batting_j_33_ha_ave AS
select 
    a.Name
    , a.innings_j as home_inn, a.runs as home_runs, a.Average as home_average
    , b.innings_j as away_inn, b.runs as away_runs, b.Average as away_average
    , a.Average-b.Average as diff
from tmp_batting_33_ha_ave a
inner join tmp_batting_33_ha_ave b
on a.Name = b.Name
and a.ha='home'
and b.ha='away'
order by abs(a.Average-b.Average) desc
;