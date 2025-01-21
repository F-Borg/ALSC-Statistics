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



##########################
# Close Workbook
##########################
writer.close()