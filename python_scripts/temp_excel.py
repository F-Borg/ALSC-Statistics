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
# Bowling (3)
#########################################################################################################################
#########################################################################################################################
sheetname = 'Bowling (3)'
row_end = 0

##########################
# Best Bowling Performances
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select player as "Name", overs as "Overs", figures as "Figures", Opponent as "Opponent"
                          , Year AS "Year", round as "Round", eleven AS "XI", Association AS "Association", Grade AS "Grade"
    from bowling_09_p3_best_figs limit 20""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:I1',"Best Bowling Performances",heading1)
worksheet.set_row(0, heading1_height)

row_end = stats_table.shape[0] + 2

##########################
# Hat Tricks
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select player_name as "Name", '' as " ", '' as "  ", Opponent as "Opponent"
                          , Year AS "Year", round as "Round", eleven AS "XI", Association AS "Association", Grade AS "Grade"
    from bowling_10_p3_hat_trick""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,8,"Hat Tricks",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4

##########################
# 10 Wicket Matches
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Name", "Wickets", "Figures", Opponent as "Opponent"
                          , Year AS "Year", round as "Round", eleven AS "XI", Association AS "Association", Grade AS "Grade"
    from bowling_11_p3_10WM""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,8,"10 Wicket Matches",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4

##########################
# Most Economical Bowling (min 10 overs)
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Player as "Name", Overs as "Overs", figures as "Figures", Opponent as "Opponent"
                          , Year AS "Year", round as "Round", eleven AS "XI", Association AS "Association", Grade AS "Grade"
    from bowling_12_p3_match_econ limit 12""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,8,"Most Economical Bowling (min 10 overs)",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4








writer.close()