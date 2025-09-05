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
import matplotlib.pyplot as plt

import importlib
importlib.reload(tf)

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()

# html output
outfile = ""

############################
# User input               
############################
playerid = 269


#########################################################################################################################
#########################################################################################################################
# Player Summary
#########################################################################################################################
#########################################################################################################################

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

outfile += first_game.to_html(classes='table table-stripped')

bat_score_list = pd.read_sql(con=pgconn, sql=f"""select 
matches.date1
--, batting.* 
, batting.score::int
, seasons.year
, row_number() over (order by matches.date1, innings.inningsno) as inn_order
from batting
join innings
on batting.inningsid = innings.inningsid
join matches
ON Matches.MatchID = Innings.MatchID
join seasons
on seasons.seasonid = matches.seasonid
where batting.playerid = {playerid}
and how_out not in ('DNB','Absent Out')
order by inn_order
;
""")

# Manhattan
plt.bar(bat_score_list['inn_order'],bat_score_list['score'])
plt.axis((0,max(bat_score_list['inn_order']+1),0,max(bat_score_list['score'])+10))
plt.show()







# write html to file
text_file = open(f"data/player_summary/{firstname}{surname}-{playerid}.html", "w")
text_file.write(outfile)
text_file.close()