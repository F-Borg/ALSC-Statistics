#### Notes:
"""
missing:
    check for equal last and extend tables as appropriate - see opposition lowest team scores as exammple
    multiple formats in same cell - see write_rich_string
    capitalise column names
"""

#########################################################################################################################
#########################################################################################################################
# Setup
#########################################################################################################################
#########################################################################################################################
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
writer = pd.ExcelWriter(f"data/excel/ALSC_Statistical_History_{latest_season}.xlsx", engine="xlsxwriter")
wb = writer.book


##########################
# Text Formats
##########################
heading1 = wb.add_format({'size':20,'bold':True,'underline':True})
bold14centre = wb.add_format({'size':14,'bold':True,'align':'centre'})
heading1_height = 35


#########################################################################################################################
#########################################################################################################################
# Season Summary
#########################################################################################################################
#########################################################################################################################
sheetname = 'Season Summary'

##########################
# 1st XI
##########################
team_01_season_summary_1stxi = pd.read_sql(con=pgconn, sql=f"""
    select 
        year,  played,  wo,   w1,  d,   l1,  lo, "Position", association, grade, captain, \"Vice Captain\"                                       
    from team_01_season_summary_all 
    WHERE eleven = '1st' and (grade != 'T20' or grade is null) order by year"""
    )

# add overall row
appendrow = pd.DataFrame([['Overall',
                           team_01_season_summary_1stxi['played'].sum(),
                           team_01_season_summary_1stxi['wo'].sum(),
                           team_01_season_summary_1stxi['w1'].sum(),
                           team_01_season_summary_1stxi['d'].sum(),
                           team_01_season_summary_1stxi['l1'].sum(),
                           team_01_season_summary_1stxi['lo'].sum(),
                           '','','','','']]
                           ,columns = team_01_season_summary_1stxi.columns)
team_01_season_summary_1stxi = pd.concat([team_01_season_summary_1stxi,appendrow])
team_01_season_summary_1stxi.to_excel(writer, sheet_name=sheetname, startrow = 4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:L1',"Adelaide Lutheran Cricket Club Season Summary",heading1)
worksheet.set_row(0,35) # set row height
worksheet.write(2,0,"1st XI",bold14centre)
worksheet.set_row(0,23)

row_end_t01 = team_01_season_summary_1stxi.shape[0] + 4

##########################
# 2nd XI
##########################
worksheet.write(row_end_t01+2,0,"2nd XI",bold14centre)
team_02_season_summary_2ndxi = pd.read_sql(con=pgconn, sql=f"""
    select 
        year,  played,  wo,   w1,  d,   l1,  lo, "Position", association, grade, captain, \"Vice Captain\"                                       
    from team_01_season_summary_all 
    WHERE eleven = '2nd' and (grade != 'T20' or grade is null) order by year"""
    )
appendrow = pd.DataFrame([['Overall',
                           team_02_season_summary_2ndxi['played'].sum(),
                           team_02_season_summary_2ndxi['wo'].sum(),
                           team_02_season_summary_2ndxi['w1'].sum(),
                           team_02_season_summary_2ndxi['d'].sum(),
                           team_02_season_summary_2ndxi['l1'].sum(),
                           team_02_season_summary_2ndxi['lo'].sum(),
                           '','','','','']]
                           ,columns = team_02_season_summary_2ndxi.columns)
team_02_season_summary_2ndxi = pd.concat([team_02_season_summary_2ndxi,appendrow])
team_02_season_summary_2ndxi.to_excel(writer, sheet_name=sheetname, startrow = row_end_t01+4, index=False)

row_end_t02 = row_end_t01 + team_02_season_summary_2ndxi.shape[0] + 4

##########################
# 3rd XI
##########################
worksheet.write(row_end_t02+2,0,"3rd XI",bold14centre)
team_03_season_summary_3rdxi = pd.read_sql(con=pgconn, sql=f"""
    select 
        year,  played,  wo,   w1,  d,   l1,  lo, "Position", association, grade, captain, \"Vice Captain\"                                       
    from team_01_season_summary_all 
    WHERE eleven = '3rd' and (grade != 'T20' or grade is null) order by year"""
    )
appendrow = pd.DataFrame([['Overall',
                           team_03_season_summary_3rdxi['played'].sum(),
                           team_03_season_summary_3rdxi['wo'].sum(),
                           team_03_season_summary_3rdxi['w1'].sum(),
                           team_03_season_summary_3rdxi['d'].sum(),
                           team_03_season_summary_3rdxi['l1'].sum(),
                           team_03_season_summary_3rdxi['lo'].sum(),
                           '','','','','']]
                           ,columns = team_03_season_summary_3rdxi.columns)
team_03_season_summary_3rdxi = pd.concat([team_03_season_summary_3rdxi,appendrow])
team_03_season_summary_3rdxi.to_excel(writer, sheet_name=sheetname, startrow = row_end_t02+4, index=False)


#########################################################################################################################
#########################################################################################################################
# Matches Against
#########################################################################################################################
#########################################################################################################################
sheetname = 'Matches Against'

team_04_matches_against_all = pd.read_sql(con=pgconn, sql=f"select * from team_04_matches_against_all")
team_04_matches_against_all.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:H1',"Record By Opponent",heading1)


#########################################################################################################################
#########################################################################################################################
# Team Scores
#########################################################################################################################
#########################################################################################################################
sheetname = 'Team Scores'

##########################
# High team score
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"select Score, Opponent, Year, Round, eleven as XI, Association, Grade from team_05_scores_highest limit 10")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:I1',"ALCC Highest Team Scores",heading1)

