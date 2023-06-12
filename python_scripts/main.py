import python_scripts.scrape_scorecard

# maybe put all this into a function that pauses running when the excel spreadsheet is open
# need manual input for season ID, match ID, innings ID

# fetch match url
# url = get_url(season,grade,rnd)
url = "https://www.playhq.com/cricket-australia/org/adelaide-turf-cricket-association/mens-senior-competitions-summer-202223/senior-men-isc-teamwear-lo-division-1/game-centre/bd01fb60"

# scrape scorecard (return multiple tables I guess...)
scrape_scorecard(url)

# export to excel for validation/modification

# open excel file for validation/modification

# import back to python

# export to postgres
