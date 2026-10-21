import python_scripts.wrangle_match_data as wd
import python_scripts.utility as util
import pathlib

# reload when required after updates to code
import importlib
importlib.reload(wd)
importlib.reload(util)




# !!! check data/[yy-yy]/[grade]/[round]/ 
# add any missing info:
# batting: balls faced, boundaries
# make sure ALL players are listed in our batting innings
# bowling: boundaries, extras 


match_info=wd.load_match_info(year='24-25', grade='WSJCA - U12 - Red', round='Rnd_4', data_dir='data')

# Check for missing/not recognised players
util.check_player_ids(match_info)
# util.add_new_player('Daniyal','Syed')

if False:
    newplayer=util.check_player_ids(match_info)[0]
    fname=newplayer.split()[0]
    lname=newplayer.split()[1]
    util.add_new_player(fname,lname)

# !!! Validate:
# all player ids are there
# bowling: assists have playerids where applicable
# batting: FOW looks correct
wd.wrangle_match_data(match_info, write_to_postgres = False)

# wrangle data and export
if False:
    # !!! run this after validating
    wd.wrangle_match_data(match_info, write_to_postgres = True)












directory='data/22-23/U10 - White'

# wd.wrangle_match_data_bulk(directory, write_to_postgres=False)

for md_file in pathlib.Path(directory).rglob('match_info.md'):
    # match_info = load_match_info_from_md(md_file)
    print(md_file)
    match_info=wd.load_match_info_from_md(md_file)


fillin_matches=wd.find_matches_with_fillins(directory='data')

for i in fillin_matches:
    print(i)
