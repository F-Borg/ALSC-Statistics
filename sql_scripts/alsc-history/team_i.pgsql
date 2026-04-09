/****************************************************************************************************
* Season Summary
****************************************************************************************************/

CREATE OR REPLACE VIEW team_i_01_season_summary_all AS
SELECT 
    Seasons_i.Year
    , Count(Matches_i.MatchID) AS Played
    , Sum(case when upper(matches_i.result)='W2' then 1 else 0 end) AS WO
    , Sum(case when upper(matches_i.result)='W1' then 1 else 0 end) AS W1
    , Sum(case when upper(matches_i.result) in ('D','T') then 1 else 0 end) AS D
    , Sum(case when upper(matches_i.result)='L1' then 1 else 0 end) AS L1
    , Sum(case when upper(matches_i.result)='L2' then 1 else 0 end) AS LO
    , Seasons_i.posn as "Position"
    , Seasons_i.Association
    , Seasons_i.Grade
    , players.surname || ', ' || players.firstname AS Captain
    , players_1.surname || ', ' || players_1.firstname AS "Vice Captain"
    , seasons_i.eleven

FROM Seasons_i
INNER JOIN Matches_i 
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN players 
ON Players.PlayerID = Seasons_i.Captain
LEFT JOIN players AS players_1 
ON Players_1.PlayerID = Seasons_i.vice_captain
--WHERE seasons_i.eleven = '1st' and (seasons_i.grade != 'T20' or seasons_i.grade is null)
GROUP BY Seasons_i.Year, Seasons_i.posn, Seasons_i.Grade, players.surname || ', ' || players.firstname, players_1.surname || ', ' || players_1.firstname, Seasons_i.Association, eleven
ORDER BY Seasons_i.Year;


/****************************************************************************************************
* Team Matches_i Against
****************************************************************************************************/
--DROP VIEW team_i_04_matches_against_all;
CREATE OR REPLACE VIEW team_i_04_matches_against_all AS
SELECT 
    --matches_i.Opponent
    regexp_replace(matches_i.Opponent,' (II|III|IV|V|VI)$','',1,1,'c') AS "Opponent"
    , Count(matches_i.matchid) AS Played
    , Sum(case when upper(matches_i.result)='W2' then 1 else 0 end) AS WO
    , Sum(case when upper(matches_i.result)='W1' then 1 else 0 end) AS W1
    , Sum(case when upper(matches_i.result) in ('D','T') then 1 else 0 end) AS D
    , Sum(case when upper(matches_i.result)='L1' then 1 else 0 end) AS L1
    , Sum(case when upper(matches_i.result)='L2' then 1 else 0 end) AS LO
    , (0.00+(Sum(case when upper(matches_i.result) in ('W1','W2') then 1 else 0 end)))/Count(matches_i.matchid) AS "Win %"
FROM seasons_i 
INNER JOIN matches_i 
ON seasons_i.seasonID = matches_i.seasonID
GROUP BY "Opponent"
ORDER BY Count(matches_i.matchid) DESC , W1 DESC;


/****************************************************************************************************
* Team Scores
****************************************************************************************************/

