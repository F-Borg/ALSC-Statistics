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
url = "https://www.playhq.com/cricket-australia/org/adelaide-and-suburban-cricket-association/saturdays-summer-202324/section-9-hopkins-mcgowran-cup/game-centre/be6c9d6d"
# scrape scorecard (saves multiple tables to data/[year]/[grade]/[round]/)
match_info = ss.scrape_scorecard(url, overwrite_md=False)

if False:
    # match_info = {'season': '22-23', 'grade': 'ISC Teamwear LO Division 1', 'round': '2', 'num_days': 1, 'date_day_1': '22 Oct 2022', 'date_day_2': '', 'num_innings': 2, 'innings_list': ['Adelaide Lutheran 1st Innings', 'Kilburn 1st Innings'], 'extras': [{'wd': 2, 'nb': 2, 'lb': 0, 'b': 4, 'p': 0}, {'wd': 7, 'nb': 1, 'lb': 0, 'b': 0, 'p': 0}], 'overs': ['40', '31.2'], 'venue': 'Blair Athol Reserve / Blair Athol Reserve - Main Oval', 'opponent': 'Kilburn', 'winner': 'Kilburn', 'result': 'L1', 'captain': 'Finley Borgas', 'game_dir': 'data/22-23/ISC Teamwear LO Division 1/Rnd_2'}
    match_info['wicketkeeper'] = 'Peter Taylor' #'Franco Raponi' # 'Nikki Grosser' #'Azad Jivani' 'Karim Valani' 
    match_info['captain'] = 'Jim Wills' #'Finley Borgas'
    match_info['fow_list'] = [["1-9 Peter Moyle, 2-15 David Conway, 3-19 Player, 4-23 Mark Sansome, 5-25 Sebastian O'Loughlin, 6-25 Richard Jackson, 7-34 Steven Sampson, 8-34 Player, 9-34 Brett Lithgow, 10-50 Adam Basedow"], ['1-23 Peter Taylor, 2-65 Steven Wilson, 3-87 Marko Fedojuk, 4-108 Connor Brown, 5-108 James Carragher, 6-110 Matthew Bell'], ["1-18 Adam Basedow, 2-20 Player, 3-29 Peter Moyle, 4-37 Sebastian O'Loughlin, 5-56 Brett Lithgow, 6-78 David Conway, 7-95 Richard Jackson, 8-112 Player, 9-119 Mark Sansome"], ['1-10 Marko Fedojuk']]
    match_info['extras'] = [{'wd': 11, 'nb': 2, 'lb': 0, 'b': 5, 'p': 0}, {'wd': 6, 'nb': 11, 'lb': 0, 'b': 0, 'p': 0}]
    match_info['result'] = 'D'

# Check for missing/not recognised players
util.check_player_ids(match_info)

# Validate
wd.wrangle_match_data(match_info, write_to_postgres = False)

# wrangle data and export
if False:
    wd.wrangle_match_data(match_info, write_to_postgres = True)


