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

t1 = soup.find("div", {"class": "sc-jrsJCI glcFNO"})

scorecard = body.find("div", {"class": "sc-jrsJCI fFicEV"})

t1 = scorecard.find("div", {"class": "c5jfdg-0 fEQKQo"})



# can only get 1st innings batting team like this. can't access 2nd innings yet...
battingTeamName = t1.find("span", {"class": "sc-jrsJCI ktPSBm"}).get_text()







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







url = 'https://www.playhq.com/cricket-australia/org/adelaide-turf-cricket-association/mens-senior-competitions-summer-202223/senior-men-isc-teamwear-lo-division-1/game-centre/bd01fb60'

req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})

source = urllib.request.urlopen(req).read()

soup = bs.BeautifulSoup(source,'xml')

# title of the page
print(soup.title)

# get attributes:
print(soup.title.name)

# get values:
print(soup.title.string)

# beginning navigation:
print(soup.title.parent.name)

# getting specific values:
print(soup.p)

print(soup.find_all('p'))

for paragraph in soup.find_all('p'):
    print(paragraph.string)
    print(str(paragraph.text))

for url in soup.find_all('a'):
    print(url.get('href'))

print(soup.get_text())




body = soup.find('body')

body.find('div')


scorecard = body.find("div", {"class": "sc-jrsJCI fFicEV"})

t1 = scorecard.find("div", {"class": "c5jfdg-0 fEQKQo"})

# can only get 1st innings batting team like this. can't access 2nd innings yet...
battingTeamName = t1.find("span", {"class": "sc-jrsJCI ktPSBm"}).get_text()







