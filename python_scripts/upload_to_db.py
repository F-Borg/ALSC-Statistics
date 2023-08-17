from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')

pgconn = engine.connect()


# test = pgconn.execute(text('select * from seasons limit 10')).fetchall()

# test:
match_info = {'season': '22-23', 'grade': 'ISC Teamwear LO Division 1', 'round': '2', 'num_days': 1, 'date_day_1': '22 Oct 2022', 'date_day_2': '', 'num_innings': 2, 'innings_list': ['Adelaide Lutheran 1st Innings', 'Kilburn 1st Innings'], 'venue': 'Blair Athol Reserve / Blair Athol Reserve - Main Oval', 'opponent': 'Kilburn', 'winner': 'Kilburn', 'captain': 'Finley Borgas', 'game_dir': 'data/22-23/ISC Teamwear LO Division 1/Rnd_2'}

#########################################################################################################################
# Player IDs
#########################################################################################################################
players = pd.read_sql(con=pgconn, sql=f"select * from players")
players['name_FL'] = players['firstname'] + ' ' + players['surname']

match_info['captain']




#########################################################################################################################
# Season, Match, Innings - numerical order does not matter
#########################################################################################################################
season = pd.read_sql(con=pgconn, sql=f"select * from seasons where playhq_season='{match_info['grade']}'")

matchid   = pd.read_sql(con=pgconn, sql=f"select max(matchid)   as n from matches")['n'][0]+1
inningsid = pd.read_sql(con=pgconn, sql=f"select max(inningsid) as n from innings")['n'][0]+1

this_match = pd.DataFrame(columns=['matchid','opponent','ground','round','seasonid','result','date1','date2','nodays','captain','wicketkeeper','fv_1st','fv_2nd'])

# !!! result
this_match.loc[0] = [matchid, match_info['opponent'], match_info['venue'], match_info['round'], season['seasonid'], match_info['result'], 
                     match_info['date_day_1'], match_info['date_day_2'], match_info['num_days'], match_info['captain'], match_info['wicketkeeper'],'','']


#########################################################################################################################
# Batting
#########################################################################################################################
batting['inningsid'] = inningsid



