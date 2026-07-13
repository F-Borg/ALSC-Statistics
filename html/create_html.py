from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd
import re
from math import ceil, floor
from jinja2 import Environment, FileSystemLoader
import python_scripts.text_formats as tf

engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()


seasonid=70

# Load summary table
stats_table = pd.read_sql(con=pgconn, sql=f"""select * from yb_01_season_summary
where seasonid = {seasonid}""")
# Get number of rounds for later use
num_rounds = len(stats_table['round'].drop_duplicates())



yb_02_batting_summary = pd.read_sql(con=pgconn, sql=f"""select * from yb_02_batting_summary
    where seasonid = {seasonid}""").iloc[:,4:20]

yb_02_batting_summary = yb_02_batting_summary.applymap(lambda x: None if x==-9 else x)


smry = ['Team Totals',num_rounds,sum(yb_02_batting_summary['Innings']),sum(yb_02_batting_summary['Not Outs']),
        sum(yb_02_batting_summary['Fours']),sum(yb_02_batting_summary['Sixes']),sum(yb_02_batting_summary['Ducks']),
        sum(yb_02_batting_summary['Fifties']),sum(yb_02_batting_summary['Hundreds']),max(yb_02_batting_summary['Highest Score'].apply(lambda x: x.replace('*',''))),
        sum(yb_02_batting_summary['Total Runs']),
        sum(yb_02_batting_summary['Total Runs'])/(sum(yb_02_batting_summary['Innings'])-sum(yb_02_batting_summary['Not Outs'])), # Average
        sum(yb_02_batting_summary['Balls Faced']), # BF
        sum(yb_02_batting_summary['Balls Faced'])/(sum(yb_02_batting_summary['Innings'])-sum(yb_02_batting_summary['Not Outs'])), # BF / dismissal
        100*sum(yb_02_batting_summary['Total Runs'])/sum(yb_02_batting_summary['Balls Faced']), # Strike rate
        100*(4*sum(yb_02_batting_summary['Fours'])+6*sum(yb_02_batting_summary['Sixes']))/sum(yb_02_batting_summary['Total Runs'])] # pct runs in boundaries

i = len(yb_02_batting_summary)
yb_02_batting_summary.loc[i] = smry


yb_03_batting_pships = pd.read_sql(con=pgconn, sql=f"""select * from yb_03_batting_pships
    where seasonid = {seasonid}""").iloc[:,0:6]

env = Environment(loader=FileSystemLoader("."))
template = env.get_template("html/template.html")

html = template.render(
    yb_02_batting_summary=yb_02_batting_summary.to_html(
        index=False,
        classes="report-table"
    ),
    yb_03_batting_pships=yb_03_batting_pships.to_html(
        index=False,
        classes="report-table shrink"
    )
)




with open("html/report.html", "w", encoding="utf-8") as f:
    f.write(html)


