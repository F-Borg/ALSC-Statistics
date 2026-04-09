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
# fmt['heading1_height'] = 35
# centre = wb.add_format({'align':'centre'})
fmt = tf.add_text_formats(wb)

# pgconn.commit()

#########################################################################################################################
#########################################################################################################################
# 
#########################################################################################################################
#########################################################################################################################
sheetname = 'Fielding'
row_end = 0

##########################
# Most Career Fielding Dismissals
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Name", "Dismissals","Catches","Stumpings","Run Outs","Matches"
    from fielding_01_p1_career_dismissals limit 15""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:J1',"Most Career Fielding Dismissals",fmt['heading1'])
worksheet.set_row(0,fmt['heading1_height'])

row_end = stats_table.shape[0] + 2
worksheet.merge_range(row_end+2,0,row_end+2,9,"Note: fielding information is not complete")
row_end += 2

##########################
# Most Dismissals In a Season
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Name", "Dismissals","Catches","Stumpings","Run Outs","Season"
    from fielding_02_p1_season_dismissals where "Dismissals" >= 17""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,9,"Most Dismissals In a Season",fmt['heading1'])
worksheet.set_row(row_end+2,fmt['heading1_height'])

row_end += stats_table.shape[0] + 4

##########################
# Most Dismissals In An Innings
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Name", "Dismissals","Catches","Stumpings","Run Outs" 
                          , Year AS "Year", Opponent as "Opponent", round as "Round", eleven AS "XI", Association AS "Association", Grade AS "Grade"
    from fielding_03_p1_innings_dismissals where "Dismissals" >= 5 """)
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,9,"Most Dismissals In An Innings",fmt['heading1'])
worksheet.set_row(row_end+2,fmt['heading1_height'])

row_end += stats_table.shape[0] + 4

##########################
# Most Career Bowler/Fielder Dismissal Combinations
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Dismissals","Catches" as "c", "Stumpings" as "st", "Fielder", '' as " ", "Bowler"
    from fielding_04_p1_ct_b_combos where "Dismissals" >= 10 """)
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,3,"Most Career Bowler/Fielder Dismissal Combinations",fmt['heading1'])
worksheet.set_row(row_end+2,fmt['heading1_height'])


# merged cells:
worksheet.merge_range(row_end+4,1,row_end+4,2,"Fielder",fmt['centre'])
worksheet.merge_range(row_end+4,3,row_end+4,4,"Bowler",fmt['centre'])
for ii in range(stats_table.shape[0]):
    worksheet.merge_range(row_end+ii+5,1,row_end+ii+5,2,stats_table['Fielder'][ii],fmt['centre'])
    worksheet.merge_range(row_end+ii+5,3,row_end+ii+5,4,stats_table['Bowler'][ii],fmt['centre'])


worksheet.set_column('A:J',None,fmt['arial9'])


pgconn.commit()
writer.close()

