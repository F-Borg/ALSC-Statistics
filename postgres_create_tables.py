import pandas as pd
from sqlalchemy import create_engine


# import psycopg2
# conn = psycopg2.connect(
#     host="localhost",
#     database="dev",
#     user="postgres",
#     password="postgres1!"
#     )
# cur = conn.cursor()


engine = create_engine('postgresql+psycopg2://postgres:postgres1!@localhost/dev')


#########################################################################################################################
# Import from excel
#########################################################################################################################
seasons = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2020-21\20-21 db temp.xlsx', sheet_name='seasons')
matches = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2020-21\20-21 db temp.xlsx', sheet_name='Matches')
innings = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2020-21\20-21 db temp.xlsx', sheet_name='Innings')
batting = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2020-21\20-21 db temp.xlsx', sheet_name='Batting')
bowling = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2020-21\20-21 db temp.xlsx', sheet_name='Bowling')
wickets = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2020-21\20-21 db temp.xlsx', sheet_name='Wickets')


#########################################################################################################################
# Create tables in postgres
#########################################################################################################################
seasons.to_sql('seasons', engine, if_exists='replace', index=False)
matches.to_sql('matches', engine, if_exists='replace', index=False)
innings.to_sql('innings', engine, if_exists='replace', index=False)
batting.to_sql('batting', engine, if_exists='replace', index=False)
bowling.to_sql('bowling', engine, if_exists='replace', index=False)
wickets.to_sql('wickets', engine, if_exists='replace', index=False)







