#########################################################################################################################
#########################################################################################################################
# Setup
#########################################################################################################################
#########################################################################################################################
from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
from math import ceil
import pandas as pd
import python_scripts.text_formats as tf

import importlib
importlib.reload(tf)

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()


############################
# User input               
############################
playerid = 269


############################
# Create Excel doc.
############################
player = pd.read_sql(con=pgconn, sql=f"""select * from players where playerid = {playerid} """)
firstname = player['firstname'][0]
surname = player['surname'][0]
writer = pd.ExcelWriter(f"data/excel/player_summary/{firstname}{surname}-{playerid}.xlsx", engine="xlsxwriter")
wb = writer.book

fmt = tf.add_text_formats(wb)

#########################################################################################################################
#########################################################################################################################
# Player Summary
#########################################################################################################################
#########################################################################################################################
sheetname = 'player_summary'

player['playerid'].to_excel(writer, sheet_name=sheetname, startrow = 1, index=False, header=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:I1',f"{firstname} {surname}",fmt['heading1'])

career_span = pd.read_sql(con=pgconn, sql=f"""select * from team_13_ind_most_matches where playerid = {playerid} """)

# time between first and last Game
career_length = pd.read_sql(con=pgconn, sql=f"""select debut, "Final Game", AGE("Final Game", debut)::text as "Career Span" from z_all_player_dates where playerid = {playerid}""")


wins_losses = pd.read_sql(con=pgconn, sql=f"""SELECT 
    Count(matches.matchid) AS Played
    , Sum(case when upper(matches.result)='W2' then 1 else 0 end) AS WO
    , Sum(case when upper(matches.result)='W1' then 1 else 0 end) AS W1
    , Sum(case when upper(matches.result) in ('D','T') then 1 else 0 end) AS D
    , Sum(case when upper(matches.result)='L1' then 1 else 0 end) AS L1
    , Sum(case when upper(matches.result)='L2' then 1 else 0 end) AS LO
    , (0.00+(Sum(case when upper(matches.result) in ('W1','W2') then 1 else 0 end)))/Count(matches.matchid) AS "Win_pct"
FROM seasons 
INNER JOIN matches 
ON seasons.seasonID = matches.seasonID
INNER JOIN (select distinct matchid 
    from innings
    INNER JOIN Batting
    ON Innings.InningsID = Batting.InningsID
    WHERE batting.playerid = {playerid}
    ) ind_matches
ON Matches.MatchID = ind_matches.MatchID""")


first_game = pd.read_sql(con=pgconn, sql=f"""select year, round, eleven, opponent, date1, batting_position, score, balls_faced from (
    select
    year, round, eleven, opponent, date1, batting_position, score, balls_faced
    , row_number() over (partition by batting.playerid order by matches.date1) as tmp
    FROM seasons
    INNER JOIN Matches 
    on seasons.seasonid = matches.seasonid
    INNER JOIN Innings 
    ON Matches.MatchID = Innings.MatchID
    INNER JOIN Batting
    ON Innings.InningsID = Batting.InningsID
    where batting.playerid = {playerid}
    ) a
where a.tmp = 1""")


data = {'Games Played': career_span['mat'][0],
        'Debut': career_span['debut'][0],
        'Last Season': career_span['Last Season'][0],
        'Career Span': career_length['Career Span'],
        'Wins': wins_losses['wo'] + wins_losses['w1'],
        'Losses': wins_losses['lo'] + wins_losses['l1']}
pd.DataFrame(data).to_excel(writer, sheet_name=sheetname, startrow = 3, index=False)


# players played with the most
teammates = pd.read_sql(con=pgconn, sql=f""" select 
case when playerid1 = {playerid} then "Player 2" else "Player 1" end as "Team-mate",
matches
from team_16_ind_most_matches_together
where playerid1 = {playerid}
or playerid2 = {playerid}
order by matches desc
limit 10""")

pd.DataFrame(teammates).to_excel(writer, sheet_name=sheetname, startrow = 6, index=False)

# who played in first game
first_game_team = pd.read_sql(con=pgconn, sql=f"""
select 
players.player_name as "XI in first match"
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
    where batting.playerid = {playerid}
    ) a
inner join batting
on a.inningsid = batting.inningsid
inner join players
on batting.playerid = players.playerid
where a.tmp = 1
order by batting.batting_position
;""")

pd.DataFrame(first_game_team).to_excel(writer, sheet_name=sheetname, startrow = 6, startcol = 3, index=False)

# who played in last game
last_game_team = pd.read_sql(con=pgconn, sql=f"""
select 
players.player_name as "XI in last match"
from (
    --get last game
    select
    batting.inningsid, matches.date1
    , row_number() over (partition by batting.playerid order by matches.date1 desc) as tmp
    FROM Matches
    INNER JOIN Innings 
    ON Matches.MatchID = Innings.MatchID
    INNER JOIN Batting
    ON Innings.InningsID = Batting.InningsID
    where batting.playerid = {playerid}
    ) a
inner join batting
on a.inningsid = batting.inningsid
inner join players
on batting.playerid = players.playerid
where a.tmp = 1
order by batting.batting_position
;""")

pd.DataFrame(last_game_team).to_excel(writer, sheet_name=sheetname, startrow = 6, startcol = 5, index=False)


#########################################################################################################################
#########################################################################################################################
# Career stats
#########################################################################################################################
#########################################################################################################################
sheetname = 'player_stats'

player['playerid'].to_excel(writer, sheet_name=sheetname, startrow = 1, index=False, header=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:I1',f"{firstname} {surname}",fmt['heading1'])

# -- Bat
# runs
# ave
# best year
# runs made with others
# by posn - inn, runs, ave

# -- Bowl
# wickets
# ave
# best year
# best bowling

# -- Field
# catches
# catches off bowlers





##########################
# Close Workbook
##########################
writer.close()