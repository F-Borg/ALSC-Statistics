from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd
import re
from math import ceil, floor
import python_scripts.text_formats as tf

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()

import importlib
importlib.reload(tf)


############################
# User input               
############################
_season_ = '2021/22' # e.g. _season_ = '2021/22'
seasonid_1stxi = 73
seasonid_2ndxi = 74
seasonid_3rdxi = 75

############################
# Create Excel doc.
############################
latest_season = _season_.replace('/','-')
writer = pd.ExcelWriter(f"data/excel/test1.xlsx", engine="xlsxwriter")
wb = writer.book


##########################
# Text Formats
##########################
# heading1 = wb.add_format({'size':20,'bold':True,'underline':True})
# bold14centre = wb.add_format({'size':14,'bold':True,'align':'centre'})
# heading1_height = 35
# centre = wb.add_format({'align':'centre'})
fmt = tf.add_text_formats(wb)


#########################################################################################################################
#########################################################################################################################
# 1st XI
#########################################################################################################################
#########################################################################################################################
xi = '1st XI'
seasonid = 76
num_rounds = 13


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

# formatting
worksheet.set_column('A:P',None,fmt['arial8'])
worksheet.set_column('A:B',None,fmt['arial8bold'])
worksheet.set_column('K:K',None,fmt['arial8bold'])
worksheet.set_column('L:L',None,fmt['arial8boldnum1dec'])
worksheet.set_column('N:P',None,fmt['arial8num1dec'])

stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)

writer.close()


