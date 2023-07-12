from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')

pgconn = engine.connect()


# test = pgconn.execute(text('select * from seasons limit 10')).fetchall()



#########################################################################################################################
# Season, Match, Innings
#########################################################################################################################
season = pd.read_sql(con=pgconn, sql=f"select * from seasons where playhq_season='{match_info['grade']}'")

#########################################################################################################################
# Batting
#########################################################################################################################


