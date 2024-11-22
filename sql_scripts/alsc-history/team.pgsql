/****************************************************************************************************
* Season Summary
****************************************************************************************************/

CREATE OR REPLACE VIEW team_01_season_summary_all AS
SELECT 
    Seasons.Year
    , Count(Matches.MatchID) AS Played
    , Sum(case when upper(matches.result)='W2' then 1 else 0 end) AS WO
    , Sum(case when upper(matches.result)='W1' then 1 else 0 end) AS W1
    , Sum(case when upper(matches.result) in ('D','T') then 1 else 0 end) AS D
    , Sum(case when upper(matches.result)='L1' then 1 else 0 end) AS L1
    , Sum(case when upper(matches.result)='L2' then 1 else 0 end) AS LO
    , Seasons.posn as "Position"
    , Seasons.Association
    , Seasons.Grade
    , players.surname || ', ' || players.firstname AS Captain
    , players_1.surname || ', ' || players_1.firstname AS "Vice Captain"
    , seasons.eleven

FROM Seasons
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN players 
ON Players.PlayerID = Seasons.Captain
LEFT JOIN players AS players_1 
ON Players_1.PlayerID = Seasons.vice_captain
--WHERE seasons.eleven = '1st' and (seasons.grade != 'T20' or seasons.grade is null)
GROUP BY Seasons.Year, Seasons.posn, Seasons.Grade, players.surname || ', ' || players.firstname, players_1.surname || ', ' || players_1.firstname, Seasons.Association, eleven
ORDER BY Seasons.Year;


/****************************************************************************************************
* Team Matches Against
****************************************************************************************************/
--DROP VIEW team_04_matches_against_all;
CREATE OR REPLACE VIEW team_04_matches_against_all AS
SELECT 
    --matches.Opponent
    regexp_replace(matches.Opponent,' (II|III|IV|V|VI)$','',1,1,'c') AS "Opponent"
    , Count(matches.matchid) AS Played
    , Sum(case when upper(matches.result)='W2' then 1 else 0 end) AS WO
    , Sum(case when upper(matches.result)='W1' then 1 else 0 end) AS W1
    , Sum(case when upper(matches.result) in ('D','T') then 1 else 0 end) AS D
    , Sum(case when upper(matches.result)='L1' then 1 else 0 end) AS L1
    , Sum(case when upper(matches.result)='L2' then 1 else 0 end) AS LO
    , (0.00+(Sum(case when upper(matches.result) in ('W1','W2') then 1 else 0 end)))/Count(matches.matchid) AS "Win %"
FROM seasons 
INNER JOIN matches 
ON seasons.seasonID = matches.seasonID
WHERE (((seasons.year)<>'1994/95'))
GROUP BY "Opponent"
ORDER BY Count(matches.matchid) DESC , W1 DESC;


/****************************************************************************************************
* Team Scores
****************************************************************************************************/

