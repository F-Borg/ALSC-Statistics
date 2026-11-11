/****************************************************************************************************
* Season Summary
****************************************************************************************************/

CREATE OR REPLACE VIEW team_j_01_season_summary_all AS
SELECT 
    Seasons_j.Year
    , Count(Matches_j.MatchID) AS Played
    , Sum(case when upper(matches_j.result)='W2' then 1 else 0 end) AS WO
    , Sum(case when upper(matches_j.result)='W1' then 1 else 0 end) AS W1
    , Sum(case when upper(matches_j.result) in ('D','T') then 1 else 0 end) AS D
    , Sum(case when upper(matches_j.result)='L1' then 1 else 0 end) AS L1
    , Sum(case when upper(matches_j.result)='L2' then 1 else 0 end) AS LO
    , Seasons_j.posn as "Position"
    , Seasons_j.Association
    , Seasons_j.Grade
    , players.surname || ', ' || players.firstname AS Captain
    , players_1.surname || ', ' || players_1.firstname AS "Vice Captain"
    , seasons_j.eleven

FROM Seasons_j
INNER JOIN Matches_j 
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN players 
ON Players.PlayerID = Seasons_j.Captain
LEFT JOIN players AS players_1 
ON Players_1.PlayerID = Seasons_j.vice_captain
--WHERE seasons_j.eleven = '1st' and (seasons_j.grade != 'T20' or seasons_j.grade is null)
GROUP BY Seasons_j.Year, Seasons_j.posn, Seasons_j.Grade, players.surname || ', ' || players.firstname, players_1.surname || ', ' || players_1.firstname, Seasons_j.Association, eleven
ORDER BY Seasons_j.Year;


/****************************************************************************************************
* Team Matches_j Against
****************************************************************************************************/
--DROP VIEW team_j_04_matches_against_all;
CREATE OR REPLACE VIEW team_j_04_matches_against_all AS
SELECT 
    --matches_j.Opponent
    regexp_replace(matches_j.Opponent,' (II|III|IV|V|VI)$','',1,1,'c') AS "Opponent"
    , Count(matches_j.matchid) AS Played
    , Sum(case when upper(matches_j.result)='W2' then 1 else 0 end) AS WO
    , Sum(case when upper(matches_j.result)='W1' then 1 else 0 end) AS W1
    , Sum(case when upper(matches_j.result) in ('D','T') then 1 else 0 end) AS D
    , Sum(case when upper(matches_j.result)='L1' then 1 else 0 end) AS L1
    , Sum(case when upper(matches_j.result)='L2' then 1 else 0 end) AS LO
    , (0.00+(Sum(case when upper(matches_j.result) in ('W1','W2') then 1 else 0 end)))/Count(matches_j.matchid) AS "Win %"
FROM seasons_j 
INNER JOIN matches_j 
ON seasons_j.seasonID = matches_j.seasonID
WHERE (((seasons_j.year)<>'1994/95'))
GROUP BY "Opponent"
ORDER BY Count(matches_j.matchid) DESC , W1 DESC;


/****************************************************************************************************
* Team Scores
****************************************************************************************************/

