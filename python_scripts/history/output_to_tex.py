from sqlalchemy import create_engine
import pandas as pd

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()


############################
# User input               
############################
_season_ = '2024/25' # e.g. _season_ = '2021/22'
seasonid_1stxi = 81
seasonid_2ndxi = 82
# seasonid_3rdxi = 78

xi_1 = '1st XI'
xi_2 = '2nd XI'
# xi_3 = '3rd XI'


#########################################################################################################################
#########################################################################################################################
# Milestones
#########################################################################################################################
#########################################################################################################################
tex_doc="tex_scripts/tables/milestones.tex"

stats_table = pd.read_sql(con=pgconn, sql=f"""
SELECT
    "Name",
    ("Total Matches" - mod("Total Matches"::int,50))::varchar || ' Matches' as "Milestone",
    "Season Matches",
    "Total Matches",
    playerid
FROM (
    SELECT 
        name_fl as "Name",
        playerid,
        sum(case when "Year" = '{_season_}' then "Matches" else 0 end) as "Season Matches", 
        sum(case when "Year" <= '{_season_}' then "Matches" else 0 end) as "Total Matches"
    FROM yb_02_batting_summary
    group by playerid, name_fl
    having sum(case when "Year" = '{_season_}' then "Matches" else 0 end) > 0
    ) a
WHERE mod("Total Matches"::int,50) < "Season Matches"
ORDER BY "Total Matches" DESC
""")

with open(tex_doc, 'w') as tf:
    tf.write(stats_table.to_latex())

print(stats_table.to_latex())