CREATE OR REPLACE VIEW team_i_05_scores_highest AS
SELECT 
    case when Sum(case when lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 
    then '' 
    else Sum(case when lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) || '/' end 
    || (Sum(batting_i.score)+max(innings_i.extras)) 
    AS Score
    , Matches_i.Opponent
    , Seasons_i.Year
    , Matches_i.Round
    , Seasons_i.Eleven
    , Seasons_i.Grade
    , Innings_i.InningsNO
    , Sum(batting_i.score)+max(innings_i.extras) AS Expr1
    , Innings_i.InningsID
    , Seasons_i.Association
FROM Seasons_i 
INNER JOIN Matches_i 
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN Innings_i 
ON Matches_i.MatchID = Innings_i.MatchID 
INNER JOIN batting_i 
ON Innings_i.InningsID = Batting_i.InningsID
GROUP BY Matches_i.Opponent, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Innings_i.InningsNO, Innings_i.InningsID, Seasons_i.Year, Seasons_i.Association, Matches_i.Ground, Innings_i.InningsID, Seasons_i.Year
HAVING (case when Sum(case when lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 
          then ''
          else Sum(case when lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) || '/' end 
        || Sum(batting_i.score)+max(innings_i.extras)) != '0/'
ORDER BY Sum(batting_i.Score)+max(Innings_i.Extras) DESC;

--lowest scores does not work for inclusive - wickets are wierd


CREATE OR REPLACE VIEW team_i_07_scores_opp_highest AS
SELECT 
    case when max(z_i_wickin.num_wickets)=10 then '' else max(z_i_wickin.num_wickets) || '/' end || 
        Sum(Bowling_i.no_balls)+Sum(Bowling_i.Wides)+Sum(Bowling_i.runs_off_bat)+max(Innings_i.extras) 
        AS Score
    , Sum(bowling_i.overs) ||'.'|| Sum(bowling_i.extra_balls) AS "Overs Bowled"
    , 6*(Sum(Bowling_i.no_balls)+Sum(Bowling_i.Wides)+Sum(Bowling_i.runs_off_bat)+max(Innings_i.Extras))/Sum(6*bowling_i.overs+bowling_i.extra_balls) AS "Run Rate"
    , Matches_i.Opponent
    , Seasons_i.Year
    , Matches_i.Round
    , Matches_i.Ground
    , Seasons_i.Eleven
    , Innings_i.InningsNO
    , Matches_i.MatchID
    , Seasons_i.Association
    , Seasons_i.Grade
FROM Seasons_i 
INNER JOIN Matches_i 
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN Innings_i 
ON Matches_i.MatchID = Innings_i.MatchID
INNER JOIN z_i_wickin 
ON Innings_i.InningsID = z_i_wickin.InningsID 
INNER JOIN Bowling_i 
ON Innings_i.InningsID = Bowling_i.InningsID 
GROUP BY Matches_i.Opponent, Matches_i.Round, Matches_i.Ground, Seasons_i.Eleven, Seasons_i.Grade, Matches_i.MatchID, Innings_i.InningsNO, Seasons_i.Year, Seasons_i.Association, Innings_i.InningsID, Innings_i.InningsNO, Seasons_i.Year
ORDER BY Sum(Bowling_i.no_balls)+Sum(Bowling_i.Wides)+Sum(Bowling_i.runs_off_bat)+max(Innings_i.Extras) DESC;


--lowest scores does not work for inclusive - wickets are wierd


-- drop view team_i_09_misc_fast;
CREATE OR REPLACE VIEW team_i_09_misc_fast AS
SELECT  6*(Sum(Batting_i.score)+max(innings_i.extras))/(6*max(innings_i.bat_overs) + CASE WHEN max(innings_i.extra_balls)>0 then max(innings_i.extra_balls) else 0 end) AS "Run Rate"
    , max(innings_i.bat_overs) ||'.'|| (CASE WHEN max(innings_i.extra_balls)>0 then max(innings_i.extra_balls) else 0 end) AS "Overs"
    , (CASE WHEN Sum(CASE WHEN lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
        else (Sum(CASE WHEN lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') end) || Sum(Batting_i.Score)+max(Innings_i.Extras) AS "Score"
    , Matches_i.opponent as "Opponent"
    , Seasons_i.Year as "Year"
    , Matches_i.round as "Round"
    , Seasons_i.Eleven as "XI"
    , Seasons_i.Association as "Association"
    , Seasons_i.Grade as "Grade"
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN Innings_i
ON Matches_i.MatchID = Innings_i.MatchID
INNER JOIN Batting_i
ON Innings_i.InningsID = Batting_i.InningsID
where Seasons_i.Grade <> 'T20'
GROUP BY Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Seasons_i.Association, Matches_i.Ground, Innings_i.InningsID
HAVING (max(innings_i.bat_overs)>15) AND (
    (CASE WHEN Sum(CASE WHEN lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
    else (Sum(CASE WHEN lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') || 
    Sum(Batting_i.Score)+max(Innings_i.Extras) end)!='0/')
ORDER BY 6*(Sum(Batting_i.score)+max(innings_i.extras))/(6*max(innings_i.bat_overs) + CASE WHEN max(innings_i.extra_balls)>0 then max(innings_i.extra_balls) else 0 end) DESC , Sum(Batting_i.Score)+max(Innings_i.Extras) DESC;


-- drop view team_i_10_misc_slow;
CREATE OR REPLACE VIEW team_i_10_misc_slow AS
SELECT  6*(Sum(Batting_i.score)+max(innings_i.extras))/(6*max(innings_i.bat_overs) + CASE WHEN max(innings_i.extra_balls)>0 then max(innings_i.extra_balls) else 0 end) AS "Run Rate"
    , max(innings_i.bat_overs) ||'.'|| (CASE WHEN max(innings_i.extra_balls)>0 then max(innings_i.extra_balls) else 0 end) AS "Overs"
    , (CASE WHEN Sum(CASE WHEN lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
        else (Sum(CASE WHEN lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') end) || Sum(Batting_i.Score)+max(Innings_i.Extras) AS "Score"
    , Matches_i.opponent as "Opponent"
    , Seasons_i.Year as "Year"
    , Matches_i.round as "Round"
    , Seasons_i.Eleven as "XI"
    , Seasons_i.Association as "Association"
    , Seasons_i.Grade as "Grade"
FROM Seasons_i 
INNER JOIN Matches_i
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN Innings_i
ON Matches_i.MatchID = Innings_i.MatchID
INNER JOIN Batting_i
ON Innings_i.InningsID = Batting_i.InningsID
GROUP BY Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Seasons_i.Association, Matches_i.Ground, Innings_i.InningsID
HAVING (max(innings_i.bat_overs)>15) AND (
    (CASE WHEN Sum(CASE WHEN lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end)=10 then '' 
    else (Sum(CASE WHEN lower(batting_i.how_out) in ('not out','dnb','retired hurt','retired not out','forced retirement') then 0 else 1 end) ||'/') || 
    Sum(Batting_i.Score)+max(Innings_i.Extras) end)!='0/')
ORDER BY 6*(Sum(Batting_i.score)+max(innings_i.extras))/(6*max(innings_i.bat_overs) + CASE WHEN max(innings_i.extra_balls)>0 then max(innings_i.extra_balls) else 0 end) , Sum(Batting_i.Score)+max(Innings_i.Extras);


--   drop view team_i_11_misc_margin;
CREATE OR REPLACE VIEW team_i_11_misc_margin AS
SELECT 
    z_i_batting_totals.runs-z_i_bowling_totals.runs AS "Margin"
    , z_i_batting_totals.Score AS "For"
    , z_i_bowling_totals.Score AS "Against"
    , Matches_i.opponent as "Opponent"
    , Seasons_i.Year as "Year"
    , Matches_i.round as "Round"
    , Seasons_i.Eleven as "XI"
    , Seasons_i.Association as "Association"
    , Seasons_i.Grade as "Grade"
    , Matches_i.MatchID
    , z_i_batting_totals.runs
    , z_i_bowling_totals.runs as runs_against
FROM Seasons_i 
INNER JOIN Matches_i 
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN z_i_bowling_totals 
ON z_i_bowling_totals.MatchID = Matches_i.MatchID
INNER JOIN z_i_batting_totals 
ON z_i_batting_totals.MatchID = z_i_bowling_totals.MatchID

GROUP BY z_i_batting_totals.Score, z_i_bowling_totals.Score, Matches_i.Opponent, Seasons_i.Year, Matches_i.Round, Seasons_i.Eleven, Seasons_i.Grade, Matches_i.MatchID, z_i_batting_totals.runs, z_i_bowling_totals.runs, Seasons_i.Association, Matches_i.MatchID, z_i_batting_totals.runs, z_i_bowling_totals.runs
ORDER BY z_i_batting_totals.runs-z_i_bowling_totals.runs DESC;


-- drop view team_i_12_misc_ties;
CREATE OR REPLACE VIEW team_i_12_misc_ties AS
SELECT 
    z_i_batting_totals.runs AS "Score"
    , Matches_i.opponent as "Opponent"
    , Seasons_i.Year as "Year"
    , Matches_i.round as "Round"
    , Seasons_i.Eleven as "XI"
    , Seasons_i.Association as "Association"
    , Seasons_i.Grade as "Grade"
FROM Seasons_i 
INNER JOIN Matches_i 
ON Seasons_i.SeasonID = Matches_i.SeasonID
INNER JOIN z_i_batting_totals 
ON z_i_batting_totals.MatchID = Matches_i.MatchID
WHERE upper(matches_i.result)='T'
ORDER BY Seasons_i.Year, Matches_i.Round;


CREATE OR REPLACE VIEW team_i_13_ind_most_matches AS
SELECT 
    players.Surname ||', '||players.firstname AS Name
    , Sum(CASE WHEN innings_i.inningsno=1 Or innings_i.inningsno=2 then 1 else 0 end) AS Mat
    , batting_i_01_summary_ind.Debut
    , batting_i_01_summary_ind."Last Season"
    , Players.PlayerID
FROM Matches_i 
INNER JOIN Innings_i 
ON Matches_i.MatchID = Innings_i.MatchID
INNER JOIN Batting_i 
ON Innings_i.InningsID = Batting_i.InningsID
INNER JOIN Players 
ON Players.PlayerID = Batting_i.PlayerID
INNER JOIN batting_i_01_summary_ind 
ON batting_i_01_summary_ind.PlayerID = Players.PlayerID

GROUP BY players.Surname ||', '||players.firstname, batting_i_01_summary_ind.Debut, batting_i_01_summary_ind."Last Season", Players.PlayerID, Players.PlayerID
ORDER BY Sum(CASE WHEN innings_i.inningsno=1 Or innings_i.inningsno=2 then 1 else 0 end) DESC;


--drop view team_i_14_ind_most_matches_capt;
CREATE OR REPLACE VIEW team_i_14_ind_most_matches_capt AS
SELECT players.Surname ||', '|| players.firstname AS "Name"
    , Count(Matches_i.Captain) AS "Matches_i"
    , Sum((CASE WHEN upper(matches_i.result)='W2' then 1 else 0 end)) AS "WO"
    , Sum((CASE WHEN upper(matches_i.result)='W1' then 1 else 0 end)) AS "W1"
    , Sum((CASE WHEN upper(matches_i.result)='D'  then 1 else 0 end)) AS "D"
    , Sum((CASE WHEN upper(matches_i.result)='T'  then 1 else 0 end)) AS "T"
    , Sum((CASE WHEN upper(matches_i.result)='L1' then 1 else 0 end)) AS "L1"
    , Sum((CASE WHEN upper(matches_i.result)='L2' then 1 else 0 end)) AS "LO"
    , Sum((CASE WHEN upper(matches_i.result) in ('W2','W1') then 1 else 0 end)::float)*100/Count(matches_i.captain) AS "Win Pct"
    , Sum((CASE WHEN matches_i.Round='GF' And upper(matches_i.result) in ('W1','W2') then 1 else 0 end)) AS "Premierships"
FROM Seasons_i INNER JOIN (Players INNER JOIN Matches_i ON Players.PlayerID = Matches_i.Captain) ON Seasons_i.SeasonID = Matches_i.SeasonID
GROUP BY players.Surname ||', '|| players.firstname
ORDER BY Count(Matches_i.Captain) DESC 
    , Sum((CASE WHEN upper(matches_i.result)='W2' then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches_i.result)='W1' then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches_i.result)='D'  then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches_i.result)='T'  then 1 else 0 end)) DESC 
    , Sum((CASE WHEN upper(matches_i.result)='L1' then 1 else 0 end));


--DROP VIEW team_i_15_ind_youngest;
CREATE OR REPLACE VIEW team_i_15_ind_youngest AS
SELECT z_i_all_player_dates."Name"
    , AGE(z_i_all_player_dates.debut,z_i_all_player_dates.dob)::VARCHAR AS "Age on Debut"
    , z_i_all_player_dates."First Season"
    , AGE(z_i_all_player_dates."Final Game",z_i_all_player_dates.dob)::VARCHAR AS "Age on Final Game"
FROM z_i_all_player_dates
GROUP BY z_i_all_player_dates."Name", AGE(z_i_all_player_dates.debut,z_i_all_player_dates.dob), "First Season", "Final Game", z_i_all_player_dates.dob
HAVING   AGE(z_i_all_player_dates.debut,z_i_all_player_dates.dob) Is Not Null
ORDER BY AGE(z_i_all_player_dates.debut,z_i_all_player_dates.dob);


--drop view team_i_16_ind_most_matches_together;
CREATE OR REPLACE VIEW team_i_16_ind_most_matches_together AS
select 
    p1.name_fl as "Player 1"
    , p2.name_fl as "Player 2"
    , aa.matches_i
    , aa.playerid1
    , aa.playerid2
from (
    select 
        playerid1
        , playerid2
        , count(*) as matches_i
    from (
        select distinct  
            b1.playerid as playerid1
            , b2.playerid as playerid2
            , innings_i.matchid 
        from batting_i as b1
        inner join batting_i as b2 
        on b1.inningsid = b2.inningsid 
        and b1.playerid < b2.playerid
        inner join innings_i
        on b1.inningsid = innings_i.inningsid
        --where b1.inningsid < 10 --test
    ) a
    group by playerid1, playerid2
) aa
inner join players as p1
on aa.playerid1 = p1.playerid
inner join players as p2
on aa.playerid2 = p2.playerid
order by matches_i desc
;

-- select * from players

-- select * from matches_i where result='T'
-- select * from z_i_batting_totals where matchid = 417
-- select * from innings_i where matchid = 417

-- select * from z_i_all_player_dates
-- order by "Name"


-- select opponent, date1
--     , seasons_i.association
--     , seasons_i.eleven
--     , seasons_i.grade
--     , seasons_i.year
-- from matches_i
-- inner join seasons_i
-- on matches_i.seasonid = seasons_i.seasonid
-- where matches_i.round = 'GF'
-- order by year