CREATE OR REPLACE VIEW team_05_scores_highest AS
SELECT 
    case when Sum(case when lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 
    then '' 
    else Sum(case when lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) || '/' end 
    || (Sum(batting.score)+max(innings.extras)) 
    AS Score
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Seasons.Eleven
    , Seasons.Grade
    , Innings.InningsNO
    , Sum(batting.score)+max(innings.extras) AS Expr1
    , Innings.InningsID
    , Seasons.Association
FROM Seasons 
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID 
INNER JOIN batting 
ON Innings.InningsID = Batting.InningsID
GROUP BY Matches.Opponent, Matches.Round, Seasons.Eleven, Seasons.Grade, Innings.InningsNO, Innings.InningsID, Seasons.Year, Seasons.Association, Matches.Ground, Innings.InningsID, Seasons.Year
HAVING (case when Sum(case when lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 
          then ''
          else Sum(case when lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) || '/' end 
        || Sum(batting.score)+max(innings.extras)) != '0/'
ORDER BY Sum(batting.Score)+max(Innings.Extras) DESC;



CREATE OR REPLACE VIEW team_06_scores_lowest AS
SELECT 
    case when Sum(case when lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 
    then '' 
    else Sum(case when lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) || '/' end 
    || (Sum(batting.score)+max(innings.extras)) 
    AS Score
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Seasons.Eleven
    , Seasons.Grade
    , Innings.InningsNO
    , Sum(batting.score)+max(innings.extras) AS Expr1
    , Innings.InningsID
    , Seasons.Association
FROM Seasons 
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID 
INNER JOIN batting 
ON Innings.InningsID = Batting.InningsID
GROUP BY Matches.Opponent, Matches.Round, Seasons.Eleven, Seasons.Grade, Innings.InningsNO, Innings.InningsID, Seasons.Year, Seasons.Association, Matches.Ground, Innings.InningsID, Seasons.Year
HAVING Sum(case when lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10
ORDER BY Sum(batting.Score)+max(Innings.Extras);


CREATE OR REPLACE VIEW team_07_scores_opp_highest AS
SELECT 
    case when max(z_wickin.num_wickets)=10 then '' else max(z_wickin.num_wickets) || '/' end || 
        Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.extras) 
        AS Score
    , Sum(bowling.overs) ||'.'|| Sum(bowling.extra_balls) AS "Overs Bowled"
    , 6*(Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras))/Sum(6*bowling.overs+bowling.extra_balls) AS "Run Rate"
    , Matches.Opponent
    , Seasons.Year
    , Matches.Round
    , Matches.Ground
    , Seasons.Eleven
    , Innings.InningsNO
    , Matches.MatchID
    , Seasons.Association
    , Seasons.Grade
FROM Seasons 
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN z_wickin 
ON Innings.InningsID = z_wickin.InningsID 
INNER JOIN Bowling 
ON Innings.InningsID = Bowling.InningsID 
GROUP BY Matches.Opponent, Matches.Round, Matches.Ground, Seasons.Eleven, Seasons.Grade, Matches.MatchID, Innings.InningsNO, Seasons.Year, Seasons.Association, Innings.InningsID, Innings.InningsNO, Seasons.Year
ORDER BY Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras) DESC;



CREATE OR REPLACE VIEW team_08_scores_opp_lowest AS
SELECT case when max(z_wickin.num_wickets)=10 then '' else max(z_wickin.num_wickets) || '/' end || Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.extras) AS Score
, Sum(bowling.overs) ||'.'|| Sum(bowling.extra_balls) AS "Overs Bowled"
, 6*(Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras))/Sum(6*bowling.overs+bowling.extra_balls) AS "Run Rate"
, Matches.Opponent
, Seasons.Year
, Matches.Round
, Matches.Ground
, Seasons.Eleven
, Innings.InningsNO
, Matches.MatchID
, Innings.Inningsid
, Seasons.Association
, Seasons.Grade

FROM Seasons 
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN z_wickin 
ON Innings.InningsID = z_wickin.InningsID 
INNER JOIN Bowling 
ON Innings.InningsID = Bowling.InningsID 

GROUP BY Matches.Opponent, Matches.Round, Matches.Ground, Seasons.Eleven, Seasons.Grade, Matches.MatchID, Innings.InningsNO, Seasons.Year, Seasons.Association, Innings.InningsID, Innings.InningsNO, Seasons.Year
HAVING max(z_wickin.num_wickets)=10
ORDER BY Sum(Bowling.no_balls)+Sum(Bowling.Wides)+Sum(Bowling.runs_off_bat)+max(Innings.Extras)
;


