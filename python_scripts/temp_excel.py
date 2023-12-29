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
# Bowl
#########################################################################################################################
#########################################################################################################################
_season_ = '2022/23'
sheetname = 'Ind Bowling'


row_end = 0
worksheet = wb.add_worksheet(sheetname)
worksheet.merge_range('A1:G1',f"Individual Bowling - {_season_}",fmt['heading1'])
worksheet.set_row(0, fmt['heading1_height'])

stats_table = pd.read_sql(con=pgconn, sql=f"""
SELECT
    "Name",
    "XI",
    "Rd",
    "Opponent",
    "O",
    "M",
    "R",
    "W"
FROM zz_temp_yb_bowling
""")


players = stats_table['Name'].drop_duplicates()
headings = pd.DataFrame(stats_table.iloc[:,1:8].columns, columns=['aaa']).T

for player in players:
    worksheet.merge_range(row_end+2,0,row_end+2,6,player,fmt['arial10boldcentre'])
    t1 = stats_table.loc[stats_table['Name']==player].iloc[:,1:8]
    headings.to_excel(writer, sheet_name=sheetname, startrow = row_end+3, index=False, header=False)
    t1.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False, header=False)
    worksheet.set_row(row_end+3,None,fmt['arial8bold'])
    row_end += 3 + len(t1)

worksheet.set_column('A:G',None,fmt['arial8'])

writer.close()



