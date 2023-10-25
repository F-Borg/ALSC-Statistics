from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd
from math import ceil

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()


############################
# User input               
############################
_season_ = '2021/22' # e.g. _season_ = '2021/22'

############################
# Create Excel doc.
############################
latest_season = _season_.replace('/','-')
writer = pd.ExcelWriter(f"data/excel/test1.xlsx", engine="xlsxwriter")
wb = writer.book


##########################
# Text Formats
##########################
heading1 = wb.add_format({'size':20,'bold':True,'underline':True})
bold14centre = wb.add_format({'size':14,'bold':True,'align':'centre'})
heading1_height = 35
centre = wb.add_format({'align':'centre'})



#########################################################################################################################
#########################################################################################################################
# Batting Fast Slow
#########################################################################################################################
#########################################################################################################################
sheetname = 'Batting Fast Slow'
row_end = 0

##########################
# Longest Innings
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Name AS "Name",' ' AS " ",balls_faced AS "Balls",score AS "Runs",Opponent AS "Opponent",
    Year AS "Year",Round AS "Round",eleven AS "XI",Association AS "Association",Grade AS "Grade"
    from batting_15_fast_slow_longest limit 15""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:J1',"Longest Innings",heading1)
worksheet.set_row(0, heading1_height)

row_end = stats_table.shape[0] + 2

##########################
# Fastest Innings
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Name AS "Name",strike_rate AS "S/R",Runs AS "Runs",balls_faced AS "Balls",Opponent AS "Opponent",
    Year AS "Year",Round AS "Round",eleven AS "XI",Association AS "Association",Grade AS "Grade"
    from batting_16_fast_slow_fastest limit 15""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,9,"Fastest Innings (min 30 runs)",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4


##########################
# Slowest Innings
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Name AS "Name",strike_rate AS "S/R",Runs AS "Runs",balls_faced AS "Balls",Opponent AS "Opponent",
    Year AS "Year",Round AS "Round",eleven AS "XI",Association AS "Association",Grade AS "Grade"
    from batting_17_fast_slow_slowest limit 15""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,9,"Slowest Innings (min 60 balls)",heading1)
worksheet.set_row(row_end+2, heading1_height)






writer.close()