from bs4 import BeautifulSoup
import urllib.request
import pandas as pd
import time
import re
from selenium import webdriver
from selenium.webdriver.common.by import By
import lxml
from pathlib import Path

# url = "https://www.playhq.com/cricket-australia/org/adelaide-turf-cricket-association/mens-senior-competitions-summer-202223/senior-men-isc-teamwear-lo-division-1/game-centre/bd01fb60"
# url = "https://www.playhq.com/cricket-australia/org/adelaide-and-suburban-cricket-association/saturdays-summer-202223/section-6-blackwood-sound-cup/game-centre/5c055822"
# three innings game
# url = "https://www.playhq.com/cricket-australia/org/adelaide-and-suburban-cricket-association/saturdays-summer-202223/section-6-blackwood-sound-cup/game-centre/1d32ce30"

def scrape_scorecard(url):
    """
    Takes a url for a playhq scorecard and returns scraped data
    """
    # go to web page
    driver = webdriver.Firefox()
    driver.maximize_window()
    # !!! better way to do this?
    time.sleep(5) # wait for firefox to open
    driver.get(url)

    page_source = driver.page_source
    soup = BeautifulSoup(page_source, 'lxml')
    dom = lxml.etree.HTML(str(soup))

    # setup - default value
    mi_captain = 'ERROR'

    #########################################################################################################################
    # Match info
    #########################################################################################################################
    # NOT DONE:
    # wicketkeeper
    # draws and outright wins

    head = dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[1]')[0]
    # /html/body/div /section/main/div/div/div[1]/section/section[1]
    text1 = head.xpath('header/a/text()')[0]
    mi_grade = re.split(', ',text1)[0][2:]    
    
    if 'Round' in re.split(', ',text1)[1]:
        mi_round = re.split(', Round ',text1)[1]
    elif 'Finals Round 1' in re.split(', ',text1)[1]: 
        mi_round = 'SF'
    elif 'Finals Round 2' in re.split(', ',text1)[1]: 
        mi_round = 'GF'
    else:
        tmp = re.split(', ',text1)[1]
        raise Exception(f"Unknown Round number: {tmp}")
    
    if head.xpath('div[2]/span[1]/text()')[0] == 'One Day':
        mi_num_days = 1
    elif head.xpath('div[2]/span[1]/text()')[0] == 'Two Day+':
        mi_num_days = 2
    else:
        tmp = head.xpath('div[2]/span[1]/text()')[0]
        raise Exception(f"Unknown Number of Days: {tmp}")

    mi_date_day_1 = re.split(', ',head.xpath('div[2]/span[2]/div/span[1]/text()')[0])[2] 
    if len(head.xpath('div[2]/span[2]/div/span[2]/text()')) == 0:
        mi_date_day_2 = ''
    else:
        mi_date_day_2 = re.split(', ',head.xpath('div[2]/span[2]/div/span[2]/text()')[0])[2] 

    if (re.split(' ',mi_date_day_1)[1] in ['Sep','Oct','Nov','Dec']):
        mi_season = f"{int(re.split(' ',mi_date_day_1)[2])-2000}-{int(re.split(' ',mi_date_day_1)[2])-1999}"
    else:
        mi_season = f"{int(re.split(' ',mi_date_day_1)[2])-2001}-{int(re.split(' ',mi_date_day_1)[2])-2000}"

    mi_venue = head.xpath('div[2]/span[3]/span/a/text()')[0]

    # opponent
    mi_team_1 = head.xpath('div[1]/div[1]/div/a/text()')[0]
    mi_team_2 = head.xpath('div[1]/div[2]/div/a/text()')[0]
    if 'Adelaide Lutheran' in mi_team_1:
        opponent = mi_team_2
    else:
        opponent = mi_team_1

    # result - greyed out one is the loser
    # !!! draws?
    # team2 = head.xpath('div[1]/span[2]/span/div/span[2]/@color')
    team1 = head.xpath('div[1]/span[1]/span/div/span[2]/@color')[0]
    if team1 == 'black400':
        mi_winner = mi_team_1
    else:
        mi_winner = mi_team_2


    #########################################################################################################################
    # Create directories for markdown tables
    #########################################################################################################################
    game_dir = f'data/{mi_season}/{mi_grade}/Rnd_{mi_round}'
    Path(game_dir).mkdir(parents=True, exist_ok=True)

    num_innings = len(dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[3]/*'))
    innings = []
    for ii in range(1,num_innings+1):
        # check if innings was played
        if len(dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[4]/div[2]/div[2]/div/div[2]/span[1]/text()')) == 0:
            print(f'innings {ii} not played.')
            break
        innings.append(dom.xpath(f'//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[3]/button[{ii}]/text()')[0])
        #########################################################################################################################
        # Batting Scorecard
        #########################################################################################################################
        # -3 because column names, extras, and total are all divs
        num_players = len(dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[4]/div[1]/div[2]/div/*'))-3
        # get batting scorecard - ignore strike rate from playhq
        scorecard=dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[4]/div[1]/div[2]/div/*')
        batting_df = pd.DataFrame(columns=['batter','how_out','R','B','4s','6s'])
        for i in range(1,num_players+1):
            # initiate row
            data=[]
            # name 
            data.append(scorecard[i].xpath('div/span[1]/text()')[0])
            # how out
            if len(scorecard[i].xpath('div/span[2]/span/text()'))>0: 
                how_out = scorecard[i].xpath('div/span[2]/span/text()')
            elif len(scorecard[i].xpath('div/span[2]/div/span[1]/text()'))>0: 
                how_out = [scorecard[i].xpath('div/span[2]/div/span[1]/text()')[0] + ' ' + scorecard[i].xpath('div/span[2]/div/span[2]/text()')[0]]
            elif len(scorecard[i].xpath('div/span[2]/text()'))>0:
                how_out = scorecard[i].xpath('div/span[2]/text()')
            else:
                how_out = ['did not bat']
            data.append(how_out[0])
            # batter 1 runs, bf, 4s, 6s
            data.append(scorecard[i].xpath('span[1]/text()')[0])
            data.append(scorecard[i].xpath('span[2]/text()')[0])
            data.append(scorecard[i].xpath('span[3]/text()')[0])
            data.append(scorecard[i].xpath('span[4]/text()')[0])
            batting_df.loc[i-1] = data

            if '(c)' in data[0] & 'Adelaide Lutheran' in innings[ii-1]:
                mi_captain = data[0].replace(' (c)','')

        # FOW
        # fow = dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[4]/div[2]/div/span[2]/text()')
        # Extras
        
        # Write scorecard to file
        sc = batting_df.to_markdown()
        f=open(f'{game_dir}/innings_{ii}_batting.md','w')
        f.write(sc)
        f.close()
        # temp = pd.read_table('data/test1.md', sep="|", header=0, index_col=1, skipinitialspace=True).dropna(axis=1, how='all').iloc[1:]
        #########################################################################################################################
        # Bowling Scorecard
        #########################################################################################################################
        # need to add 4's and 6's manually
        num_bowlers = len(dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[4]/div[2]/div[2]/div/*'))-1 # -1 for the heading row
        bowling_sc = dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[4]/div[2]/div[2]/div/*')
        bowling_df = pd.DataFrame(columns=['bowler','O','M','R','W','Wd','Nb','_4s','_6s','high_over','high_over_2'])
        for i in range(1,num_bowlers+1):
            # initiate row
            data=[]
            data.append(bowling_sc[i].xpath('span[1]/text()')[0])
            data.append(bowling_sc[i].xpath('span[2]/text()')[0])
            data.append(bowling_sc[i].xpath('span[3]/text()')[0])
            data.append(bowling_sc[i].xpath('span[4]/text()')[0])
            data.append(bowling_sc[i].xpath('span[5]/text()')[0])
            data.append(bowling_sc[i].xpath('span[7]/text()')[0])
            data.append(bowling_sc[i].xpath('span[8]/text()')[0])
            data.append(0) #4s
            data.append(0) #6s
            data.append(0) #High Over
            data.append(0) #2nd High Over
            bowling_df.loc[i-1] = data
        # Write scorecard to file
        sc = bowling_df.to_markdown()
        f=open(f'{game_dir}/innings_{ii}_bowling.md','w')
        f.write(sc)
        f.close()
        #########################################################################################################################
        # Load Next Innings
        #########################################################################################################################
        if ii < num_innings:
            next_innings_button = driver.find_element(By.XPATH, f'//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[3]/button[{ii+1}]')
            # scroll to button so it is in view and can be clicked
            driver.execute_script("arguments[0].scrollIntoView(true);", next_innings_button)
            time.sleep(1)
            next_innings_button.click()
            time.sleep(1)
            page_source = driver.page_source
            soup = BeautifulSoup(page_source, 'lxml')
            dom = lxml.etree.HTML(str(soup))

    driver.close()

    match_info = {
        'season' 		: mi_season,
        'grade' 		: mi_grade,
        'round' 		: mi_round,
        'num_days' 		: mi_num_days,
        'date_day_1' 	: mi_date_day_1,
        'date_day_2' 	: mi_date_day_2,
        'num_innings' 	: num_innings,
        'innings_list'  : innings,
        'venue' 		: mi_venue,
        'opponent' 		: opponent,
        'winner' 	    : mi_winner,
        'captain'       : mi_captain,
        'game_dir'		: game_dir
        }

    return match_info
