import bs4 as bs
import urllib.request
import pandas as pd
import time
import re
from selenium import webdriver
from selenium.webdriver.common.by import By

# def scrape_scorecard(url):
#     """
#     Takes a url for a playhq scorecard and returns scraped data
#     """

url = "https://www.playhq.com/cricket-australia/org/adelaide-turf-cricket-association/mens-senior-competitions-summer-202223/senior-men-isc-teamwear-lo-division-1/game-centre/bd01fb60"
# go to web page
driver = webdriver.Firefox()
time.sleep(10)
driver.get(url)


# First Innings
page_source = driver.page_source
soup = bs.BeautifulSoup(page_source, 'lxml')


# Match info
# DONE:
# opponent
# year
# round
# venue
# date day 1
#
#
#
#
# NOT DONE:
# date day 2, num days, grade, result, captain, wicketkeeper, bat or bowl first


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













# Scorecard #1
scorecard = soup.find("div", {"class": "c5jfdg-2 ihUGeK"})

# print(scorecard.prettify())


divs = scorecard.find_all('div',{"class": "sc-jrsJCI zcQYy sc-1x5e4rc-0 dSIIez"})

df1 = pd.DataFrame(columns=['batter','how_out','R','B','4s','6s','SR'])
for i in range(1,len(divs)-1):
    data=[]
    # spans = divs[i].find_all('span')#, recursive=False)
    # spans = divs[i].select('span:not(.sc-jrsJCI.GABnk.sc-1x5e4rc-0.dBWdOW span)')
    spans = divs[i].select('span:not(.sc-jrsJCI.hXclEb span)')
    for span in spans:
        # print(span.text)
        data.append(span.text)
    df1.loc[i-1] = data
    # print(div)








# https://selenium-python.readthedocs.io/locating-elements.html
# find_element(By.ID, "id")
# find_element(By.NAME, "name")
# find_element(By.XPATH, "xpath")
# find_element(By.LINK_TEXT, "link text")
# find_element(By.PARTIAL_LINK_TEXT, "partial link text")
# find_element(By.TAG_NAME, "tag name")
# find_element(By.CLASS_NAME, "class name")
# find_element(By.CSS_SELECTOR, "css selector")



# Second Innings
swap_innings_button = driver.find_element(By.XPATH, "//button[@class='sc-bqGHjH sc-986eu2-0 jVBevJ dPjHbr']")
swap_innings_button.click()

page_source = driver.page_source
soup = bs.BeautifulSoup(page_source, 'lxml')







driver.close()


