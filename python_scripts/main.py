import python_scripts.scrape_scorecard as ss
import python_scripts.wrangle_match_data as wd
import python_scripts.utility as util
import os

# reload when required after updates to code
# import importlib
# importlib.reload(ss)
# importlib.reload(wd)
# importlib.reload(util)

# Issues:
# venue - get everything after the "/"


# fetch match url
# !!! copy and paste the url for the match into the url variable below
url = "https://www.playhq.com/cricket-australia/org/adelaide-and-suburban-cricket-association/saturdays-summer-202425/section-9-hopkins-mcgowran-cup/game-centre/3ba1bec8"

# scrape scorecard (saves multiple tables to data/[year]/[grade]/[round]/)
match_info = ss.scrape_scorecard(url, overwrite_md=False)

# !!! check data/[yy-yy]/[grade]/[round]/ 
# add any missing info:
# batting: balls faced, boundaries
# bowling: boundaries, extras 

# !!! if there is anything missing from the online scorecard, then update them by running relevant lines below
if False:
    # match_info = {'season': '24-25', 'grade': 'Section 5 At the Toss of a Coin Cup', 'round': '4', 'num_days': 2, 'date_day_1': '09 Nov 2024', 'date_day_2': '16 Nov 2024', 'num_innings': 2, 'innings_list': ['Plympton Footballers II 1st Innings', 'Adelaide Lutheran 1st Innings'], 'fow_list': [['1-88 Adrian Foote, 2-105 Oliver Martin, 3-175 Caleb King, 4-227 Lachlan Foote, 5-235 Ross Moore, 6-241 Neil Tredwell, 7-243 David Newell, 8-255 Jett Chapman'], ['1-46 Yash Sandhu, 2-52 Parth Gohil, 3-62 Tarquin Kloeden, 4-229 Daniel Grosser']], 'extras': [{'wd': 8, 'nb': 6, 'lb': 1, 'b': 2, 'p': 0}, {'wd': 1, 'nb': 4, 'lb': 0, 'b': 7, 'p': 0}], 'overs': ['60', '50'], 'venue': 'Plympton Oval / Plympton Oval', 'opponent': 'Plympton Footballers II', 'winner': 'Adelaide Lutheran', 'result': 'W1', 'captain': 'Jeremy Borgas', 'game_dir': 'data/24-25/Section 5 At the Toss of a Coin Cup/Rnd_4'}
    match_info['wicketkeeper'] = 'Peter Taylor' #'Tom Adler' # 'Peter Taylor' #'Franco Raponi' # 'Nikki Grosser' #'Azad Jivani' 'Karim Valani' 
    match_info['wicketkeeper'] = 'Tom Adler'
    match_info['captain'] = 'Jim Wills'
    match_info['captain'] = 'Finley Borgas'
    match_info['fow_list'] = [[], ['1-18 Jim Wills, 2-23 Marko Fedojuk, 3-42 David Fitzsimmons, 4-79 Peter Taylor, 5-106 Joshua Waldhuter, 6-136 Connor Brown, 7-154 Christopher Mann, 8-156 Justin Leckie, 9-176 Matthew Bell']]
    match_info['extras'] = [{'wd': 11, 'nb': 2, 'lb': 0, 'b': 5, 'p': 0}, {'wd': 6, 'nb': 11, 'lb': 0, 'b': 0, 'p': 0}]
    match_info['result'] = 'D'

# Check for missing/not recognised players
# !!! add any new players - see sql_scripts/misc/utility.pgsql
util.check_player_ids(match_info)

# !!! Validate
# all playerids are there
# bowling: assists have playerids where applicable
# batting: FOW looks correct
wd.wrangle_match_data(match_info, write_to_postgres = False)

# wrangle data and export
if False:
    # !!! run this after validating
    wd.wrangle_match_data(match_info, write_to_postgres = True)


