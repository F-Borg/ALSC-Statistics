import pandas as pd
import re



def get_how_out(how_out_str):
        if re.search('c\&b:',how_out_str):
            return 'c & b'
        elif re.search('^c:',how_out_str):
            return 'caught'
        elif re.search('^b:',how_out_str):
            return 'bowled'
        elif re.search('did not bat',how_out_str):
            return 'DNB'
        elif re.search('not out',how_out_str):
            return 'Not Out'
        elif re.search('^lbw:',how_out_str):
            return 'LBW'
        elif re.search('run out',how_out_str):
            return 'Run Out'
        elif re.search('stumped',how_out_str):
            return 'Stumped'
        elif re.search('absent out',how_out_str):
            return 'Absent Out'
        elif re.search('retired hurt',how_out_str):
            return 'Retired Hurt'
        elif re.search('retired',how_out_str):
            return 'Retired'
        elif re.search('hit wicket',how_out_str):
            return 'Hit Wicket'
        else:
            raise Exception(f"Unknown dismissal method - batting posn {j+1}")

def name_FL_to_LFi(name):
    return re.sub('(\S)(\S+)\s?(\S)?(\S+)? (\S+)$','\\5, \\1\\3',name)

def how_out_bowler(how_out_str):
    if get_how_out(how_out_str) in ['caught','bowled','LBW','Stumped','c & b','Hit Wicket']:
        return re.sub('.*?(?:lbw|b): (\S)(\S+)\s?(\S)?(\S+)? (\S+)$','\\5, \\1\\3',how_out_str)
    else:
        return ''
    
def how_out_assist(how_out_str):
    if get_how_out(how_out_str) in ['caught','Stumped','c & b','Run Out']:
        return re.sub('.*?(?:c|stumped|run out|c\&b): (\S)(\S+)\s?(\S)?(\S+)? (\S+)$','\\5, \\1\\3',how_out_str)
    else:
        return ''
    

# def wrangle_match_data(match_info):
match_dir = match_info['game_dir']

# for i in range(1,match_info['num_innings']):
i=1
# if 'Adelaide Lutheran' in match_info['innings_list'][i-1]:
#########################################################################################################################
# Batting
#########################################################################################################################

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

batting['batting_posn'] = batting.reset_index().index + 1
batting['bowler_name'] = batting['how_out'].apply(how_out_FL_to_LFi)
batting['how_out2'] = batting['how_out'].apply(get_how_out)
batting['wicket'] = ''
batting['fow'] = ''
batting['not_out_batter'] = ''



    # match_info['fow']




# else: #bowling
i=2
#########################################################################################################################
# Bowling
#########################################################################################################################
bowling = pd.read_table(f'{match_dir}/innings_{i}_bowling.md', sep="|", header=0, index_col=1, skipinitialspace=True).dropna(axis=1, how='all').iloc[1:]
  # Read a markdown file, getting the header from the first row and inex from the second column
  #.read_table(f'{match_info['game_dir']}', sep="|", header=0, index_col=1, skipinitialspace=True)
  # Drop the left-most and right-most null columns 
  #.dropna(axis=1, how='all')
  # Drop the header underline row
  #.iloc[1:]   
# trim whitespace
bowling = bowling.applymap(lambda x: x.strip() if isinstance(x, str) else x)
bowling.columns = bowling.columns.str.strip()


bowling = bowling.applymap(lambda x: x.replace('-','0'))
bowling['bowler_name2'] = bowling['bowler'].apply(name_FL_to_LFi)


#########################################################################################################################
# Wickets
#########################################################################################################################
wickets = pd.read_table(f'{match_dir}/innings_{i}_batting.md', sep="|", header=0, index_col=1, skipinitialspace=True).dropna(axis=1, how='all').iloc[1:]
  # Read a markdown file, getting the header from the first row and inex from the second column
  #.read_table(f'{match_info['game_dir']}', sep="|", header=0, index_col=1, skipinitialspace=True)
  # Drop the left-most and right-most null columns 
  #.dropna(axis=1, how='all')
  # Drop the header underline row
  #.iloc[1:]   
# trim whitespace
wickets = wickets.applymap(lambda x: x.strip() if isinstance(x, str) else x)
wickets.columns = wickets.columns.str.strip()

wickets['batting_posn'] = wickets.reset_index().index + 1
wickets['bowler_name'] = wickets['how_out'].apply(how_out_bowler)
wickets['assist'] = wickets['how_out'].apply(how_out_assist)
wickets['how_out2'] = wickets['how_out'].apply(get_how_out)




