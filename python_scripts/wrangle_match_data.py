import pandas as pd
import re


# def wrangle_match_data(match_info):
match_dir = match_info['game_dir']

# for i in range(1,match_info['num_innings']):
i=1
if 'Adelaide Lutheran' in match_info['innings_list'][i-1]:


batting = pd.read_table(f'{match_dir}/innings_{i}_batting.md', sep="|", header=0, index_col=1, skipinitialspace=True).dropna(axis=1, how='all').iloc[1:]
  # Read a markdown file, getting the header from the first row and inex from the second column
  #.read_table(f'{match_info['game_dir']}', sep="|", header=0, index_col=1, skipinitialspace=True)
  # Drop the left-most and right-most null columns 
  #.dropna(axis=1, how='all')
  # Drop the header underline row
  #.iloc[1:]   
# trim whitespace
batting = batting.applymap(lambda x: x.strip() if isinstance(x, str) else x)
batting.columns = batting.columns.str.strip()

batting['how_out2'] = ''
batting['batting_posn'] = ''
batting['wicket'] = ''
batting['fow'] = ''
batting['not_out_batter'] = ''


for j in range(0,len(batting)):
    if re.search('^c:',batting['how_out'][j]):
        batting['how_out2'][j] = 'caught'
    elif re.search('^b:',batting['how_out'][j]):
        batting['how_out2'][j] = 'bowled'
    elif re.search('did not bat',batting['how_out'][j]):
        batting['how_out2'][j] = 'DNB'
    elif re.search('not out',batting['how_out'][j]):
        batting['how_out2'][j] = 'Not Out'
    elif re.search('^lbw:',batting['how_out'][j]):
        batting['how_out2'][j] = 'LBW'
    elif re.search('run out',batting['how_out'][j]):
        batting['how_out2'][j] = 'Run Out'
    elif re.search('stumped',batting['how_out'][j]):
        batting['how_out2'][j] = 'Stumped'
    elif re.search('absent out',batting['how_out'][j]):
        batting['how_out2'][j] = 'Absent Out'
    elif re.search('retired hurt',batting['how_out'][j]):
        batting['how_out2'][j] = 'Retired Hurt'
    elif re.search('retired',batting['how_out'][j]):
        batting['how_out2'][j] = 'Retired'
    elif re.search('hit wicket',batting['how_out'][j]):
        batting['how_out2'][j] = 'Hit Wicket'
    else:
        raise Exception("Unknown dismissal method")

    batting['batting_posn'][j] = j+1

    # match_info['fow']