row_end = stats_table.shape[0] + 2

##########################
# Low team score
##########################
worksheet.merge_range(row_end+2,0,row_end+2,7,"ALCC Lowest Team Scores",heading1)
stats_table = pd.read_sql(con=pgconn, sql=f"select Score, Opponent, Year, Round, eleven as XI, Association, Grade from team_06_scores_lowest limit 10")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)

row_end += stats_table.shape[0] + 4

##########################
# Opp High team score
##########################
worksheet.merge_range(row_end+2,0,row_end+2,7,"Opposition Highest Team Scores",heading1)
stats_table = pd.read_sql(con=pgconn, sql=f"select Score, Opponent, Year, Round, eleven as XI, Association, Grade from team_07_scores_opp_highest limit 10")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)

row_end += stats_table.shape[0] + 4

##########################
# Opp Low team score
##########################
worksheet.merge_range(row_end+2,0,row_end+2,7,"Opposition Lowest Team Scores",heading1)
stats_table = pd.read_sql(con=pgconn, sql=f"select Score, Opponent, Year, Round, eleven as XI, Association, Grade from team_08_scores_opp_lowest limit 10")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)


#########################################################################################################################
#########################################################################################################################
# Team Misc
#########################################################################################################################
#########################################################################################################################
sheetname = 'Team Misc'
row_end = 0

##########################
# Fastest team innings - excluding T20
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Run Rate",	"Overs",	"Score",	"Opponent",	"Year",	"Round",	"XI",	"Association",	"Grade"
    from team_09_misc_fast where "Grade" <> 'T20' limit 10""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:I1',"ALCC Fastest Team Innings",heading1)
worksheet.set_row(0, heading1_height)


row_end += stats_table.shape[0] + 2

##########################
# Slowest team innings team_10_misc_slow
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Run Rate",	"Overs",	"Score",	"Opponent",	"Year",	"Round",	"XI",	"Association",	"Grade"
    from team_10_misc_slow where "Grade" <> 'T20' limit 10""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,8,"ALCC Slowest team innings",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4

##########################
# Greatest Winning Margins team_11_misc_margin
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Margin",	"For",	"Against",	"Opponent",	"Year",	"Round",	"XI",	"Association",	"Grade"
    from team_11_misc_margin where "Grade" <> 'T20' limit 10""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,8,"Greatest Winning Margins",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4

##########################
# Tied matches team_12_misc_ties
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Score",	"Opponent",	"Year",	"Round",	"XI",	"Association",	"Grade"
    from team_12_misc_ties""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, startcol=2, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,2,row_end+2,8,"Tied Matches",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4





#########################################################################################################################
#########################################################################################################################
# Team Ind
#########################################################################################################################
#########################################################################################################################
sheetname = ''

#########################################################################################################################
#########################################################################################################################
# Player Batting Summary
#########################################################################################################################
#########################################################################################################################
sheetname = ''

#########################################################################################################################
#########################################################################################################################
# Batting Career
#########################################################################################################################
#########################################################################################################################
sheetname = ''

#########################################################################################################################
#########################################################################################################################
# Batting Milestones
#########################################################################################################################
#########################################################################################################################
sheetname = ''

#########################################################################################################################
#########################################################################################################################
# Batting High
#########################################################################################################################
#########################################################################################################################
sheetname = ''

#########################################################################################################################
#########################################################################################################################
# Batting By Position
#########################################################################################################################
#########################################################################################################################
sheetname = ''

#########################################################################################################################
#########################################################################################################################
# Batting Fast Slow
#########################################################################################################################
#########################################################################################################################
sheetname = ''

#########################################################################################################################
#########################################################################################################################
# Batting Dismissals
#########################################################################################################################
#########################################################################################################################
sheetname = ''

#########################################################################################################################
#########################################################################################################################
# Batting Partnerships
#########################################################################################################################
#########################################################################################################################
sheetname = ''






#########################################################################################################################
#########################################################################################################################
# Player Bowling Summary
#########################################################################################################################
#########################################################################################################################
sheetname = ''




##########################
# Close Workbook
##########################
writer.close()