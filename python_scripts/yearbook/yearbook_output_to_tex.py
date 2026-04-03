from sqlalchemy import create_engine
import pandas as pd

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()


############################
# User input               
############################
_season_ = '2024/25' # e.g. _season_ = '2021/22'
seasonid_1stxi = 81
seasonid_2ndxi = 82
# seasonid_3rdxi = 78

seasonid=81

xi_1 = '1st XI'
xi_2 = '2nd XI'
# xi_3 = '3rd XI'


#########################################################################################################################
#########################################################################################################################
# Milestones
#########################################################################################################################
#########################################################################################################################

stats_table = pd.read_sql(con=pgconn, sql=f"""select * from yb_01_season_summary
where seasonid = {seasonid}""")
# Get number of rounds for later use
num_rounds = len(stats_table['round'].drop_duplicates())


tex_doc="tex_scripts/tables/yearbook/batting_1st_xi_summary.tex"

stats_table = pd.read_sql(con=pgconn, sql=f"""select * from yb_02_batting_summary
where seasonid = {seasonid}""").iloc[:,4:20]

stats_table = stats_table.applymap(lambda x: None if x==-9 else x)


smry = ['Team Totals',num_rounds,sum(stats_table['Innings']),sum(stats_table['Not Outs']),
        sum(stats_table['Fours']),sum(stats_table['Sixes']),sum(stats_table['Ducks']),
        sum(stats_table['Fifties']),sum(stats_table['Hundreds']),max(stats_table['Highest Score'].apply(lambda x: x.replace('*',''))),
        sum(stats_table['Total Runs']),
        sum(stats_table['Total Runs'])/(sum(stats_table['Innings'])-sum(stats_table['Not Outs'])), # Average
        sum(stats_table['Balls Faced']), # BF
        sum(stats_table['Balls Faced'])/(sum(stats_table['Innings'])-sum(stats_table['Not Outs'])), # BF / dismissal
        100*sum(stats_table['Total Runs'])/sum(stats_table['Balls Faced']), # Strike rate
        100*(4*sum(stats_table['Fours'])+6*sum(stats_table['Sixes']))/sum(stats_table['Balls Faced'])] # pct runs in boundaries


with open(tex_doc, 'w') as tf:
    tf.write(stats_table.to_latex())

print(stats_table.to_latex())
