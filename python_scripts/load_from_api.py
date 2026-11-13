import python_scripts.api_playhq as api
import http.client
import pprint
import pandas as pd

import importlib
importlib.reload(api)


####################################
# input
####################################
if False:
    # association=['asca','saca_junior','atca']
    association='asca'
    season='Summer 2026/27'

    association='atca'
    competition='3. Junior Boys Competition'
    season='Summer 2025/26'

    # competition=['WSJCA','Western Suburbs']
    competition='WSJCA'

OUR_CLUB_REGEX = r'(Adelaide Junior Bulldogs|Adelaide Bulldogs|Adelaide Lutheran)' # |\bADE\b)

client = api.PlayHQClient(association=association)
print(f"Using organisation_id={client.organisation_id}, tenant={client.tenant}")

grades_list = api.find_grades_for_team(client, organisation_id=client.organisation_id, our_club_regex=OUR_CLUB_REGEX)

# pprint.pprint(grades_list)

grades_list_df = pd.DataFrame(grades_list)
grades_list_df[['season_name','competition_name','grade_name','team_name']].sort_values(by='season_name')

grades_list_df.loc[grades_list_df['season_name'] == season].iloc[0]

# i=1
# this_grade=grades_list_df.loc[grades_list_df['season_name'] == 'Summer 2023/24'].iloc[2]

# grades_list_tmp=grades_list_df[['grade_id','grade_name']].drop_duplicates()
grades_list_tmp=grades_list_df.loc[grades_list_df['season_name'] == season][['grade_id','grade_name']].drop_duplicates()

for row in grades_list_tmp.itertuples(index=False):
    # row=grades_list_tmp.iloc[0]
    match_infos = api.fetch_grade_matches(client, grade_id=row.grade_id, 
                                          grade_name=row.grade_name, 
                                          our_club_regex=OUR_CLUB_REGEX, 
                                          overwrite_md=False)



# pprint.pprint(match_infos)
# fixture = client.get_grade_fixture(this_grade['grade_id'])
# pprint.pprint(fixture)

# match_infos = api.fetch_grade_matches(client, grade_id, 
#                                       grade_name='Section 4 Elder Meat Store Cup', 
#                                       our_club_regex=OUR_CLUB_REGEX, 
#                                       overwrite_md=False)


match_infos = api.fetch_recent_matches_all_associations(days=7)


# seasons = client.get_seasons()
# print(f"Connection OK - found {len(seasons)} season(s):")
# for season in seasons:
#     print(f"  {season['id']}  {season['name']}  {season['competition']['name']}")

# season = [x['id'] for x in seasons if x['name'] == 'Summer 2025/26'][0]

# seasons[0]

# grades = client.get_grades(season_id=season)
# for grade in grades:
#     print(f"  {grade['id']}  {grade['name']}")

# grade_id = [x['id'] for x in grades if x['name'] == 'Section 4 Elder Meat Store Cup'][0]

# fixture = client.get_grade_fixture(grade_id=grade)

# team_id = next(t['id'] for t in fixture['teams'] if t['name'] == 'Adelaide Lutheran')

# OUR_CLUB_REGEX = r'(Adelaide Junior Bulldogs|Adelaide Lutheran|\bADE\b)'
# match_infos = api.fetch_grade_matches(client, grade_id, 
#                                       grade_name='Section 4 Elder Meat Store Cup', 
#                                       our_club_regex=OUR_CLUB_REGEX, 
#                                       overwrite_md=False)



