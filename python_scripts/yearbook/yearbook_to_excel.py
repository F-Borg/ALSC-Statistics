#### Notes:
"""
# Milestones

# Records

# Adelaide Lutheran 1st XI Season Summary

# Adelaide Lutheran 2nd XI Season Summary

# Adelaide Lutheran 3rd XI Season Summary - if applicable

# Ind Batting Details

# Ind Bowling Details
"""

#########################################################################################################################
#########################################################################################################################
# Setup
#########################################################################################################################
#########################################################################################################################
from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy import text
# from math import ceil
import pandas as pd
import python_scripts.yearbook.yearbook_to_excel_fns as yb
import python_scripts.text_formats as tf
import os


# reload when required
import importlib
importlib.reload(yb)
importlib.reload(tf)



engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')
pgconn = engine.connect()


############################
# User input               
############################
_season_ = '2022/23' # e.g. _season_ = '2021/22'
seasonid_1stxi = 76
seasonid_2ndxi = 77
seasonid_3rdxi = 78

xi_1 = '1st XI'
xi_2 = '2nd XI'
xi_3 = '3rd XI'

############################
# Create Excel doc.
############################
latest_season = _season_.replace('/','-')
writer = pd.ExcelWriter(f"data/excel/ALSC_yearbook_{latest_season}.xlsx", engine="xlsxwriter")
wb = writer.book
# fmt = tf.add_text_formats(wb)


#########################################################################################################################
#########################################################################################################################
# Milestones
#########################################################################################################################
#########################################################################################################################



#########################################################################################################################
#########################################################################################################################
# XI Summaries
#########################################################################################################################
#########################################################################################################################
yb.yb_summary(_season_, seasonid_1stxi, xi_1, writer, wb, pgconn)
yb.yb_summary(_season_, seasonid_2ndxi, xi_2, writer, wb, pgconn)
yb.yb_summary(_season_, seasonid_3rdxi, xi_3, writer, wb, pgconn)






writer.close()

