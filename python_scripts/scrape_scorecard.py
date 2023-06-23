from bs4 import BeautifulSoup
import urllib.request
import pandas as pd
import time
import re
from selenium import webdriver
from selenium.webdriver.common.by import By
import lxml

# def scrape_scorecard(url):
#     """
#     Takes a url for a playhq scorecard and returns scraped data
#     """

url = "https://www.playhq.com/cricket-australia/org/adelaide-turf-cricket-association/mens-senior-competitions-summer-202223/senior-men-isc-teamwear-lo-division-1/game-centre/bd01fb60"
# go to web page
driver = webdriver.Firefox()
time.sleep(10) # wait for firefox to open
driver.get(url)

page_source = driver.page_source
soup = BeautifulSoup(page_source, 'lxml')
dom = lxml.etree.HTML(str(soup))

####################################################################################
# Match info
####################################################################################
# NOT DONE:
# captain, wicketkeeper
# 2-day games

head = dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[1]')[0]
# /html/body/div /section/main/div/div/div[1]/section/section[1]
text1 = head.xpath('header/a/text()')[0]
mi_grade = re.split(', ',text1)[0][2:]
mi_round = re.split(', ',text1)[1]
mi_date = re.split(', ',head.xpath('div[2]/span[2]/div/span/text()')[0])[2] 
# !!! 2-day game?
# mi_date_day_1
# mi_date_day_2
# mi_num_days
mi_venue = head.xpath('div[2]/span[3]/span/a/text()')[0]

# opponent
mi_team_1 = head.xpath('div[1]/div[1]/div/a/text()')[0]
mi_team_2 = head.xpath('div[1]/div[2]/div/a/text()')[0]
if mi_team_1 == 'Adelaide Lutheran':
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


first_innings = dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[3]/button[1]/text()')[0]
mi_first_innings_team = re.split(' 1st Innings',first_innings)[0]

second_innings = dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[3]/button[2]/text()')[0]
mi_second_innings_team = re.split(' 1st Innings',second_innings)[0]

# third_innings
# fourth_innings



####################################################################################
# First Innings Scorecard
####################################################################################

# Get number of players
# -3 because column names, extras, and total are all divs
num_players = len(dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[4]/div[1]/div[2]/div/*'))-3

# get batting scorecard - ignore strike rate from playhq
scorecard=dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[4]/div[1]/div[2]/div/*')
scorecard_df = pd.DataFrame(columns=['batter','how_out','R','B','4s','6s'])
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
    scorecard_df.loc[i-1] = data


# FOW:
dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[4]/div[2]/div/span[2]/text()')






page_title = soup.title.text
# 'Kilburn v Adelaide Lutheran, Summer 2022/23, R2 - Game Centre | PlayHQ'
text1 = re.split(', ',page_title)
teams = re.split(' v ',text1[0])
if teams[0] == 'Adelaide Lutheran':
    opponent = teams[1]
else :
    opponent = teams[0]

year = re.split(' ',text1[1])[1]

round = re.split(' ',text1[2])[0]

venue = soup.find("a", {"class": "sc-bqGHjH sc-1swl5w-19 lnVPQZ eMQkmb"}).text
# 'Blair Athol Reserve / Blair Athol Reserve - Main Oval'

date_text = soup.find("span", {"class": "sc-bqGHjH cUXLAP"}).text
# '12:30 PM, Saturday, 22 Oct 2022'
date_day_1 = re.split(', ',date_text)[2]

grade_text = soup.find("a", {"class": "sc-1swl5w-2 FHMNq"}).text
# '< ISC Teamwear LO Division 1, Round 2'

toss_text = soup.find("span", {"class": "sc-jrsJCI gXUjpw"}).text
# 'Adelaide Lutheran won the toss and elected to bat'







# Second Innings
second_innings_button = driver.find_element(By.XPATH, '//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[3]/button[2]')
second_innings_button.click()









driver.close()


