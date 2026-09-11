import python_scripts.api_playhq as api
import http.client

import importlib
importlib.reload(api)


####################################
# input
####################################
# association=['asca','saca_junior','atca']
association='saca_junior'
# competition=['WSJCA','Western Suburbs']
competition='WSJCA'

OUR_CLUB_REGEX = r'(Adelaide Junior Bulldogs|Adelaide Lutheran|\bADE\b)'

client = api.PlayHQClient(association=association)
print(f"Using organisation_id={client.organisation_id}, tenant={client.tenant}")

grades_list = api.find_grades_for_team(client, organisation_id=client.organisation_id, our_club_regex=OUR_CLUB_REGEX)




seasons = client.get_seasons()
print(f"Connection OK - found {len(seasons)} season(s):")
for season in seasons:
    print(f"  {season['id']}  {season['name']}  {season['competition']['name']}")

season = [x['id'] for x in seasons if x['name'] == 'Summer 2025/26'][0]

seasons[0]

grades = client.get_grades(season_id=season)
for grade in grades:
    print(f"  {grade['id']}  {grade['name']}")

grade_id = [x['id'] for x in grades if x['name'] == 'Section 4 Elder Meat Store Cup'][0]

fixture = client.get_grade_fixture(grade_id=grade)

team_id = next(t['id'] for t in fixture['teams'] if t['name'] == 'Adelaide Lutheran')

OUR_CLUB_REGEX = r'(Adelaide Junior Bulldogs|Adelaide Lutheran|\bADE\b)'
match_infos = api.fetch_grade_matches(client, grade_id, 
                                      grade_name='Section 4 Elder Meat Store Cup', 
                                      our_club_regex=OUR_CLUB_REGEX, 
                                      overwrite_md=False)