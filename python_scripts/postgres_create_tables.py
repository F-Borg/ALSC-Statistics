import pandas as pd
import re
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
seasons = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2021-22\21-22 db temp.xlsx', sheet_name='seasons')
matches = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2021-22\21-22 db temp.xlsx', sheet_name='Matches')
innings = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2021-22\21-22 db temp.xlsx', sheet_name='Innings')
batting = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2021-22\21-22 db temp.xlsx', sheet_name='Batting')
bowling = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2021-22\21-22 db temp.xlsx', sheet_name='Bowling')
wickets = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2021-22\21-22 db temp.xlsx', sheet_name='Wickets')

# players = pd.read_excel(r'C:\Users\Fin\Documents\ALSC stats\ALSC Stats 2020-21\20-21 db temp.xlsx', sheet_name='Players2')


#########################################################################################################################
# Additions for update
#########################################################################################################################
seasons['playhq_season'] = ''
appendrow = pd.DataFrame([[76,'2022/23','ATCA','LO1','1st',269,0,0,'True','ISC Teamwear LO Division 1']],columns = seasons.columns)
seasons = pd.concat([seasons,appendrow])



# def split_LF_name_first(name):
#     return re.sub('(.*?), (.*)','\\2',name)

# def split_LF_name_last(name):
#     return re.sub('(.*?), (.*)','\\1',name)

# players['FirstName'] = players['Name'].apply(split_LF_name_first)
# players['Surname'] = players['Name'].apply(split_LF_name_last)







#########################################################################################################################
# Create tables in postgres
#########################################################################################################################
seasons.to_sql('seasons', engine, if_exists='replace', index=False)
matches.to_sql('matches', engine, if_exists='replace', index=False)
innings.to_sql('innings', engine, if_exists='replace', index=False)
batting.to_sql('batting', engine, if_exists='replace', index=False)
bowling.to_sql('bowling', engine, if_exists='replace', index=False)
wickets.to_sql('wickets', engine, if_exists='replace', index=False)

# players.to_sql('players', engine, if_exists='replace', index=False)





