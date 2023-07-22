import python_scripts.scrape_scorecard as ss
import python_scripts.wrangle_match_data as wd


# reload when required
import importlib
importlib.reload(ss)

# Issues:
# FOW is currently missing from website


# need manual input for season ID, match ID, innings ID at this stage

# fetch match url
# url = get_url(season,grade,rnd)
url = "https://www.playhq.com/cricket-australia/org/adelaide-turf-cricket-association/mens-senior-competitions-summer-202223/senior-men-isc-teamwear-lo-division-1/game-centre/bd01fb60"

# scrape scorecard (return multiple tables I guess...)
match_info = ss.scrape_scorecard(url)
# match_info = {'season': '22-23', 'grade': 'ISC Teamwear LO Division 1', 'round': '2', 'num_days': 1, 'date_day_1': '22 Oct 2022', 'date_day_2': '', 'num_innings': 2, 'innings_list': ['Adelaide Lutheran 1st Innings', 'Kilburn 1st Innings'], 'venue': 'Blair Athol Reserve / Blair Athol Reserve - Main Oval', 'opponent': 'Kilburn', 'winner': 'Kilburn', 'captain': 'Finley Borgas', 'game_dir': 'data/22-23/ISC Teamwear LO Division 1/Rnd_2'}


# open for validation/modification
# os.system('code -r ./data/test1.md')

# wrangle data


# export to postgres
