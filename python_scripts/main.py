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

# Junior
# match_info=wd.load_match_info(year='24-25', grade='WSJCA - U12 - Red', round='Rnd_4', data_dir='data')
match_info=wd.load_match_info(year='26-27', grade='U10 Gold (Older Kids) - Red', round='Rnd_4', data_dir='data')
match_info=wd.load_match_info(year='26-27', grade='U10 Gold (Older Kids) - Royal', round='Rnd_4', data_dir='data')
match_info=wd.load_match_info(year='26-27', grade='U10 Green (Younger Kids) - White', round='Rnd_4', data_dir='data')
match_info=wd.load_match_info(year='26-27', grade='U12 Division 2', round='Rnd_4', data_dir='data')
match_info=wd.load_match_info(year='26-27', grade='Western Suburbs - U10 Sunday - Blue', round='Rnd_3', data_dir='data')
match_info=wd.load_match_info(year='26-27', grade='Western Suburbs - U12 Division 2 - Blue', round='Rnd_4', data_dir='data')
match_info=wd.load_match_info(year='26-27', grade='Western Suburbs - U14', round='Rnd_5', data_dir='data')




# Senior
# match_info=wd.load_match_info(year='26-27', grade='Section 3 Cup', round='Rnd_3', data_dir='data')
# match_info=wd.load_match_info(year='26-27', grade='Section 8 Claim this Cup', round='Rnd_3', data_dir='data')

if False:
    match_info['wicketkeeper'] = 'Peter Taylor'
    match_info['wicketkeeper'] = 'Brett MacTavish'

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
# batting: FOW looks correct - check for fill-ins in FOW
wd.wrangle_match_data(match_info, write_to_postgres = False)

# wrangle data and export
if False:
    # !!! run this after validating
    wd.wrangle_match_data(match_info, write_to_postgres = True)












# directory='data/22-23/U10 - White'

# # wd.wrangle_match_data_bulk(directory, write_to_postgres=False)

# for md_file in pathlib.Path(directory).rglob('match_info.md'):
#     # match_info = load_match_info_from_md(md_file)
#     print(md_file)
#     match_info=wd.load_match_info_from_md(md_file)


# fillin_matches=wd.find_matches_with_fillins(directory='data')

# for i in fillin_matches:
#     print(i)
