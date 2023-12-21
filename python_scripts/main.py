import python_scripts.scrape_scorecard as ss
import python_scripts.wrangle_match_data as wd
import python_scripts.utility as util
import os


# reload when required
import importlib
importlib.reload(ss)
importlib.reload(wd)
importlib.reload(util)

# Issues:
# need manual input for season ID, match ID, innings ID at this stage
# venue - get everything after the "/"


# fetch match url
# url = get_url(season,grade,rnd)
url = "https://www.playhq.com/cricket-australia/org/adelaide-and-suburban-cricket-association/summer-202223/section-9-hopkins-mcgowran-cup/game-centre/20421e2c"

# scrape scorecard (saves multiple tables to data/[year]/[grade]/[round]/)
match_info = ss.scrape_scorecard(url, overwrite_md=False)
# match_info = {'season': '22-23', 'grade': 'ISC Teamwear LO Division 1', 'round': '2', 'num_days': 1, 'date_day_1': '22 Oct 2022', 'date_day_2': '', 'num_innings': 2, 'innings_list': ['Adelaide Lutheran 1st Innings', 'Kilburn 1st Innings'], 'extras': [{'wd': 2, 'nb': 2, 'lb': 0, 'b': 4, 'p': 0}, {'wd': 7, 'nb': 1, 'lb': 0, 'b': 0, 'p': 0}], 'overs': ['40', '31.2'], 'venue': 'Blair Athol Reserve / Blair Athol Reserve - Main Oval', 'opponent': 'Kilburn', 'winner': 'Kilburn', 'result': 'L1', 'captain': 'Finley Borgas', 'game_dir': 'data/22-23/ISC Teamwear LO Division 1/Rnd_2'}

if False:
    match_info['wicketkeeper'] = 'Franco Raponi' 'Azad Jivani' 'Karim Valani' 
    match_info['captain'] = 'Hussain Habib'
    match_info['fow_list'] = [['1-16 Martin Jongeneel, 2-21 Kaspar Jongeneel, 3-22 Mark Carragher, 4-25 Hussain Habib, 5-33 Toby Carragher, 6-35 Michael Vardaro, 7-36 Franco Raponi, 8-73 Vamil Shah, 9-75 James Carragher, 10-76 Kashap Patel'], []] 
    match_info['extras'] = [{'wd': 11, 'nb': 2, 'lb': 0, 'b': 5, 'p': 0}, {'wd': 6, 'nb': 11, 'lb': 0, 'b': 0, 'p': 0}]
    match_info['result'] = 'L1'

# Check for missing/not recognised players
missing_ids = util.check_player_ids(match_info)
if len(missing_ids) > 0:
    print(missing_ids)



# check
wd.wrangle_match_data(match_info, write_to_postgres = False)

# wrangle data and export
if False:
    wd.wrangle_match_data(match_info, write_to_postgres = True)