-- drop view team_09_misc_fast;
CREATE OR REPLACE VIEW team_09_misc_fast AS
SELECT  6*(Sum(Batting.score)+max(innings.extras))/(6*max(innings.bat_overs) + CASE WHEN max(innings.extra_balls)>0 then max(innings.extra_balls) else 0 end) AS "Run Rate"
    , max(innings.bat_overs) ||'.'|| (CASE WHEN max(innings.extra_balls)>0 then max(innings.extra_balls) else 0 end) AS "Overs"
    , (CASE WHEN Sum(CASE WHEN lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
        else (Sum(CASE WHEN lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') end) || Sum(Batting.Score)+max(Innings.Extras) AS "Score"
    , Matches.opponent as "Opponent"
    , Seasons.Year as "Year"
    , Matches.round as "Round"
    , Seasons.Eleven as "XI"
    , Seasons.Association as "Association"
    , Seasons.Grade as "Grade"
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
GROUP BY Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association, Matches.Ground, Innings.InningsID
HAVING (max(innings.bat_overs)>15) AND (
    (CASE WHEN Sum(CASE WHEN lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
    else (Sum(CASE WHEN lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') || 
    Sum(Batting.Score)+max(Innings.Extras) end)!='0/')
ORDER BY 6*(Sum(Batting.score)+max(innings.extras))/(6*max(innings.bat_overs) + CASE WHEN max(innings.extra_balls)>0 then max(innings.extra_balls) else 0 end) DESC , Sum(Batting.Score)+max(Innings.Extras) DESC;


-- drop view team_10_misc_slow;
CREATE OR REPLACE VIEW team_10_misc_slow AS
SELECT  6*(Sum(Batting.score)+max(innings.extras))/(6*max(innings.bat_overs) + CASE WHEN max(innings.extra_balls)>0 then max(innings.extra_balls) else 0 end) AS "Run Rate"
    , max(innings.bat_overs) ||'.'|| (CASE WHEN max(innings.extra_balls)>0 then max(innings.extra_balls) else 0 end) AS "Overs"
    , (CASE WHEN Sum(CASE WHEN lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
        else (Sum(CASE WHEN lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') end) || Sum(Batting.Score)+max(Innings.Extras) AS "Score"
    , Matches.opponent as "Opponent"
    , Seasons.Year as "Year"
    , Matches.round as "Round"
    , Seasons.Eleven as "XI"
    , Seasons.Association as "Association"
    , Seasons.Grade as "Grade"
FROM Seasons 
INNER JOIN Matches
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN Innings
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting
ON Innings.InningsID = Batting.InningsID
GROUP BY Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Seasons.Association, Matches.Ground, Innings.InningsID
HAVING (max(innings.bat_overs)>15) AND (
    (CASE WHEN Sum(CASE WHEN lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
    else (Sum(CASE WHEN lower(batting.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') || 
    Sum(Batting.Score)+max(Innings.Extras) end)!='0/')
ORDER BY 6*(Sum(Batting.score)+max(innings.extras))/(6*max(innings.bat_overs) + CASE WHEN max(innings.extra_balls)>0 then max(innings.extra_balls) else 0 end) , Sum(Batting.Score)+max(Innings.Extras);


--   drop view team_11_misc_margin;
CREATE OR REPLACE VIEW team_11_misc_margin AS
SELECT 
    z_batting_totals.runs-z_bowling_totals.runs AS "Margin"
    , z_batting_totals.Score AS "For"
    , z_bowling_totals.Score AS "Against"
    , Matches.opponent as "Opponent"
    , Seasons.Year as "Year"
    , Matches.round as "Round"
    , Seasons.Eleven as "XI"
    , Seasons.Association as "Association"
    , Seasons.Grade as "Grade"
    , Matches.MatchID
    , z_batting_totals.runs
    , z_bowling_totals.runs as runs_against
FROM Seasons 
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN z_bowling_totals 
ON z_bowling_totals.MatchID = Matches.MatchID
INNER JOIN z_batting_totals 
ON z_batting_totals.MatchID = z_bowling_totals.MatchID

GROUP BY z_batting_totals.Score, z_bowling_totals.Score, Matches.Opponent, Seasons.Year, Matches.Round, Seasons.Eleven, Seasons.Grade, Matches.MatchID, z_batting_totals.runs, z_bowling_totals.runs, Seasons.Association, Matches.MatchID, z_batting_totals.runs, z_bowling_totals.runs
ORDER BY z_batting_totals.runs-z_bowling_totals.runs DESC;


-- drop view team_12_misc_ties;
CREATE OR REPLACE VIEW team_12_misc_ties AS
SELECT 
    z_batting_totals.runs AS "Score"
    , Matches.opponent as "Opponent"
    , Seasons.Year as "Year"
    , Matches.round as "Round"
    , Seasons.Eleven as "XI"
    , Seasons.Association as "Association"
    , Seasons.Grade as "Grade"
FROM Seasons 
INNER JOIN Matches 
ON Seasons.SeasonID = Matches.SeasonID
INNER JOIN z_batting_totals 
ON z_batting_totals.MatchID = Matches.MatchID
WHERE upper(matches.result)='T'
ORDER BY Seasons.Year, Matches.Round;


CREATE OR REPLACE VIEW team_13_ind_most_matches AS
SELECT 
    players.Surname ||', '||players.firstname AS Name
    , Sum(CASE WHEN innings.inningsno=1 Or innings.inningsno=2 then 1 else 0 end) AS Mat
    , batting_01_summary_ind.Debut
    , batting_01_summary_ind."Last Season"
    , Players.PlayerID
FROM Matches 
INNER JOIN Innings 
ON Matches.MatchID = Innings.MatchID
INNER JOIN Batting 
ON Innings.InningsID = Batting.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting.PlayerID
INNER JOIN batting_01_summary_ind 
ON batting_01_summary_ind.PlayerID = Players.PlayerID

GROUP BY players.Surname ||', '||players.firstname, batting_01_summary_ind.Debut, batting_01_summary_ind."Last Season", Players.PlayerID, Players.PlayerID
ORDER BY Sum(CASE WHEN innings.inningsno=1 Or innings.inningsno=2 then 1 else 0 end) DESC;


--drop view team_14_ind_most_matches_capt;
CREATE OR REPLACE VIEW team_14_ind_most_matches_capt AS
SELECT players.Surname ||', '|| players.firstname AS "Name"
    , Count(Matches.Captain) AS "Matches"
    , Sum((CASE WHEN upper(matches.result)='W2' then 1 else 0 end)) AS "WO"
    , Sum((CASE WHEN upper(matches.result)='W1' then 1 else 0 end)) AS "W1"
    , Sum((CASE WHEN upper(matches.result)='D'  then 1 else 0 end)) AS "D"
    , Sum((CASE WHEN upper(matches.result)='T'  then 1 else 0 end)) AS "T"
    , Sum((CASE WHEN upper(matches.result)='L1' then 1 else 0 end)) AS "L1"
    , Sum((CASE WHEN upper(matches.result)='L2' then 1 else 0 end)) AS "LO"
    , Sum((CASE WHEN upper(matches.result) in ('W2','W1') then 1 else 0 end)::float)*100/Count(matches.captain) AS "Win Pct"
    , Sum((CASE WHEN matches.Round='GF' And upper(matches.result) in ('W1','W2') then 1 else 0 end)) AS "Premierships"
FROM Seasons INNER JOIN (Players INNER JOIN Matches ON Players.PlayerID = Matches.Captain) ON Seasons.SeasonID = Matches.SeasonID
GROUP BY players.Surname ||', '|| players.firstname
ORDER BY Count(Matches.Captain) DESC 
    , Sum((CASE WHEN upper(matches.result)='W2' then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches.result)='W1' then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches.result)='D'  then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches.result)='T'  then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches.result)='L1' then 1 else 0 end));


--DROP VIEW team_15_ind_youngest;
CREATE OR REPLACE VIEW team_15_ind_youngest AS
SELECT z_all_player_dates."Name"
    , AGE(z_all_player_dates.debut,z_all_player_dates.dob)::VARCHAR AS "Age on Debut"
    , z_all_player_dates."First Season"
    , AGE(z_all_player_dates."Final Game",z_all_player_dates.dob)::VARCHAR AS "Age on Final Game"
FROM z_all_player_dates
GROUP BY z_all_player_dates."Name", AGE(z_all_player_dates.debut,z_all_player_dates.dob), "First Season", "Final Game", z_all_player_dates.dob
HAVING   AGE(z_all_player_dates.debut,z_all_player_dates.dob) Is Not Null
ORDER BY AGE(z_all_player_dates.debut,z_all_player_dates.dob);


--drop view team_16_ind_most_matches_together;
CREATE OR REPLACE VIEW team_16_ind_most_matches_together AS
select 
    p1.name_fl as "Player 1"
    , p2.name_fl as "Player 2"
    , aa.matches
    , aa.playerid1
    , aa.playerid2
from (
    select 
        playerid1
        , playerid2
        , count(*) as matches
    from (
        select distinct  
            b1.playerid as playerid1
            , b2.playerid as playerid2
            , innings.matchid 
        from batting as b1
        inner join batting as b2 
        on b1.inningsid = b2.inningsid 
        and b1.playerid < b2.playerid
        inner join innings
        on b1.inningsid = innings.inningsid
        --where b1.inningsid < 10 --test
    ) a
    group by playerid1, playerid2
) aa
inner join players as p1
on aa.playerid1 = p1.playerid
inner join players as p2
on aa.playerid2 = p2.playerid
order by matches desc
;

-- select * from players

-- select * from matches where result='T'
-- select * from z_batting_totals where matchid = 417
-- select * from innings where matchid = 417

-- select * from z_all_player_dates
-- order by "Name"


-- select opponent, date1
--     , seasons.association
--     , seasons.eleven
--     , seasons.grade
--     , seasons.year
-- from matches
-- inner join seasons
-- on matches.seasonid = seasons.seasonid
-- where matches.round = 'GF'
-- order by year