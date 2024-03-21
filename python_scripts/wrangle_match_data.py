import pandas as pd
import re
import math
from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()


def get_how_out(how_out_str):
    if re.search('c\&b:',how_out_str):
        return 'c & b'
    elif re.search('^c:',how_out_str):
        return 'caught'
    elif re.search('^b:',how_out_str):
        return 'bowled'
    elif re.search('did not bat',how_out_str) or how_out_str=='-':
        return 'DNB'
    elif re.search('not out',how_out_str):
        return 'Not Out'
    elif re.search('^lbw:',how_out_str):
        return 'LBW'
    elif re.search('run out',how_out_str):
        return 'Run Out'
    elif re.search('(stumped|st:)',how_out_str):
        return 'Stumped'
    elif re.search('absent out',how_out_str):
        return 'Absent Out'
    elif re.search('retired hurt',how_out_str):
        return 'Retired Hurt'
    elif re.search('retired',how_out_str):
        return 'Retired'
    elif re.search('hit wicket',how_out_str):
        return 'Hit Wicket'
    else:
        return 'ERROR'

# def name_FL_to_LFi(name):
#     return re.sub('(\S)(\S+)\s?(\S)?(\S+)? (\S+)$','\\5, \\1\\3',name)

def how_out_bowler(how_out_str):
    if get_how_out(how_out_str) in ['caught','bowled','LBW','Stumped','c & b','Hit Wicket']:
        # return re.sub('.*?(?:lbw|b): (\S)(\S+)\s?(\S)?(\S+)? (\S+)$','\\5, \\1\\3',how_out_str)
        return re.sub('.*?(?:lbw|b): (.*)','\\1',how_out_str) # return name as-is
    else:
        return ''

def how_out_assist(how_out_str):
    if get_how_out(how_out_str) in ['caught','Stumped','c & b','Run Out']:
        if '?' in how_out_str:
            return None
        else:
            return re.sub('(?:c|stumped|st|run out|c\&b): (\S+)\s(\S+).*','\\1 \\2',how_out_str)
    else:
        return None

def split_fow(s):
    # s='1-0 Daniel Grosser'
    wicket = s.split('-',1)[0]
    fow = s.split('-',1)[1].split(' ',1)[0]
    name = s.split(' ',1)[1]
    return [wicket,fow,name]

# !!! test
# match_info = {'season': '22-23', 'grade': 'ISC Teamwear LO Division 1', 'round': '2', 'num_days': 1, 'date_day_1': '22 Oct 2022', 'date_day_2': '', 'num_innings': 2, 'innings_list': ['Adelaide Lutheran 1st Innings', 'Kilburn 1st Innings'], 'fow_list': [['1-0 Daniel Grosser, 2-25 Jeremy Borgas, 3-64 Marko Fedojuk, 4-67 Manmeet Singh, 5-102 Joshua Waldhuter, 6-109 Finley Borgas, 7-126 Ajay Agnihotri, 8-132 Matthew Nitschke, 9-142 Azadar Malik'], ['1-4 Hussain Ahmadi, 2-36 Irfan Raza, 3-69 Ali Khan, 4-74 Asif Ali Shafa']], 'extras': [{'wd': 2, 'nb': 2, 'lb': 0, 'b': 4, 'p': 0}, {'wd': 7, 'nb': 1, 'lb': 0, 'b': 0, 'p': 0}], 'overs': ['40', '31.2'], 'venue': 'Blair Athol Reserve / Blair Athol Reserve - Main Oval', 'opponent': 'Kilburn', 'winner': 'Kilburn', 'result': 'L1', 'captain': 'Finley Borgas', 'game_dir': 'data/22-23/ISC Teamwear LO Division 1/Rnd_2', 'wicketkeeper': 'Marko Fedojuk'}

