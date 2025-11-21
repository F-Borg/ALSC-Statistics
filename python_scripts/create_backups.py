from sqlalchemy import create_engine
# from sqlalchemy import select
# from sqlalchemy import text
# from math import ceil
import pandas as pd
import python_scripts.text_formats as tf


engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()

############################
# Create Excel doc.
############################
writer = pd.ExcelWriter(f"data/excel/backup.xlsx", engine="xlsxwriter")
wb = writer.book

sheetname = 'batting'
data = pd.read_sql(con=pgconn, sql=f"select * from batting")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'bowling'
data = pd.read_sql(con=pgconn, sql=f"select * from bowling")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'innings'
data = pd.read_sql(con=pgconn, sql=f"select * from innings")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'matches'
data = pd.read_sql(con=pgconn, sql=f"select * from matches")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'players'
data = pd.read_sql(con=pgconn, sql=f"select * from players")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'seasons'
data = pd.read_sql(con=pgconn, sql=f"select * from seasons")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'wickets'
data = pd.read_sql(con=pgconn, sql=f"select * from wickets")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

# juniors
sheetname = 'batting_j'
data = pd.read_sql(con=pgconn, sql=f"select * from batting_j")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'bowling_j'
data = pd.read_sql(con=pgconn, sql=f"select * from bowling_j")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'fielding_j'
data = pd.read_sql(con=pgconn, sql=f"select * from fielding_j")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'innings_j'
data = pd.read_sql(con=pgconn, sql=f"select * from innings_j")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'matches_j'
data = pd.read_sql(con=pgconn, sql=f"select * from matches_j")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'seasons_j'
data = pd.read_sql(con=pgconn, sql=f"select * from seasons_j")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'wickets_j'
data = pd.read_sql(con=pgconn, sql=f"select * from wickets_j")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

# inclusive
sheetname = 'batting_i'
data = pd.read_sql(con=pgconn, sql=f"select * from batting_i")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'bowling_i'
data = pd.read_sql(con=pgconn, sql=f"select * from bowling_i")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

# sheetname = 'fielding_i'
# data = pd.read_sql(con=pgconn, sql=f"select * from fielding_i")
# data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'innings_i'
data = pd.read_sql(con=pgconn, sql=f"select * from innings_i")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'matches_i'
data = pd.read_sql(con=pgconn, sql=f"select * from matches_i")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'seasons_i'
data = pd.read_sql(con=pgconn, sql=f"select * from seasons_i")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

sheetname = 'wickets_i'
data = pd.read_sql(con=pgconn, sql=f"select * from wickets_i")
data.to_excel(writer, sheet_name=sheetname, startrow = 0, index=False)

##########################
# Close Workbook
##########################
writer.close()