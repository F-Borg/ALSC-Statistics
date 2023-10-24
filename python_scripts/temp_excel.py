from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd

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
# Team Ind
#########################################################################################################################
#########################################################################################################################
sheetname = 'Team Ind'
row_end = 0

##########################
# Most Matches
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Name as "Name", mat as "Matches", debut as "Debut"
                          , CASE WHEN "Last Season" = '{_season_}' THEN '-' ELSE "Last Season" END AS "Last Season"
    from team_13_ind_most_matches limit 20""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 3, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:G1',"Most Matches",heading1)
worksheet.set_row(0, heading1_height)

# merged cells:
worksheet.merge_range('C4:D4',"Debut")
worksheet.merge_range('E4:G4',"Last Season")
for ii in range(stats_table.shape[0]):
    worksheet.merge_range(ii+4,2,ii+4,3,stats_table['Debut'][ii],centre)
    worksheet.merge_range(ii+4,4,ii+4,6,stats_table['Last Season'][ii],centre)

row_end += stats_table.shape[0] + 2

##########################
# Youngest Known Players
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Name", "Age on Debut", "First Season", "Age on Final Game"
    from team_15_ind_youngest limit 20""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 3, startcol = 8, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('I1:L1',"Youngest Known Players",heading1)


##########################
# Most Matches as Captain
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Name", "Matches", "WO", "W1", "D", "T", "L1", "LO", "Win Pct", "Premierships"
    from team_14_ind_most_matches_capt limit 10""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,10,"Most Matches as Captain",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4








writer.close()