from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
import pandas as pd


engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()

# pgconn.close()

#########################################################################################################################
# Season Summary
#########################################################################################################################

season_summary_1st = pd.read_sql(con=pgconn, sql=f"select * from season_summary where eleven='1st' order by year")
season_summary_1st = season_summary_1st.loc[:, 'year':'association']

latest_season = season_summary['year'].max().replace('/','-')

# Create a Pandas Excel writer using XlsxWriter as the engine.
writer = pd.ExcelWriter(f"data/excel/ALSC_Statistical_History_{latest_season}.xlsx", engine="xlsxwriter")
wb = writer.book

#############
# Formats
#############
heading1 = wb.add_format({'size':16,'bold':True,'underline':True})







season_summary_1st.to_excel(writer, sheet_name="Season Summary", startrow = 5, index=False)
worksheet = writer.sheets["Season Summary"]
worksheet.write(0,0,"Adelaide Lutheran Cricket Club Season Summary",heading1)
worksheet.merge_range('A1':'L1')

writer.close()
