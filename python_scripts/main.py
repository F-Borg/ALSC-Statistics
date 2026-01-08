import python_scripts.scrape_scorecard as ss
import python_scripts.scrape_scorecard_playcricket as ssp
import python_scripts.wrangle_match_data as wd
import python_scripts.utility as util

# reload when required after updates to code
import importlib
importlib.reload(ss)
importlib.reload(ssp)
importlib.reload(wd)
importlib.reload(util)


# fetch match url
# !!! copy and paste the url for the match into the url variable below
url = "https://www.playhq.com/cricket-australia/org/adelaide-and-suburban-cricket-association/cricket-summer-202526/section-9-hopkins-mcgowran-cup/game-centre/c4f7d42f"

# scrape scorecard (saves multiple tables to data/[year]/[grade]/[round]/)
match_info = ss.scrape_scorecard(url, overwrite_md=False)
# match_info = ss.scrape_scorecard(url, overwrite_md=False, team='Blue')
# match_info = ssp.scrape_scorecard_playcricket(url, overwrite_md=False, team='Red')

# !!! check data/[yy-yy]/[grade]/[round]/ 
# add any missing info:
# batting: balls faced, boundaries
# make sure ALL players are listed in our batting innings
# bowling: boundaries, extras 

# !!! if there is anything missing from the online scorecard, then update them by running relevant lines below
if False:
    match_info['wicketkeeper'] = 'Marko Fedojuk' 
    match_info['wicketkeeper'] = 'Peter Taylor'
    match_info['wicketkeeper'] = 'Brett MacTavish'
    match_info['captain'] = 'Jim Wills'
    match_info['captain'] = 'Finley Borgas'
    match_info['fow_list'] = [['1-9 Brett MacTavish, 2-37 Steven Wilson, 3-58 Connor Brown, 4-96 David Fitzsimmons, 5-186 Joshua Waldhuter, 6-186 Christopher Mann, 7-186 Sidhaarth Bamarani Thangaswamy, 8-188 Joshua Fitzsimmons, 9-189 Michael Vardaro'], ['1-97 Player, 2-139 Peter Hughes, 3-176 Michael Bayliss']]
    match_info['extras'] = [{'wd': 11, 'nb': 2, 'lb': 0, 'b': 5, 'p': 0}, {'wd': 6, 'nb': 11, 'lb': 0, 'b': 0, 'p': 0}]
    match_info['result'] = 'W1'
    match_info['grade'] = 'WSJCA Under 10 Pool A - Red'


# Check for missing/not recognised players
# Unknown PlayerX
# !!! add any new players
util.check_player_ids(match_info)

if False:
    newplayer=util.check_player_ids(match_info)[0]
    fname=newplayer.split()[0]
    lname=newplayer.split()[1]
    util.add_new_player(fname,lname)

    # util.add_new_player('Takdir Singh','Sahota')

# !!! Validate:
# all player ids are there
# bowling: assists have playerids where applicable
# batting: FOW looks correct
wd.wrangle_match_data(match_info, write_to_postgres = False)

# wrangle data and export
if False:
    # !!! run this after validating
    wd.wrangle_match_data(match_info, write_to_postgres = True)

