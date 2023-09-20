import python_scripts.scrape_scorecard as ss
import python_scripts.wrangle_match_data as wd
import python_scripts.utility as util


# reload when required
import importlib
importlib.reload(ss)
importlib.reload(wd)
importlib.reload(util)

# Issues:
# FOW is currently missing from website


# need manual input for season ID, match ID, innings ID at this stage

# fetch match url
# url = get_url(season,grade,rnd)
url = "https://www.playhq.com/cricket-australia/org/adelaide-turf-cricket-association/mens-senior-competitions-summer-202223/senior-men-isc-teamwear-lo-division-1/game-centre/bd01fb60"

# scrape scorecard (return multiple tables I guess...)
match_info = ss.scrape_scorecard(url)
# match_info = {'season': '22-23', 'grade': 'ISC Teamwear LO Division 1', 'round': '2', 'num_days': 1, 'date_day_1': '22 Oct 2022', 'date_day_2': '', 'num_innings': 2, 'innings_list': ['Adelaide Lutheran 1st Innings', 'Kilburn 1st Innings'], 'extras': [{'wd': 2, 'nb': 2, 'lb': 0, 'b': 4, 'p': 0}, {'wd': 7, 'nb': 1, 'lb': 0, 'b': 0, 'p': 0}], 'overs': ['40', '31.2'], 'venue': 'Blair Athol Reserve / Blair Athol Reserve - Main Oval', 'opponent': 'Kilburn', 'winner': 'Kilburn', 'result': 'L1', 'captain': 'Finley Borgas', 'game_dir': 'data/22-23/ISC Teamwear LO Division 1/Rnd_2'}

match_info['wicketkeeper'] = 'Marko Fedojuk'


# Check for missing/not recognised players
missing_ids = util.check_player_ids(match_info)

if len(missing_ids) > 0:
    print(missing_ids)


# open for validation/modification
# os.system('code -r ./data/22-23/ISC Teamwear LO Division 1')

# wrangle data and export
wd.wrangle_match_data(match_info, write_to_postgres = False)



    