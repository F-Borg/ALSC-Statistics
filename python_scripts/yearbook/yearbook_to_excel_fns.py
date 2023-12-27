#########################################################################################################################
#########################################################################################################################
# Setup
#########################################################################################################################
#########################################################################################################################
# from sqlalchemy import create_engine
# from sqlalchemy import select
# from sqlalchemy import text
# from math import ceil
import pandas as pd
import re
from math import floor
import python_scripts.text_formats as tf

import importlib
importlib.reload(tf)

# engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
# pgconn = engine.connect()


############################
# User input               
############################
# _season_ = '2020/21' # e.g. _season_ = '2021/22'
# seasonid_1stxi = 70
# seasonid_2ndxi = 71
# seasonid_3rdxi = 72


############################
# Create Excel doc.
############################
# latest_season = _season_.replace('/','-')
# writer = pd.ExcelWriter(f"data/excel/ALSC_yearbook_{latest_season}.xlsx", engine="xlsxwriter")
# wb = writer.book



#########################################################################################################################
#########################################################################################################################
# 1st XI
#########################################################################################################################
#########################################################################################################################

def yb_summary(_season_, seasonid, xi, writer, wb, pgconn):
    # xi = '1st XI'
    # seasonid = 70
    # _season_ = '2020/21'
    fmt = tf.add_text_formats(wb)

    ##########################
    # Season Summary
    ##########################
    sheetname = f'{xi} Season Summary'

    row_end = 0
    worksheet = wb.add_worksheet(sheetname)
    worksheet.merge_range('A1:E1',f"Adelaide Lutheran {xi} Season Summary - {_season_}",fmt['heading1'])
    worksheet.set_row(0, fmt['heading1_height'])

    

    # Load summary table
    stats_table = pd.read_sql(con=pgconn, sql=f"""select * from yb_01_season_summary
    where seasonid = {seasonid}""")
    # Get number of rounds for later use
    num_rounds = len(stats_table['round'].drop_duplicates())

    # Loop through rounds
    for round in stats_table['round'].drop_duplicates():
        # round = '2'
        t1 = stats_table.loc[stats_table['round']==round]
        ground = f"at {t1['ground'].iloc[0]}"
        result = t1['result'].iloc[0]
        c1 = 'Adelaide Lutheran'
        c2 = t1['bat_total'].iloc()[0]
        if result == 'W1': c3 = 'DEFEATED'
        elif result == 'L1': c3 = 'LOST TO'
        elif result == 'D': c3 = 'DREW WITH'
        elif result == 'W2': c3 = 'DEFEATED OUTRIGHT'
        elif result == 'L2': c3 = 'LOST OUTRIGHT TO'
        c4 = t1['opponent'].iloc[0]
        c5 = t1['bowl_total'].iloc[0]
        bat = t1[['bat_name','bat_score']].drop_duplicates().dropna()
        bowl = t1[['bowl_name','figures']].drop_duplicates().dropna()
        row3 = ''
        if len(bat) > 0:
            for i in range(len(bat)):
                row3 = row3+bat.iloc[i]['bat_name']+' '+bat.iloc[i]['bat_score']
                if i < len(bat)-1: row3 = row3+', '
        if len(bat) > 0 and len(bowl) > 0: 
            row3 = row3+'  -  '
        if len(bowl) > 0:
            for j in range(len(bowl)):
                row3 = row3+bowl.iloc[j]['bowl_name']+' '+bowl.iloc[j]['figures']
                if j < len(bowl)-1: row3 = row3+', '
        # Write to worksheet 
        worksheet.write(row_end+2,0,f'Round {round}',fmt['arial9BIU'])
        worksheet.merge_range(row_end+2,1,row_end+2,4,ground,fmt['arial9'])
        worksheet.write(row_end+3,0,c1,fmt['arial9'])
        worksheet.write(row_end+3,1,c2,fmt['arial9'])
        worksheet.write(row_end+3,2,c3,fmt['arial9bold'])
        worksheet.write(row_end+3,3,c4,fmt['arial9'])
        worksheet.write(row_end+3,4,c5,fmt['arial9'])
        worksheet.merge_range(row_end+4,0,row_end+4,4,row3,fmt['arial9'])
        # New end row
        row_end += 4


    ##########################
    # Batting Summary
    ##########################
    sheetname = f'{xi} Batting'

    row_end = 0
    worksheet = wb.add_worksheet(sheetname)
    worksheet.merge_range('A1:E1',f"{xi} Batting Summary - {_season_}",fmt['heading1'])
    worksheet.set_row(0, fmt['heading1_height'])

    stats_table = pd.read_sql(con=pgconn, sql=f"""select * from yb_02_batting_summary
    where seasonid = {seasonid}""").iloc[:,2:18]

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

    i = len(stats_table)
    stats_table.loc[i] = smry

    stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)

    # Formatting
    worksheet.set_column('A:P',None,fmt['arial8'])
    worksheet.set_column('A:B',None,fmt['arial8bold'])
    worksheet.set_column('K:K',None,fmt['arial8bold'])
    worksheet.set_column('L:L',None,fmt['arial8boldnum1dec'])
    worksheet.set_column('N:P',None,fmt['arial8num1dec'])


    ##########################
    # Batting Partnerships
    ##########################
    sheetname = f'{xi} Batting Partnerships'

    row_end = 0
    worksheet = wb.add_worksheet(sheetname)
    worksheet.merge_range('A1:F1',f"{xi} Partnership Records - {_season_}",fmt['heading1'])
    worksheet.set_row(0, fmt['heading1_height'])

    stats_table = pd.read_sql(con=pgconn, sql=f"""select * from yb_03_batting_pships
    where seasonid = {seasonid}""").iloc[:,0:6]

    stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)

    # Formatting
    worksheet.set_column('A:F',None,fmt['arial9'])
    worksheet.set_column('B:B',None,fmt['arial9bold'])


    ##########################
    # Bowling Summary
    ##########################
    sheetname = f'{xi} Bowling'

    row_end = 0
    worksheet = wb.add_worksheet(sheetname)
    worksheet.merge_range('A1:L1',f"{xi} Bowling Summary - {_season_}",fmt['heading1'])
    worksheet.set_row(0, fmt['heading1_height'])

    stats_table = pd.read_sql(con=pgconn, sql=f"""select * from yb_04_bowling_summary
    where seasonid = {seasonid}""").iloc[:,0:12]

    stats_table = stats_table.applymap(lambda x: None if x==-9 else x)

    bbf = stats_table.loc[:,['Best Bowling Figures']]
    bbf['w'] = bbf['Best Bowling Figures'].apply(lambda x: re.sub('/.*','',x))
    bbf['r'] = bbf['Best Bowling Figures'].apply(lambda x: re.sub('.*/','',x))


    smry = ['Team Totals',num_rounds,str(floor(sum(stats_table['Balls'])/6)) + '.' + str(int(sum(stats_table['Balls']) % 6)),
            sum(stats_table['Balls']), sum(stats_table['Maidens']), sum(stats_table['Runs']), sum(stats_table['Wickets']), 
            sum(stats_table['Runs'])/sum(stats_table['Wickets']), # Average
            bbf.sort_values(by='r').sort_values(by='w',ascending=False).iloc[0,0], # best figs
            sum(stats_table['Balls'])/sum(stats_table['Wickets']), # SR
            6*sum(stats_table['Runs'])/sum(stats_table['Balls']), # ER
            None] # ABD

    i = len(stats_table)
    stats_table.loc[i] = smry

    stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)

    # Formatting
    worksheet.set_column('A:L',None,fmt['arial8'])
    worksheet.set_column('A:B',None,fmt['arial8bold'])
    worksheet.set_column('G:G',None,fmt['arial8bold'])
    worksheet.set_column('H:H',None,fmt['arial8boldnum1dec'])
    worksheet.set_column('J:L',None,fmt['arial8num1dec'])


    ##########################
    # Fielding Summary
    ##########################
    sheetname = f'{xi} Fielding'

    row_end = 0
    worksheet = wb.add_worksheet(sheetname)
    worksheet.merge_range('A1:E1',f"{xi} Fielding Summary - {_season_}",fmt['heading1'])
    worksheet.set_row(0, fmt['heading1_height'])

    stats_table = pd.read_sql(con=pgconn, sql=f"""select * from yb_05_fielding_summary
    where seasonid = {seasonid}""").iloc[:,0:5]

    smry = ['Team Totals',num_rounds,sum(stats_table['Catches']), sum(stats_table['Stumpings']), sum(stats_table['Run Outs'])] 

    i = len(stats_table)
    stats_table.loc[i] = smry

    stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)

    # Formatting
    worksheet.set_column('B:E',None,fmt['arial9'])
    worksheet.set_column('A:A',None,fmt['arial9bold'])


# writer.close()

