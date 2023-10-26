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
# Player Bowling Summary
#########################################################################################################################
#########################################################################################################################
sheetname = 'Player Bowling Summary'
row_end = 0


player_count = pd.read_sql(con=pgconn, sql=f"""select count(*) from bowling_01_summary_ind where mat>0""")['count'][0]
num_pages = ceil(player_count/70)

stats_table_tmp = pd.read_sql(con=pgconn, sql=f"""select Name AS "Name",mat AS "Matches",o AS "Overs",Balls AS "Balls",mdns AS "Maidens",
                              "Total Runs" AS "Runs","Total Wickets" AS "Wickets",Average AS "Average","Strike Rate",rpo as "Economy Rate",
                              ABD AS "ABD",_4s AS "4s",_6s AS "6s",figures AS "Best Bowling Figures","5WI",
                              "Expensive Over" AS "Most Expensive Over",Catches AS "Catches",Stumpings AS "Stumpings"
    from bowling_01_summary_ind where mat>0""")

for ii in range(num_pages):
    sheetname = f'Player Bowling Summary ({ii+1})'
    stats_table = stats_table_tmp.loc[70*ii:(70*(ii+1)-1)]
    stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
    worksheet = writer.sheets[sheetname]
    worksheet.merge_range('A1:R1',"ALCC Player Bowling and Fielding Summary",heading1)
    worksheet.set_row(0, heading1_height)






##########################
# Highest Partnerships
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Runs AS "Runs",Wicket AS "Wicket","Player 1","Player 2",Opponent AS "Opponent"
                          ,Year AS "Year",Round AS "Round",eleven AS "XI",Association AS "Association",Grade AS "Grade"
    from batting_23_partnerships_highest limit 20""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:J1',"Highest Partnerships",heading1)
worksheet.set_row(0, heading1_height)

row_end = stats_table.shape[0] + 2

##########################
# 1st XI Wicket Partnership Records
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Runs AS "Runs",Wicket AS "Wicket","Player 1","Player 2",Opponent AS "Opponent"
                          ,Year AS "Year",Round AS "Round",Association AS "Association",Grade AS "Grade"
    from batting_24_partnerships_wicket_1stXI""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,9,"1st XI Wicket Partnership Records",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4

##########################
# 2nd XI Wicket Partnership Records
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Runs AS "Runs",Wicket AS "Wicket","Player 1","Player 2",Opponent AS "Opponent"
                          ,Year AS "Year",Round AS "Round",Association AS "Association",Grade AS "Grade"
    from batting_25_partnerships_wicket_2ndXI""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,9,"2nd XI Wicket Partnership Records",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4

##########################
# 3rd XI Wicket Partnership Records
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Runs AS "Runs",Wicket AS "Wicket","Player 1","Player 2",Opponent AS "Opponent"
                          ,Year AS "Year",Round AS "Round",Association AS "Association",Grade AS "Grade"
    from batting_26_partnerships_wicket_3rdXI""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,9,"3rd XI Wicket Partnership Records",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4







writer.close()