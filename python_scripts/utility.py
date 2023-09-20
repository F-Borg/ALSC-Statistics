import pandas as pd
import re
import math
from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()


def check_player_ids(match_info):
    # match_info = {'season': '22-23', 'grade': 'ISC Teamwear LO Division 1', 'round': '2', 'num_days': 1, 'date_day_1': '22 Oct 2022', 'date_day_2': '', 'num_innings': 2, 'innings_list': ['Adelaide Lutheran 1st Innings', 'Kilburn 1st Innings'], 'extras': [{'wd': 2, 'nb': 2, 'lb': 0, 'b': 4, 'p': 0}, {'wd': 7, 'nb': 1, 'lb': 0, 'b': 0, 'p': 0}], 'overs': ['40', '31.2'], 'venue': 'Blair Athol Reserve / Blair Athol Reserve - Main Oval', 'opponent': 'Kilburn', 'winner': 'Kilburn', 'result': 'L1', 'captain': 'Finley Borgas', 'game_dir': 'data/22-23/ISC Teamwear LO Division 1/Rnd_2'}
    match_dir = match_info['game_dir']

    # Player IDs
    players = pd.read_sql(con=pgconn, sql=f"select * from players")

    for i in range(1,match_info['num_innings']+1):
        # i=1
        if 'Adelaide Lutheran' in match_info['innings_list'][i-1]:
            batting = pd.read_table(f'{match_dir}/innings_{i}_batting.md', sep="|", header=0, index_col=1, skipinitialspace=True).dropna(axis=1, how='all').iloc[1:]
            batting = batting.applymap(lambda x: x.strip() if isinstance(x, str) else x)
            batting.columns = batting.columns.str.strip()
            batting['name_fl'] = batting['batter']
            batting2 = pd.merge(batting, players, on="name_fl", how="left")
            break

    missing_ids = batting2[batting2['playerid'].isna()]['name_fl'].to_list()
    return missing_ids

