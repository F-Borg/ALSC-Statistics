from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')

pgconn = engine.connect()


# test = pgconn.execute(text('select * from seasons limit 10')).fetchall()



#########################################################################################################################
# Season, Match, Innings - numerical order does not matter
#########################################################################################################################
season = pd.read_sql(con=pgconn, sql=f"select * from seasons where playhq_season='{match_info['grade']}'")

matchid   = pd.read_sql(con=pgconn, sql=f"select max(matchid)   as n from matches")['n'][0]+1
inningsid = pd.read_sql(con=pgconn, sql=f"select max(inningsid) as n from innings")['n'][0]+1

this_match = pd.DataFrame(columns=['matchid','opponent','ground','round','seasonid','result','date1','date2','nodays','captain','wicketkeeper','fv_1st','fv_2nd'])

# !!! result
this_match.loc[0] = [matchid, match_info['opponent'], match_info['venue'], match_info['round'], season['seasonid'], match_info[''], match_info[''], match_info[''], match_info[''], match_info['']]


#########################################################################################################################
# Batting
#########################################################################################################################
batting['inningsid'] = inningsid