def wrangle_match_data(match_info, write_to_postgres = False):
    match_dir = match_info['game_dir']

    # Player IDs
    players = pd.read_sql(con=pgconn, sql=f"select * from players")
    players1 = players.loc[:,['playerid','name_fl']]
    players2 = players1.rename(columns={'playerid':'not_out_batter','name_fl':'not_out_batter_name'})
    players3 = players1.rename(columns={'playerid':'assist','name_fl':'assist_name'})

    #########################################################################################################################
    # Season, Match - numerical order does not matter
    #########################################################################################################################
    season = pd.read_sql(con=pgconn, sql=f"select * from seasons where playhq_season='{match_info['grade']}' and year='20'||replace('{match_info['season']}','-','/')")

    matchid   = pd.read_sql(con=pgconn, sql=f"select max(matchid)   as n from matches")['n'][0]+1
    inningsid = pd.read_sql(con=pgconn, sql=f"select max(inningsid) as n from innings")['n'][0]+1

    this_match = pd.DataFrame(columns=['matchid','opponent','ground','round','seasonid','result','date1','date2','nodays','captain','wicketkeeper','fv_1st','fv_2nd'])

    captain_id = players.loc[players['name_fl'] == match_info['captain']]['playerid'].values[0].tolist()
    wicketkeeper_id = players.loc[players['name_fl'] == match_info['wicketkeeper']]['playerid'].values[0].tolist()

    this_match.loc[0] = [matchid, match_info['opponent'], match_info['venue'], match_info['round'], season['seasonid'][0], match_info['result'], 
                        match_info['date_day_1'], match_info['date_day_2'], match_info['num_days'], captain_id, wicketkeeper_id,0,0]
    if not match_info['date_day_2']:
        this_match['date2'] = None

    if(write_to_postgres):
        this_match.to_sql('matches', engine, if_exists='append', index=False)
    else:
        print(this_match)

    for i in range(1,match_info['num_innings']+1):
        # i=1
        if 'Adelaide Lutheran' in match_info['innings_list'][i-1]:
            #########################################################################################################################
            # Batting, Innings
            #########################################################################################################################
            batting = pd.read_table(f'{match_dir}/innings_{i}_batting.md', sep="|", header=0, index_col=1, skipinitialspace=True).dropna(axis=1, how='all').iloc[1:]
            batting = batting.applymap(lambda x: x.strip() if isinstance(x, str) else x)
            batting.columns = batting.columns.str.strip()

            batting['inningsid'] = inningsid + (i-1)
            batting['batting_position'] = batting.reset_index().index + 1
            batting['bowler_name'] = batting['how_out'].apply(how_out_bowler)
            batting['how_out'] = batting['how_out'].apply(get_how_out)
            batting['wicket'] = None
            batting['fow'] = None
            batting['not_out_batter_name'] = None
            batting['name_fl'] = batting['batter']

            # FOW
            fow = [split_fow(s) for s in match_info['fow_list'][i-1][0].split(', ')]
            batter_pos_1 = 1
            batter_pos_2 = 2
            for jj in range(0,len(fow)):
                # jj=3
                # if batter 1 is out, then batter 2 is the not out batter, and update batter 1 to the next batter
                if batting.loc[batting['batting_position']==batter_pos_1, 'batter'][0] == fow[jj][2]:
                    not_out_batter = batting.loc[batting['batting_position']==batter_pos_2, 'batter'][0]
                    batter_pos_1 = max(batter_pos_1,batter_pos_2)+1
                else:
                    not_out_batter = batting.loc[batting['batting_position']==batter_pos_1, 'batter'][0]
                    batter_pos_2 = max(batter_pos_1,batter_pos_2)+1
                batting.loc[batting['batter']==fow[jj][2], 'wicket']         = fow[jj][0]
                batting.loc[batting['batter']==fow[jj][2], 'fow']            = fow[jj][1]
                batting.loc[batting['batter']==fow[jj][2], 'not_out_batter_name'] = not_out_batter

            # not out batters - calc final score
            if max(batter_pos_1,batter_pos_2) <= 11 and batting.loc[batting['batting_position']==max(batter_pos_1,batter_pos_2), 'how_out'][0] != 'DNB':
                batting.loc[batting['batting_position']==batter_pos_1, 'wicket']         = len(fow)+1
                batting.loc[batting['batting_position']==batter_pos_1, 'fow']            = sum(batting['score'].astype('int')) + sum(match_info['extras'][i-1].values())
                # !!! issue here with last batter - batter_pos_2 = 12
                batting.loc[batting['batting_position']==batter_pos_1, 'not_out_batter_name'] = batting.loc[batting['batting_position']==batter_pos_2, 'batter'][0] 


            batting2 = batting.merge(players1, on="name_fl", how="left").merge(players2, on="not_out_batter_name", how="left")

            batting3 = batting2[['inningsid','playerid','batting_position','how_out','bowler_name','score','_4s','_6s','balls_faced','fow','wicket','not_out_batter']]
            if(write_to_postgres):
                batting3.to_sql('batting', engine, if_exists='append', index=False)
            else:
                print(batting3)

            # Innings - batting
            ex = match_info['extras'][i-1]
            extras = ex['wd']+ex['nb']+ex['lb']+ex['b']+ex['p']

            overs = match_info['overs'][i-1].split('.')[0]
            if len(match_info['overs'][i-1].split('.')) == 1:
                extra_balls = 0
            else:
                extra_balls = match_info['overs'][i-1].split('.')[1]

            this_innings = pd.DataFrame(columns=['inningsid','extras','matchid','inningsno','innings_type','bat_overs','extra_balls'])
            this_innings.loc[0] = [inningsid + (i-1), extras, matchid, i, 'bat', overs, extra_balls]

            if(write_to_postgres):
                this_innings.to_sql('innings', engine, if_exists='append', index=False)
            else:
                print(this_innings)  

        # i=2
        else: #bowling and wickets
            #########################################################################################################################
            # Bowling, Innings
            #########################################################################################################################
            bowling = pd.read_table(f'{match_dir}/innings_{i}_bowling.md', sep="|", header=0, index_col=1, skipinitialspace=True).dropna(axis=1, how='all').iloc[1:]
            bowling = bowling.applymap(lambda x: x.strip() if isinstance(x, str) else x)
            bowling.columns = bowling.columns.str.strip()
            bowling = bowling.applymap(lambda x: x.replace('-','0') if isinstance(x, str) else x).fillna(0)

            bowling['inningsid'] = inningsid + (i-1)
            bowling['name_fl'] = bowling['bowler']
            bowling['extra_balls'] = bowling['overs'].apply(lambda x: round(10* (float(x) - math.floor(float(x)))))
            bowling['overs'] = bowling['overs'].apply(lambda x: math.floor(float(x)))
            bowling['runs'] = bowling['runs'].astype(int)
            bowling['wides'] = bowling['wides'].astype(int)
            bowling['no_balls'] = bowling['no_balls'].astype(int)
            bowling['runs_off_bat'] = bowling['runs'] - bowling['wides'] - bowling['no_balls']


            bowling2 = bowling.merge(players1, on="name_fl", how="left")
            bowling3 = bowling2[['inningsid','playerid','overs','extra_balls','maidens','wides','no_balls','runs_off_bat','_4s_against','_6s_against','highover','_2nd_high_over']]
            if(write_to_postgres):
                bowling3.to_sql('bowling', engine, if_exists='append', index=False)
            else:
                print(bowling3)
            

            # Innings - bowling
            # exclude overs bowled
            ex = match_info['extras'][i-1]
            extras = ex['lb']+ex['b']+ex['p'] # exclude wides and no balls for bowling innings

            this_innings = pd.DataFrame(columns=['inningsid','extras','matchid','inningsno','innings_type','bat_overs','extra_balls'])
            this_innings.loc[0] = [inningsid + (i-1), extras, matchid, i, 'bowl', None, None]
            if(write_to_postgres):
                this_innings.to_sql('innings', engine, if_exists='append', index=False)
            else:
                print(this_innings)
            

            #########################################################################################################################
            # Wickets
            #########################################################################################################################
            wickets = pd.read_table(f'{match_dir}/innings_{i}_batting.md', sep="|", header=0, index_col=1, skipinitialspace=True).dropna(axis=1, how='all').iloc[1:]
            wickets = wickets.applymap(lambda x: x.strip() if isinstance(x, str) else x)
            wickets.columns = wickets.columns.str.strip()

            wickets['inningsid'] = inningsid + (i-1)
            wickets['batting_position'] = wickets.reset_index().index + 1
            wickets['batter_name'] = wickets['batter']
            wickets['name_fl'] = wickets['how_out'].apply(how_out_bowler)
            wickets['assist_name'] = wickets['how_out'].apply(how_out_assist)
            wickets['how_out'] = wickets['how_out'].apply(get_how_out)
            wickets['hat_trick'] = 0

            wickets2 = wickets.merge(players1, on="name_fl", how="left").merge(players3, on="assist_name", how="left")

            wickets3 = wickets2[['inningsid','batting_position','batter_name','how_out','assist','playerid','hat_trick']]
            if(write_to_postgres):
                wickets3.to_sql('wickets', engine, if_exists='append', index=False)
            else:
                print(wickets3)
            

