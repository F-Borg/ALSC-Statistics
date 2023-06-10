import bs4 as bs
import urllib.request
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By


# go to web page
driver = webdriver.Firefox()
driver.get("https://www.playhq.com/cricket-australia/org/adelaide-turf-cricket-association/mens-senior-competitions-summer-202223/senior-men-isc-teamwear-lo-division-1/game-centre/bd01fb60")


# First Innings
page_source = driver.page_source
soup = bs.BeautifulSoup(page_source, 'lxml')


table_MN = pd.read_html(body)

body = soup.find('body')


scorecard = soup.find("div", {"class": "sc-jrsJCI fFicEV"})

spans = scorecard.find_all('span')

for span in spans:
    print(span.text)



bodytable = pd.read_html(str(body))




scorecard = soup.find("div", {"class": "sc-jrsJCI fFicEV"})
scorecard2 = soup.find("div", {"class": "c5jfdg-2 ihUGeK"})

divs = scorecard2.find_all('div',{"class": "sc-jrsJCI zcQYy sc-1x5e4rc-0 dSIIez"})
spans = scorecard2.find_all('span')

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








