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
# _season_ = '2022/23' # e.g. _season_ = '2021/22'
# seasonid_1stxi = 73
# seasonid_2ndxi = 74
# seasonid_3rdxi = 75

############################
# Create Excel doc.
############################
# latest_season = _season_.replace('/','-')
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
# Player Batting Summary
#########################################################################################################################
#########################################################################################################################
row_end = 0

player_count = pd.read_sql(con=pgconn, sql=f"""select count(*) from batting_01_summary_ind where mat>0""")['count'][0]
num_pages = ceil(player_count/70)

stats_table_tmp = pd.read_sql(con=pgconn, sql=f"""select name as "Name", debut as "Debut", "Last Season", mat as "Matches", inn as "Innings", "NO" as "Not Outs", ducks as "Ducks"
                          , fours as "Fours", Sixes as "Sixes", Fifties as "Fifties", hundreds as "Hundreds", hs as "Highest Score", total as "Total Runs", "Average", bf as "Balls Faced"
                          , "Average BF" as "Average Balls Faced/Dismissal", "Runs/100 Balls" as "Strike Rate", "Pct Runs in Boundaries"  
    from batting_01_summary_ind where mat>0""")

for ii in range(num_pages):
    sheetname = f'Player Batting Summary ({ii+1})'
    stats_table = stats_table_tmp.loc[70*ii:(70*(ii+1)-1)]
    stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
    worksheet = writer.sheets[sheetname]
    worksheet.merge_range('A1:R1',"ALCC Player Batting Career Summary",fmt['heading1'])
    worksheet.set_row(0, fmt['heading1_height'])
    worksheet.set_column('A:A',None,fmt['arial7bold'])
    worksheet.set_column('B:C',None,fmt['arial7'])
    worksheet.set_column('D:D',None,fmt['arial7bold'])
    worksheet.set_column('E:L',None,fmt['arial7'])
    worksheet.set_column('M:M',None,fmt['arial7bold'])
    worksheet.set_column('N:N',None,fmt['arial7boldnum1dec'])
    worksheet.set_column('O:O',None,fmt['arial7'])
    worksheet.set_column('P:R',None,fmt['arial7num1dec'])
    


writer.close()



