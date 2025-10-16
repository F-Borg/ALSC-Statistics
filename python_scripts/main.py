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
url = "https://www.playhq.com/cricket-australia/org/adelaide-and-suburban-cricket-association/cricket-summer-202526/section-9-hopkins-mcgowran-cup/game-centre/6bff5141"

# scrape scorecard (saves multiple tables to data/[year]/[grade]/[round]/)
match_info = ss.scrape_scorecard(url, overwrite_md=False)
# match_info = ssp.scrape_scorecard_playcricket(url, overwrite_md=False)

# !!! check data/[yy-yy]/[grade]/[round]/ 
# add any missing info:
# batting: balls faced, boundaries
# make sure ALL players are listed in our batting innings
# bowling: boundaries, extras 

# !!! if there is anything missing from the online scorecard, then update them by running relevant lines below
if False:
    match_info = {'season': '24-25', 'grade': 'Section 9 Hopkins McGowran Cup', 'round': '3', 'num_days': 2, 'date_day_1': '26 Oct 2024', 'date_day_2': '02 Nov 2024', 'num_innings': 3, 'innings_list': ['Mitchell Park V 1st Innings', 'Adelaide Lutheran II 1st Innings', 'Mitchell Park V 2nd Innings'], 'fow_list': [['1-47 Joshua Clayton, 2-48 Andrew Basedow, 3-61 Adam Basedow, 4-70 Tyler Clayton, 5-86 Bodie Menzel, 6-88 Gurshaan Singh Khera, 7-88 Player, 8-89 Brett Lithgow, 9-95 Drishya Yadav, 10-98 Andrew Menzel'], ['1-1 Brett MacTavish, 2-44 Peter Taylor, 3-208 Marko Fedojuk'], ['1-16 Tyler Clayton, 2-60 Andrew Basedow, 3-93 Adam Basedow']], 'extras': [{'wd': 2, 'nb': 2, 'lb': 0, 'b': 2, 'p': 0}, {'wd': 8, 'nb': 4, 'lb': 3, 'b': 4, 'p': 0}, {'wd': 11,
        'nb': 1, 'lb': 1, 'b': 0, 'p': 0}, {'wd': 0, 'nb': 0, 'lb': 0, 'b': 0, 'p': 0}], 'overs': ['47', '30', '35'], 'venue': 'Park 21 / Park 21 - North Eastern Oval', 'opponent': 'Mitchell Park V', 'winner': 'Adelaide Lutheran II', 'result': 'W1', 'captain': 'Marko Fedojuk', 'game_dir': 'data/24-25/Section 9 Hopkins McGowran Cup/Rnd_3'}
    match_info['wicketkeeper'] = 'Frank Biedermann' 
    match_info['wicketkeeper'] = 'Parth Gohil'
    match_info['wicketkeeper'] = 'Brett MacTavish'
    match_info['captain'] = 'Jim Wills'
    match_info['captain'] = 'Finley Borgas'
    match_info['fow_list'] = [['1-2 Jim Wills, 2-91 Joshua Waldhuter, 3-122 Christopher Mann, 4-144 Joshua Fitzsimmons, 5-143 David Fitzsimmons, 6-150 Frank Biedermann, 7-158 Matthew Bell, 8-158 Jamie Ladlow'],[]]
    match_info['extras'] = [{'wd': 11, 'nb': 2, 'lb': 0, 'b': 5, 'p': 0}, {'wd': 6, 'nb': 11, 'lb': 0, 'b': 0, 'p': 0}]
    match_info['result'] = 'D'
    match_info['innings_list'] = ['Adelaide Lutheran','PHA']
    match_info['date_day_1'] = '13 Oct 2019'

# Check for missing/not recognised players
# Unknown PlayerX
# !!! add any new players
util.check_player_ids(match_info)

if False:
    newplayer=util.check_player_ids(match_info)[0]
    fname=newplayer.split()[0]
    lname=newplayer.split()[1]
    util.add_new_player(fname,lname)

    util.add_new_player('Takdir Singh','Sahota')



# !!! Validate:
# all playerids are there
# bowling: assists have playerids where applicable
# batting: FOW looks correct
wd.wrangle_match_data(match_info, write_to_postgres = False)

# wrangle data and export
if False:
    # !!! run this after validating
    wd.wrangle_match_data(match_info, write_to_postgres = True)

