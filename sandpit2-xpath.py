from bs4 import BeautifulSoup
import lxml

f = open('scorecard1.html','r')

soup = BeautifulSoup(f.read(), 'lxml')

print(soup.head)



dom = lxml.etree.HTML(str(soup))

# FOW:
print(dom.xpath('//*[@id="root"]/section/main/div/div/div[1]/section/section[2]/div[3]/div[4]/div[2]/div/span[2]/text()'))

# get batting scorecard
scorecard = dom.xpath('')