CREATE OR REPLACE VIEW team_j_05_scores_highest AS
SELECT 
    case when Sum(case when lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 
    then '' 
    else Sum(case when lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) || '/' end 
    || (Sum(batting_j.score)+max(innings_j.extras)) 
    AS Score
    , Matches_j.Opponent
    , Seasons_j.Year
    , Matches_j.Round
    , Seasons_j.Eleven
    , Seasons_j.Grade
    , Innings_j.InningsNO
    , Sum(batting_j.score)+max(innings_j.extras) AS Expr1
    , Innings_j.InningsID
    , Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j 
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID 
INNER JOIN batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
GROUP BY Matches_j.Opponent, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Innings_j.InningsNO, Innings_j.InningsID, Seasons_j.Year, Seasons_j.Association, Matches_j.Ground, Innings_j.InningsID, Seasons_j.Year
HAVING (case when Sum(case when lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 
          then ''
          else Sum(case when lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) || '/' end 
        || Sum(batting_j.score)+max(innings_j.extras)) != '0/'
ORDER BY Sum(batting_j.Score)+max(Innings_j.Extras) DESC;



CREATE OR REPLACE VIEW team_j_06_scores_lowest AS
SELECT 
    case when Sum(case when lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 
    then '' 
    else Sum(case when lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) || '/' end 
    || (Sum(batting_j.score)+max(innings_j.extras)) 
    AS Score
    , Matches_j.Opponent
    , Seasons_j.Year
    , Matches_j.Round
    , Seasons_j.Eleven
    , Seasons_j.Grade
    , Innings_j.InningsNO
    , Sum(batting_j.score)+max(innings_j.extras) AS Expr1
    , Innings_j.InningsID
    , Seasons_j.Association
FROM Seasons_j 
INNER JOIN Matches_j 
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID 
INNER JOIN batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
GROUP BY Matches_j.Opponent, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Innings_j.InningsNO, Innings_j.InningsID, Seasons_j.Year, Seasons_j.Association, Matches_j.Ground, Innings_j.InningsID, Seasons_j.Year
HAVING Sum(case when lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10
ORDER BY Sum(batting_j.Score)+max(Innings_j.Extras);


CREATE OR REPLACE VIEW team_j_07_scores_opp_highest AS
SELECT 
    case when max(z_j_wickin.num_wickets)=10 then '' else max(z_j_wickin.num_wickets) || '/' end || 
        Sum(Bowling_j.no_balls)+Sum(Bowling_j.Wides)+Sum(Bowling_j.runs_off_bat)+max(Innings_j.extras) 
        AS Score
    , Sum(bowling_j.overs) ||'.'|| Sum(bowling_j.extra_balls) AS "Overs Bowled"
    , 6*(Sum(Bowling_j.no_balls)+Sum(Bowling_j.Wides)+Sum(Bowling_j.runs_off_bat)+max(Innings_j.Extras))/Sum(6*bowling_j.overs+bowling_j.extra_balls) AS "Run Rate"
    , Matches_j.Opponent
    , Seasons_j.Year
    , Matches_j.Round
    , Matches_j.Ground
    , Seasons_j.Eleven
    , Innings_j.InningsNO
    , Matches_j.MatchID
    , Seasons_j.Association
    , Seasons_j.Grade
FROM Seasons_j 
INNER JOIN Matches_j 
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN z_j_wickin 
ON Innings_j.InningsID = z_j_wickin.InningsID 
INNER JOIN Bowling_j 
ON Innings_j.InningsID = Bowling_j.InningsID 
GROUP BY Matches_j.Opponent, Matches_j.Round, Matches_j.Ground, Seasons_j.Eleven, Seasons_j.Grade, Matches_j.MatchID, Innings_j.InningsNO, Seasons_j.Year, Seasons_j.Association, Innings_j.InningsID, Innings_j.InningsNO, Seasons_j.Year
ORDER BY Sum(Bowling_j.no_balls)+Sum(Bowling_j.Wides)+Sum(Bowling_j.runs_off_bat)+max(Innings_j.Extras) DESC;



CREATE OR REPLACE VIEW team_j_08_scores_opp_lowest AS
SELECT case when max(z_j_wickin.num_wickets)=10 then '' else max(z_j_wickin.num_wickets) || '/' end || Sum(Bowling_j.no_balls)+Sum(Bowling_j.Wides)+Sum(Bowling_j.runs_off_bat)+max(Innings_j.extras) AS Score
, Sum(bowling_j.overs) ||'.'|| Sum(bowling_j.extra_balls) AS "Overs Bowled"
, 6*(Sum(Bowling_j.no_balls)+Sum(Bowling_j.Wides)+Sum(Bowling_j.runs_off_bat)+max(Innings_j.Extras))/Sum(6*bowling_j.overs+bowling_j.extra_balls) AS "Run Rate"
, Matches_j.Opponent
, Seasons_j.Year
, Matches_j.Round
, Matches_j.Ground
, Seasons_j.Eleven
, Innings_j.InningsNO
, Matches_j.MatchID
, Innings_j.Inningsid
, Seasons_j.Association
, Seasons_j.Grade

FROM Seasons_j 
INNER JOIN Matches_j 
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN z_j_wickin 
ON Innings_j.InningsID = z_j_wickin.InningsID 
INNER JOIN Bowling_j 
ON Innings_j.InningsID = Bowling_j.InningsID 

GROUP BY Matches_j.Opponent, Matches_j.Round, Matches_j.Ground, Seasons_j.Eleven, Seasons_j.Grade, Matches_j.MatchID, Innings_j.InningsNO, Seasons_j.Year, Seasons_j.Association, Innings_j.InningsID, Innings_j.InningsNO, Seasons_j.Year
HAVING max(z_j_wickin.num_wickets)=10
ORDER BY Sum(Bowling_j.no_balls)+Sum(Bowling_j.Wides)+Sum(Bowling_j.runs_off_bat)+max(Innings_j.Extras)
;


-- drop view team_j_09_misc_fast;
CREATE OR REPLACE VIEW team_j_09_misc_fast AS
SELECT  6*(Sum(Batting_j.score)+max(innings_j.extras))/(6*max(innings_j.bat_overs) + CASE WHEN max(innings_j.extra_balls)>0 then max(innings_j.extra_balls) else 0 end) AS "Run Rate"
    , max(innings_j.bat_overs) ||'.'|| (CASE WHEN max(innings_j.extra_balls)>0 then max(innings_j.extra_balls) else 0 end) AS "Overs"
    , (CASE WHEN Sum(CASE WHEN lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
        else (Sum(CASE WHEN lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') end) || Sum(Batting_j.Score)+max(Innings_j.Extras) AS "Score"
    , Matches_j.opponent as "Opponent"
    , Seasons_j.Year as "Year"
    , Matches_j.round as "Round"
    , Seasons_j.Eleven as "XI"
    , Seasons_j.Association as "Association"
    , Seasons_j.Grade as "Grade"
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j
ON Innings_j.InningsID = Batting_j.InningsID
where Seasons_j.Grade <> 'T20'
GROUP BY Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association, Matches_j.Ground, Innings_j.InningsID
HAVING (max(innings_j.bat_overs)>15) AND (
    (CASE WHEN Sum(CASE WHEN lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
    else (Sum(CASE WHEN lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') || 
    Sum(Batting_j.Score)+max(Innings_j.Extras) end)!='0/')
ORDER BY 6*(Sum(Batting_j.score)+max(innings_j.extras))/(6*max(innings_j.bat_overs) + CASE WHEN max(innings_j.extra_balls)>0 then max(innings_j.extra_balls) else 0 end) DESC , Sum(Batting_j.Score)+max(Innings_j.Extras) DESC;


-- drop view team_j_10_misc_slow;
CREATE OR REPLACE VIEW team_j_10_misc_slow AS
SELECT  6*(Sum(Batting_j.score)+max(innings_j.extras))/(6*max(innings_j.bat_overs) + CASE WHEN max(innings_j.extra_balls)>0 then max(innings_j.extra_balls) else 0 end) AS "Run Rate"
    , max(innings_j.bat_overs) ||'.'|| (CASE WHEN max(innings_j.extra_balls)>0 then max(innings_j.extra_balls) else 0 end) AS "Overs"
    , (CASE WHEN Sum(CASE WHEN lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
        else (Sum(CASE WHEN lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') end) || Sum(Batting_j.Score)+max(Innings_j.Extras) AS "Score"
    , Matches_j.opponent as "Opponent"
    , Seasons_j.Year as "Year"
    , Matches_j.round as "Round"
    , Seasons_j.Eleven as "XI"
    , Seasons_j.Association as "Association"
    , Seasons_j.Grade as "Grade"
FROM Seasons_j 
INNER JOIN Matches_j
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN Innings_j
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j
ON Innings_j.InningsID = Batting_j.InningsID
GROUP BY Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Seasons_j.Association, Matches_j.Ground, Innings_j.InningsID
HAVING (max(innings_j.bat_overs)>15) AND (
    (CASE WHEN Sum(CASE WHEN lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
    else (Sum(CASE WHEN lower(batting_j.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') || 
    Sum(Batting_j.Score)+max(Innings_j.Extras) end)!='0/')
ORDER BY 6*(Sum(Batting_j.score)+max(innings_j.extras))/(6*max(innings_j.bat_overs) + CASE WHEN max(innings_j.extra_balls)>0 then max(innings_j.extra_balls) else 0 end) , Sum(Batting_j.Score)+max(Innings_j.Extras);


--   drop view team_j_11_misc_margin;
CREATE OR REPLACE VIEW team_j_11_misc_margin AS
SELECT 
    z_j_batting_totals.runs-z_j_bowling_totals.runs AS "Margin"
    , z_j_batting_totals.Score AS "For"
    , z_j_bowling_totals.Score AS "Against"
    , Matches_j.opponent as "Opponent"
    , Seasons_j.Year as "Year"
    , Matches_j.round as "Round"
    , Seasons_j.Eleven as "XI"
    , Seasons_j.Association as "Association"
    , Seasons_j.Grade as "Grade"
    , Matches_j.MatchID
    , z_j_batting_totals.runs
    , z_j_bowling_totals.runs as runs_against
FROM Seasons_j 
INNER JOIN Matches_j 
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN z_j_bowling_totals 
ON z_j_bowling_totals.MatchID = Matches_j.MatchID
INNER JOIN z_j_batting_totals 
ON z_j_batting_totals.MatchID = z_j_bowling_totals.MatchID

GROUP BY z_j_batting_totals.Score, z_j_bowling_totals.Score, Matches_j.Opponent, Seasons_j.Year, Matches_j.Round, Seasons_j.Eleven, Seasons_j.Grade, Matches_j.MatchID, z_j_batting_totals.runs, z_j_bowling_totals.runs, Seasons_j.Association, Matches_j.MatchID, z_j_batting_totals.runs, z_j_bowling_totals.runs
ORDER BY z_j_batting_totals.runs-z_j_bowling_totals.runs DESC;


-- drop view team_j_12_misc_ties;
CREATE OR REPLACE VIEW team_j_12_misc_ties AS
SELECT 
    z_j_batting_totals.runs AS "Score"
    , Matches_j.opponent as "Opponent"
    , Seasons_j.Year as "Year"
    , Matches_j.round as "Round"
    , Seasons_j.Eleven as "XI"
    , Seasons_j.Association as "Association"
    , Seasons_j.Grade as "Grade"
FROM Seasons_j 
INNER JOIN Matches_j 
ON Seasons_j.SeasonID = Matches_j.SeasonID
INNER JOIN z_j_batting_totals 
ON z_j_batting_totals.MatchID = Matches_j.MatchID
WHERE upper(matches_j.result)='T'
ORDER BY Seasons_j.Year, Matches_j.Round;


CREATE OR REPLACE VIEW team_j_13_ind_most_matches AS
SELECT 
    players.Surname ||', '||players.firstname AS Name
    , Sum(CASE WHEN innings_j.inningsno=1 Or innings_j.inningsno=2 then 1 else 0 end) AS Mat
    , batting_j_01_summary_ind.Debut
    , batting_j_01_summary_ind."Last Season"
    , Players.PlayerID
FROM Matches_j 
INNER JOIN Innings_j 
ON Matches_j.MatchID = Innings_j.MatchID
INNER JOIN Batting_j 
ON Innings_j.InningsID = Batting_j.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting_j.PlayerID
INNER JOIN batting_j_01_summary_ind 
ON batting_j_01_summary_ind.PlayerID = Players.PlayerID

GROUP BY players.Surname ||', '||players.firstname, batting_j_01_summary_ind.Debut, batting_j_01_summary_ind."Last Season", Players.PlayerID, Players.PlayerID
ORDER BY Sum(CASE WHEN innings_j.inningsno=1 Or innings_j.inningsno=2 then 1 else 0 end) DESC;


--drop view team_j_14_ind_most_matches_capt;
CREATE OR REPLACE VIEW team_j_14_ind_most_matches_capt AS
SELECT players.Surname ||', '|| players.firstname AS "Name"
    , Count(Matches_j.Captain) AS "Matches_j"
    , Sum((CASE WHEN upper(matches_j.result)='W2' then 1 else 0 end)) AS "WO"
    , Sum((CASE WHEN upper(matches_j.result)='W1' then 1 else 0 end)) AS "W1"
    , Sum((CASE WHEN upper(matches_j.result)='D'  then 1 else 0 end)) AS "D"
    , Sum((CASE WHEN upper(matches_j.result)='T'  then 1 else 0 end)) AS "T"
    , Sum((CASE WHEN upper(matches_j.result)='L1' then 1 else 0 end)) AS "L1"
    , Sum((CASE WHEN upper(matches_j.result)='L2' then 1 else 0 end)) AS "LO"
    , Sum((CASE WHEN upper(matches_j.result) in ('W2','W1') then 1 else 0 end)::float)*100/Count(matches_j.captain) AS "Win Pct"
    , Sum((CASE WHEN matches_j.Round='GF' And upper(matches_j.result) in ('W1','W2') then 1 else 0 end)) AS "Premierships"
FROM Seasons_j INNER JOIN (Players INNER JOIN Matches_j ON Players.PlayerID = Matches_j.Captain) ON Seasons_j.SeasonID = Matches_j.SeasonID
GROUP BY players.Surname ||', '|| players.firstname
ORDER BY Count(Matches_j.Captain) DESC 
    , Sum((CASE WHEN upper(matches_j.result)='W2' then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches_j.result)='W1' then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches_j.result)='D'  then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches_j.result)='T'  then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches_j.result)='L1' then 1 else 0 end));


--DROP VIEW team_j_15_ind_youngest;
CREATE OR REPLACE VIEW team_j_15_ind_youngest AS
SELECT z_j_all_player_dates."Name"
    , AGE(z_j_all_player_dates.debut,z_j_all_player_dates.dob)::VARCHAR AS "Age on Debut"
    , z_j_all_player_dates."First Season"
    , AGE(z_j_all_player_dates."Final Game",z_j_all_player_dates.dob)::VARCHAR AS "Age on Final Game"
FROM z_j_all_player_dates
GROUP BY z_j_all_player_dates."Name", AGE(z_j_all_player_dates.debut,z_j_all_player_dates.dob), "First Season", "Final Game", z_j_all_player_dates.dob
HAVING   AGE(z_j_all_player_dates.debut,z_j_all_player_dates.dob) Is Not Null
ORDER BY AGE(z_j_all_player_dates.debut,z_j_all_player_dates.dob);


--drop view team_j_16_ind_most_matches_together;
CREATE OR REPLACE VIEW team_j_16_ind_most_matches_together AS
select 
    p1.name_fl as "Player 1"
    , p2.name_fl as "Player 2"
    , aa.matches_j
    , aa.playerid1
    , aa.playerid2
from (
    select 
        playerid1
        , playerid2
        , count(*) as matches_j
    from (
        select distinct  
            b1.playerid as playerid1
            , b2.playerid as playerid2
            , innings_j.matchid 
        from batting_j as b1
        inner join batting_j as b2 
        on b1.inningsid = b2.inningsid 
        and b1.playerid < b2.playerid
        inner join innings_j
        on b1.inningsid = innings_j.inningsid
        --where b1.inningsid < 10 --test
    ) a
    group by playerid1, playerid2
) aa
inner join players as p1
on aa.playerid1 = p1.playerid
inner join players as p2
on aa.playerid2 = p2.playerid
order by matches_j desc
;

-- select * from players

-- select * from matches_j where result='T'
-- select * from z_j_batting_totals where matchid = 417
-- select * from innings_j where matchid = 417

-- select * from z_j_all_player_dates
-- order by "Name"


-- select opponent, date1
--     , seasons_j.association
--     , seasons_j.eleven
--     , seasons_j.grade
--     , seasons_j.year
-- from matches_j
-- inner join seasons_j
-- on matches_j.seasonid = seasons_j.seasonid
-- where matches_j.round = 'GF'
-- order by year