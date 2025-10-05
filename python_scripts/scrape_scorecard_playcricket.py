from bs4 import BeautifulSoup
import urllib.request
import pandas as pd
import time
import re
from selenium import webdriver
from selenium.webdriver.common.by import By
import lxml
from pathlib import Path
import os

# url = "https://play.cricket.com.au/match/befc8418-e18e-42cc-a840-1073d8f99035/adelaide-junior-bulldogs-phantoms-cricket-blue-wsjca-under-10-pool-a?tab=scorecard"

def scrape_scorecard_playcricket(url, overwrite_md=False):
    """
    Takes a url for a playhq scorecard and returns scraped data
    overwrite_md=False will only write md files if they don't exist
    """
    # go to web page
    driver = webdriver.Firefox()
    driver.maximize_window()
    time.sleep(2) # wait for firefox to open
    driver.get(url)

    page_source = driver.page_source
    soup_tmp = BeautifulSoup(page_source, 'lxml')
    soup_str = soup_tmp.prettify().replace('::before','').replace('::after','')
    soup = BeautifulSoup(soup_str, 'lxml')

    dom = lxml.etree.HTML(str(soup))

        #########################################################################################################################
        # setup
        #########################################################################################################################
        # default values

    # if toss info is missing then structure is different:
    #             /html/body/div/section/main/div/div/div[1]/section/section[2]/div[2]/div[1]/span[1]
    # if dom.xpath('/html/body/div/section/main/div/div/div[1]/section/section[2]/div[2]/div[1]/span[1]/text()')[0]=='Toss':
    #     div_a = 4
    # else: 
    #     div_a = 3
    # Somtimes this is in there
    # try:
    #     if dom.xpath('/html/body/div/section/main/div/div/div[1]/section/section[1]/div[1]/span[1]/text()')[0] == 'Stumps':
    #         div_b = 3
    #     else:
    #         div_b = 2
    # except:
    #     div_b = 2

        #########################################################################################################################
        # Match info
        #########################################################################################################################

    # !!! need to go to summary tab
    time.sleep(2)
    summary_button = driver.find_element(By.XPATH,f'//*[@id="tab-summary"]')

    summary_button.click()
    time.sleep(1)
    page_source = driver.page_source
    soup_tmp = BeautifulSoup(page_source, 'lxml')
    soup_str = soup_tmp.prettify().replace('::before','').replace('::after','')
    soup = BeautifulSoup(soup_str, 'lxml')
    dom = lxml.etree.HTML(str(soup))

    head = dom.xpath('/html/body/main/section/header/div')[0]
    mi_grade = re.sub(':','',head.xpath('//nav/ol/li[1]/a/span/text()')[0].strip())
    mi_round = head.xpath('//nav/ol/li[2]/a/span/text()')[0].strip()

    if 'Round' in mi_round:
        mi_round = re.split('Round ',mi_round)[1]
    # elif 'Semi Finals' in re.split(', ',text1)[1]: 
    #     mi_round = 'SF'
    # elif 'Grand Final' in re.split(', ',text1)[1]: 
    #     mi_round = 'GF'
    else:
        raise Exception(f"Unknown Round number: {mi_round}")


    tmp_days = dom.xpath('/html/body/main/section/div[4]/div/div/div[2]/section/div/article[1]/ul/li[1]/p/text()')[0].strip()
    if tmp_days == 'One Day':
        mi_num_days = 1
    elif tmp_days == 'Two Day+':
        mi_num_days = 2
    else:
        raise Exception(f"Unknown Number of Days: {tmp_days}")

    tmp_date = dom.xpath('/html/body/main/section/div[4]/div/div/div[2]/section/div/article[1]/ul/li[4]/p/span/text()')[0].strip()
                                    
    mi_date_day_1 = re.sub(r'.*?(\d{1,2}\s\w+\s\d{4}).*',r'\1',tmp_date)

    if (re.split(' ',mi_date_day_1)[1] in ['Sep','Oct','Nov','Dec']):
        mi_season = f"{int(re.split(' ',mi_date_day_1)[2])-2000}-{int(re.split(' ',mi_date_day_1)[2])-1999}"
    else:
        mi_season = f"{int(re.split(' ',mi_date_day_1)[2])-2001}-{int(re.split(' ',mi_date_day_1)[2])-2000}"

    #                     /html/body/main/section/div[4]/div/div/div[2]/section/div/article[1]/ul/li[3]
    if len(dom.xpath('/html/body/main/section/div[4]/div/div/div[2]/section/div/article[1]/ul/li[3]/p/a/span/text()')) > 0:
        mi_venue = dom.xpath('/html/body/main/section/div[4]/div/div/div[2]/section/div/article[1]/ul/li[3]/p/a/span/text()')[0].strip()
    else:
        mi_venue = 'unknown'


    # opponent
    mi_team_1 = head.xpath('/html/body/main/section/header/div/div/div[2]/div[1]/div[3]/text()')[0].strip()
    mi_team_2 = head.xpath('/html/body/main/section/header/div/div/div[2]/div[3]/div[3]/text()')[0].strip()
    if 'Adelaide Junior Bulldogs' in mi_team_1:
        opponent = mi_team_2
    else:
        opponent = mi_team_1


    # result

    tmp_result = dom.xpath('/html/body/main/section/header/div/div/div[4]/span/text()')[0].strip()
    if 'Adelaide Junior Bulldogs' in tmp_result:
        mi_winner = 'Adelaide Lutheran'
    elif opponent in tmp_result:
        mi_winner = opponent
    else:
        mi_winner = "draw"

    if 'Adelaide Lutheran' in mi_winner:
        mi_result = 'W1'
    elif mi_winner == "draw":
        mi_result = 'D'
    else:
        mi_result = 'L1'


    #########################################################################################################################
    # Create directories for markdown tables
    #########################################################################################################################
    # navigate to scorecard
    scorecard_button = driver.find_element(By.XPATH,f'/html/body/main/section/div[4]/div/div/div[1]/div/div/ul/li[1]/button')

    scorecard_button.click()
    time.sleep(1)
    page_source = driver.page_source
    soup_tmp = BeautifulSoup(page_source, 'lxml')
    soup_str = soup_tmp.prettify().replace('::before','').replace('::after','')
    soup = BeautifulSoup(soup_str, 'lxml')
    dom = lxml.etree.HTML(str(soup))


    tmp_bat_1 = dom.xpath('/html/body/main/section/div[4]/div/div/div[2]/section/div[1]/div/div[2]/div/fieldset/div[1]/label/span[1]/text()')[0].strip()

    game_dir = f'data/{mi_season}/{mi_grade}/Rnd_{mi_round}'
    Path(game_dir).mkdir(parents=True, exist_ok=True)

    num_innings = len(dom.xpath('/html/body/main/section/div[4]/div/div/div[2]/section/div[1]/div/div[2]/div/fieldset/*'))
    num_innings_played = num_innings
    innings = []
    extras = []
    overs = []
    fow = []

    for ii in range(1,num_innings+1):
        print(f'Innings no.{ii}')
        ###
        # Check if innings played
        ###
        # check if innings was played - path to first batter name in scorecard
        if len(dom.xpath(f'/html/body/main/section/div[4]/div/div/div[2]/section/div[2]/div[1]/table/tbody/tr[1]/td[1]/a/text()')) == 0:
            print(f'innings {ii} not played.')
            num_innings_played-=1 
            break
        # get batting scorecard - ignore strike rate from playhq
        scorecard=dom.xpath(f'/html/body/main/section/div[4]/div/div/div[2]/section/div[2]/div[1]/table')[0]
        # -1 because extras included
        num_players = len(scorecard.xpath(f'tbody/*'))-1
        # check > 0 overs bowled
        # if re.sub('([\d\.]+) Overs','\\1',dom.xpath('/html/body/main/section/div[4]/div/div/div[2]/section/div[2]/div[1]/table/tfoot/tr/td[2]/span[1]/text()')[0].strip()) == '0' \
        #     and ii not in (1,2):
        #     print(f'innings {ii} not played..')
        #     num_innings_played-=1 
        # else:
        
        if dom.xpath(f'/html/body/main/section/div[4]/div/div/div[2]/section/div[1]/div/div[2]/div/fieldset/div[{ii}]/label/span[1]/text()')[0].strip() == 'ADE':
            innings.append('Adelaide Lutheran')
        else:
            innings.append(dom.xpath(f'/html/body/main/section/div[4]/div/div/div[2]/section/div[1]/div/div[2]/div/fieldset/div[{ii}]/label/span[1]/text()')[0].strip())
        #########################################################################################################################
        # Batting Scorecard
        #########################################################################################################################
        # only need to do batting for Adelaide Lutheran batting innings
        # if 'Adelaide Lutheran' in innings[ii-1]:

        batting_df = pd.read_html(lxml.etree.tostring(scorecard, method='html').decode('utf-8'))[0]
        batting_df.columns = ['batter','how_out','score','balls_faced','_4s','_6s','sr']
        extras_str = batting_df.iloc[num_players,0]

        batting_df = batting_df.iloc[0:num_players,:].drop('sr', axis=1)
        batting_df['batter'] = batting_df['batter'].apply(lambda x: re.sub(r'(\s{2}.*|(retired )?not out.*|did not bat)','',x))
        batting_df['score']  = batting_df['score'].apply(lambda x: re.sub(r'\*','',str(x)))
        batting_df['score']  = batting_df['score'].apply(lambda x: re.sub('(\\-|nan)','0',str(x)))
        batting_df['balls_faced']  = batting_df['balls_faced'].apply(lambda x: re.sub('nan','0',str(x)))
        batting_df['_4s']  = batting_df['_4s'].apply(lambda x: re.sub('nan','0',str(x)))
        batting_df['_6s']  = batting_df['_6s'].apply(lambda x: re.sub('nan','0',str(x)))


        # Extras
        if re.match(r'.*?(\d+)Wd.*',extras_str): extras_wd = int(re.sub(r'.*?(\d+)Wd.*',r'\1',extras_str))
        else: extras_wd = 0
        if re.match(r'.*?(\d+)NB.*',extras_str): extras_nb = int(re.sub(r'.*?(\d+)NB.*',r'\1',extras_str))
        else: extras_nb = 0
        if re.match(r'.*?(\d+)LB.*',extras_str): extras_lb = int(re.sub(r'.*?(\d+)LB.*',r'\1',extras_str))
        else: extras_lb = 0
        if re.match(r'.*?(\d+)B.*',extras_str): extras_b = int(re.sub(r'.*?(\d+)B.*',r'\1',extras_str))
        else: extras_b = 0
        if re.match(r'.*?(\d+)PR.*',extras_str): extras_pr = int(re.sub(r'.*?(\d+)PR.*',r'\1',extras_str))
        else: extras_pr = 0

        extras.append({'wd' : extras_wd,
            'nb' : extras_nb,
            'lb' : extras_lb,
            'b' : extras_b,
            'p' : extras_pr
        })

        # Overs
        overs.append(re.sub(r'([\d\.]+) Overs',r'\1',scorecard.xpath('tfoot/tr/td[2]/span/text()')[0].strip()))

        # Write scorecard to file
        if overwrite_md or not os.path.exists(f'{game_dir}/innings_{ii}_batting.md'):
            sc = batting_df.to_markdown()
            f=open(f'{game_dir}/innings_{ii}_batting.md','w')
            f.write(sc)
            f.close()

        #########################################################################################################################
        # Bowling Scorecard
        #########################################################################################################################
        # only need to do bowling for opposition batting innings
        if 'Adelaide Lutheran' not in innings[ii-1]:
            # only run if our bowling is entered (check first bowler exists)
            if len(dom.xpath(f'/html/body/main/section/div[4]/div/div/div[2]/section/div[2]/div[2]/table')) == 1:
                bowling_sc =      dom.xpath(f'/html/body/main/section/div[4]/div/div/div[2]/section/div[2]/div[2]/table')[0]
                bowling_df = pd.read_html(lxml.etree.tostring(bowling_sc, method='html').decode('utf-8'))[0]
                bowling_df.columns = ['bowler','overs','overs_hidden','maidens','runs','wickets','econ','wides','no_balls','dot_balls']
                bowling_df = bowling_df.loc[:,['bowler','overs','maidens','runs','wickets','wides','no_balls']]
                bowling_df.insert(loc=7, column='_4s_against', value=0)
                bowling_df.insert(loc=8, column='_6s_against', value=0)
                bowling_df.insert(loc=9, column='highover', value=0)
                bowling_df.insert(loc=10, column='_2nd_high_over', value=0)

            else:
                print('empty bowling scorecard')
                bowling_df = pd.DataFrame(columns=['bowler','overs','maidens','runs','wickets','wides','no_balls','_4s_against','_6s_against','highover','_2nd_high_over'])
                for i in range(1,7):
                    bowling_df.loc[i] = ['','','','','','','','','','','']
            # Write scorecard to file
            if overwrite_md or not os.path.exists(f'{game_dir}/innings_{ii}_bowling.md'):
                sc = bowling_df.to_markdown()
                f=open(f'{game_dir}/innings_{ii}_bowling.md','w')
                f.write(sc)
                f.close()

            # Fielding
            if len(dom.xpath(f'/html/body/main/section/div[4]/div/div/div[2]/section/div[2]/div[3]/table')) == 1:
                fielding_sc =      dom.xpath(f'/html/body/main/section/div[4]/div/div/div[2]/section/div[2]/div[3]/table')[0]
                fielding_df = pd.read_html(lxml.etree.tostring(fielding_sc, method='html').decode('utf-8'))[0]
                fielding_df.columns = ['player','catches','run_outs','stumpings']
                if overwrite_md or not os.path.exists(f'{game_dir}/innings_{ii}_fielding.md'):
                    sc = fielding_df.to_markdown()
                    f=open(f'{game_dir}/innings_{ii}_fielding.md','w')
                    f.write(sc)
                    f.close()
            else:
                print('empty fielding scorecard')


        #########################################################################################################################
        # Load Next Innings
        #########################################################################################################################
        if ii < num_innings:
            next_innings_button = driver.find_element(By.XPATH, f'/html/body/main/section/div[4]/div/div/div[2]/section/div[1]/div/div[2]/div/fieldset/div[2]')
            # scroll to button so it is in view and can be clicked
            # driver.execute_script("arguments[0].scrollIntoView(true);", next_innings_button)
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
        'date_day_2' 	: None,
        'num_innings' 	: num_innings_played,
        'innings_list'  : innings,
        'fow_list'      : fow,
        'extras'        : extras,
        'overs'         : overs,
        'venue' 		: mi_venue,
        'opponent' 		: opponent,
        'winner' 	    : mi_winner,
        'result'        : mi_result,
        'game_dir'		: game_dir
        }
    
    for ii in range(len(match_info['extras'])):
        if match_info['extras'][ii] == {'wd': 0, 'nb': 0, 'lb': 0, 'b': 0, 'p': 0}:
            print(f'Missing extras for innings {ii+1}')

    match_info_df = pd.DataFrame.from_dict(match_info,orient='index').to_markdown()

    # game_dir = "data/22-23/ISC Teamwear LO Division 1/Rnd_2"

    if overwrite_md or not os.path.exists(f'{game_dir}/match_info.md'):
        f=open(f'{game_dir}/match_info.md','w')
        f.write(match_info_df)
        f.close()

    return match_info

