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
centre = wb.add_format({'align':'centre'})


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
# Tied matches
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


#########################################################################################################################
#########################################################################################################################
# Player Batting Summary
#########################################################################################################################
#########################################################################################################################
row_end = 0

player_count = pd.read_sql(con=pgconn, sql=f"""select count(*) from batting_01_summary_ind""")['count'][0]
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
    worksheet.merge_range('A1:R1',"ALCC Player Batting Career Summary",heading1)
    worksheet.set_row(0, heading1_height)


#########################################################################################################################
#########################################################################################################################
# Career Batting
#########################################################################################################################
#########################################################################################################################
sheetname = 'Career Batting'
row_end = 0

##########################
# Most Career Runs
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Runs", "Name", "Inn", "Average"
    from batting_02_career_runs limit 25""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 3, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:D1',"Most Career Runs",heading1)
worksheet.set_row(0, heading1_height)

##########################
# Highest Career Average
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Runs", "Name", "Inn", "Average"
    from batting_03_career_ave limit 25""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 3, startcol=5, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('F1:I1',"Highest Career Average",heading1)
worksheet.set_row(0, heading1_height)

row_end = stats_table.shape[0] + 3

##########################
# Fastest Career Strike Rate
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Runs/100 Balls", "Name", "Runs", "Balls"
    from batting_04_career_sr_high limit 20""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+5, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,3,"Fastest Career Strike Rate",heading1)
worksheet.set_row(row_end+2, heading1_height)

##########################
# Slowest Career Strike Rate
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select "Runs/100 Balls", "Name", "Runs", "Balls"
    from batting_05_career_sr_low limit 20""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+5, startcol=5, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,5,row_end+2,8,"Slowest Career Strike Rate",heading1)
worksheet.set_row(row_end+2, heading1_height)


#########################################################################################################################
#########################################################################################################################
# Batting Milestones
#########################################################################################################################
#########################################################################################################################
sheetname = 'Batting Milestones'
row_end = 0

##########################
# Most Hundreds
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select name as "Name", Hundreds as "100s", inn as "Inn", "Percentage 100s"
    from batting_06_milestones_100 where Hundreds >= 3""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:F1',"Most Hundreds",heading1)
worksheet.set_row(0, heading1_height)

row_end = stats_table.shape[0] + 2

##########################
# Most Fifties
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select name as "Name", Fifties as "50s", inn as "Inn", "Percentage 50s"
    from batting_07_milestones_50 limit 15""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A13:F13',"Most Fifties",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += 4 + stats_table.shape[0]

##########################
# Most Ducks
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select name as "Name", ducks as "Ducks", inn as "Inn", "Percentage Ducks"
    from batting_08_milestones_ducks limit 15""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,5,"Most Ducks",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += 4 + stats_table.shape[0]

##########################
# Most Runs In A Season (in one division)
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Name as "Name", runs AS "Runs", Mat as "Mat", Average as "Average", Year as "Year"
    , Eleven as "XI", Association as "Association", Grade as "Grade"
    from batting_09_milestones_runs_season limit 15""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,5,"Most Runs In A Season (in one division)",heading1)
worksheet.set_row(row_end+2, heading1_height)


#########################################################################################################################
#########################################################################################################################
# Batting High
#########################################################################################################################
#########################################################################################################################
sheetname = 'Batting High'
row_end = 0

##########################
# Highest Individual Scores
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Name AS "Name",Score AS "Score",Balls_Faced AS "Balls Faced",Opponent AS "Opponent",Year AS "Year"
                          ,Round AS "Round",eleven AS "XI",Association AS "Association",Grade AS "Grade"
    from batting_10_high_score_ind limit 30""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:J1',"Highest Individual Scores",heading1)
worksheet.set_row(0, heading1_height)

row_end = stats_table.shape[0] + 2

##########################
# Most 6s in an Innings
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select Name AS "Name",_6s AS "6s",score AS "Runs",balls_faced AS "Balls",Opponent AS "Opponent",Year AS "Year"
                          ,Round AS "Round",eleven AS "XI",Association AS "Association",Grade AS "Grade"
    from batting_11_high_score_sixes limit 10""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,9,"Most 6s in an Innings",heading1)
worksheet.set_row(row_end+2, heading1_height)


#########################################################################################################################
#########################################################################################################################
# Batting By Position
#########################################################################################################################
#########################################################################################################################
sheetname = 'Batting By Position'
row_end = 0

##########################
# Highest 1st XI Scores By Batting Position
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select bat_pos AS "Postion",
maxofscore AS "Score",
Balls_Faced AS "Balls Faced",
batter AS "Batter",
Opponent AS "Opponent",
Year AS "Year",
Round AS "Round",
Association AS "Association",
Grade AS "Grade"
    from batting_12_score_by_posn_1stXI""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = 2, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range('A1:I1',"Highest 1st XI Scores By Batting Position",heading1)
worksheet.set_row(0, heading1_height)

row_end = stats_table.shape[0] + 2

##########################
# Highest 2nd XI Scores By Batting Position
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select bat_pos AS "Postion",
maxofscore AS "Score",
Balls_Faced AS "Balls Faced",
batter AS "Batter",
Opponent AS "Opponent",
Year AS "Year",
Round AS "Round",
Association AS "Association",
Grade AS "Grade"
    from batting_13_score_by_posn_2ndXI""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,8,"Highest 2nd XI Scores By Batting Position",heading1)
worksheet.set_row(row_end+2, heading1_height)

row_end += stats_table.shape[0] + 4


##########################
# Highest 3rd XI Scores By Batting Position
##########################
stats_table = pd.read_sql(con=pgconn, sql=f"""select bat_pos AS "Postion",
maxofscore AS "Score",
Balls_Faced AS "Balls Faced",
batter AS "Batter",
Opponent AS "Opponent",
Year AS "Year",
Round AS "Round",
Association AS "Association",
Grade AS "Grade"
    from batting_14_score_by_posn_3rdXI""")
stats_table.to_excel(writer, sheet_name=sheetname, startrow = row_end+4, index=False)
worksheet = writer.sheets[sheetname]
worksheet.merge_range(row_end+2,0,row_end+2,8,"Highest 3rd XI Scores By Batting Position",heading1)
worksheet.set_row(row_end+2, heading1_height)


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