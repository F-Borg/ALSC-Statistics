import pandas as pd
import re
import math
from sqlalchemy import insert
from sqlalchemy import text
from python_scripts.db import get_engine

engine = get_engine()
pgconn = engine.connect()


def check_player_ids(match_info):
    # match_info = {'season': '22-23', 'grade': 'ISC Teamwear LO Division 1', 'round': '2', 'num_days': 1, 'date_day_1': '22 Oct 2022', 'date_day_2': '', 'num_innings': 2, 'innings_list': ['Adelaide Lutheran 1st Innings', 'Kilburn 1st Innings'], 'extras': [{'wd': 2, 'nb': 2, 'lb': 0, 'b': 4, 'p': 0}, {'wd': 7, 'nb': 1, 'lb': 0, 'b': 0, 'p': 0}], 'overs': ['40', '31.2'], 'venue': 'Blair Athol Reserve / Blair Athol Reserve - Main Oval', 'opponent': 'Kilburn', 'winner': 'Kilburn', 'result': 'L1', 'captain': 'Finley Borgas', 'game_dir': 'data/22-23/ISC Teamwear LO Division 1/Rnd_2'}
    match_dir = match_info['game_dir']

    # Player IDs
    players = pd.read_sql(con=pgconn, sql=f"select * from players")

    for i in range(1,match_info['num_innings']+1):
        # i=2
        if match_info['opponent'] not in match_info['innings_list'][i-1]:
            batting = pd.read_table(f'{match_dir}/innings_{i}_batting.md', sep="|", header=0, index_col=1, skipinitialspace=True).dropna(axis=1, how='all').iloc[1:]
            batting = batting.applymap(lambda x: x.strip() if isinstance(x, str) else x)
            batting.columns = batting.columns.str.strip()
            batting['name_fl'] = batting['batter']
            batting2 = pd.merge(batting, players, on="name_fl", how="left")
            break

    missing_ids = batting2[batting2['playerid'].isna()]['name_fl'].to_list()
    return missing_ids


def check_game_exists(seasonid, round, opponent, matches_tbl):
    # checks whether a match with the same season, round and opponent has already been loaded
    existing = pd.read_sql(
        con=pgconn,
        sql=text(f"""
            select matchid from {matches_tbl}
            where seasonid = :seasonid
            and round = :round
            and opponent = :opponent
            """),
        params={'seasonid': int(seasonid), 'round': str(round), 'opponent': opponent},
    )
    return len(existing) > 0


def add_new_player(firstname,lastname):
    newplayerid = pd.read_sql(con=pgconn, sql=f"select max(playerid)+1 as playerid from players")['playerid'][0]
    pgconn.execute(
        text("insert into players values (:playerid, :name_lf, :firstname, :lastname, NULL, :name_fl)"),
        {
            'playerid': int(newplayerid),
            'name_lf': f'{lastname}, {firstname}',
            'firstname': firstname,
            'lastname': lastname,
            'name_fl': f'{firstname} {lastname}',
        },
    )
    pgconn.commit()



# def delete_game_juniors():
#     #     # delete from batting, bowling, wickets, fielding, innings, matches.
#     pd.read_sql(con=pgconn, sql=f"select seasonid from matches_j")
#     #     pd.read_sql(con=pgconn, sql=f"select * from matches_j where seasonid=8")
#     #     pd.read_sql(con=pgconn, sql=f"select * from innings_j where matchid in (select matchid from matches_j where seasonid=8)")
#     #     pgconn.execute(text(f"delete from batting_j  where inningsid in (select inningsid from innings_j where matchid in (select matchid from matches_j where seasonid=8))"))
#     #     pgconn.execute(text(f"delete from bowling_j  where inningsid in (select inningsid from innings_j where matchid in (select matchid from matches_j where seasonid=8))"))
#     #     pgconn.execute(text(f"delete from fielding_j where inningsid in (select inningsid from innings_j where matchid in (select matchid from matches_j where seasonid=8))"))
#     #     pgconn.execute(text(f"delete from innings_j where matchid in (select matchid from matches_j where seasonid=8)"))
#     #     pgconn.execute(text(f"delete from matches_j where seasonid=8"))
#     pd.read_sql(con=pgconn, sql=f"select * from players where playerid < 0")    
    


