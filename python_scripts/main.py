import python_scripts.scrape_scorecard as ss
import python_scripts.wrangle_match_data as wd


# reload when required
import importlib
importlib.reload(ss)

# Issues:
# FOW is currently missing from website

# maybe put all this into a function that pauses running when the excel spreadsheet is open
# need manual input for season ID, match ID, innings ID

# fetch match url
# url = get_url(season,grade,rnd)
url = "https://www.playhq.com/cricket-australia/org/adelaide-turf-cricket-association/mens-senior-competitions-summer-202223/senior-men-isc-teamwear-lo-division-1/game-centre/bd01fb60"

# scrape scorecard (return multiple tables I guess...)
match_info = ss.scrape_scorecard(url)

# open for validation/modification
# os.system('code -r ./data/test1.md')

# wrangle data


# export to postgres
