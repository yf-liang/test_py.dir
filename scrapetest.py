
##### will ONLY work with:    workon maze_run

import datetime
import getpass
import random
import re
import sys
import types

from urllib.request import urlopen
from urllib.error import HTTPError
from urllib.error import URLError

# import bs4
from bs4 import BeautifulSoup
import requests

# html = urlopen('http://pythonscraping.com/pages/page1.html')
# print(html.read())

# ---------------------------------------------------------------------
def getTitle(url):
    try:
        html = urlopen(url)
    except URLError as e:
        # print('The server could not be found!')
        return None

    except HTTPError as e:
        return None
    try:
        bs = BeautifulSoup(html.read(), 'html.parser')
        title = bs.body.h1
    except AttributeError as e:
        return None
    return title

# ---------------------------------------------------------------------
# for test25
random.seed(datetime.datetime.now())
def getLinks(articleUrl):
    html = urlopen('http://en.wikipedia.org{}'.format(articleUrl))
    bs = BeautifulSoup(html, 'html.parser')
    return bs.find('div', {'id':'bodyContent'}).find_all('a',
         href=re.compile('^(/wiki/)((?!:).)*$'))

# ---------------------------------------------------------------------
# for test26
pages = set()
def getLinks(pageUrl):
    global pages
    html = urlopen('http://en.wikipedia.org{}'.format(pageUrl))
    bs = BeautifulSoup(html, 'html.parser')

    try:
        print(bs.h1.get_text())
        print(bs.find(id ='mw-content-text').find_all('p')[0])
        print(bs.find(id='ca-edit').find('span')
             .find('a').attrs['href'])
    except AttributeError:
        print('This page is missing something! Continuing...')

    for link in bs.find_all('a', href=re.compile('^(/wiki/)')):
        if 'href' in link.attrs:
            if link.attrs['href'] not in pages:
                #We have encountered a new page
                newPage = link.attrs['href']
                print('-'*20)
                print(newPage)
                pages.add(newPage)
                getLinks(newPage)

# ---------------------------------------------------------------------


# html = urlopen('http://www.pythonscraping.com/pages/page1.html')
# bad page
# html = urlopen('http://www.pythonscraping.com/pages/pagexx1.html')
# bad url
# html = urlopen('http://www.pythonscrapingxx.com/pages/page1.html')

# ---------- main ----------
nparms = len( sys.argv )
if nparms <= 1:
   # help()
   sys.exit()

if sys.argv[1] == "test1":
   print ("test1")
   sys.exit()

# ---------------------------------------------------------------------
if sys.argv[1] == "test2":

   # title = getTitle('http://www.pythonscrapingxx.com/pages/page1.html')
   # title = getTitle('http://www.pythonscraping.com/pages/page1xx.html')
   title = getTitle('http://www.pythonscraping.com/pages/page1.html')
   if title == None:
      print('Title could not be found')
   else:
      print(title)

   sys.exit()


# ---------------------------------------------------------------------
if sys.argv[1] == "testxx":
   print ("hello")
   sys.exit()

# ---------------------------------------------------------------------
# 
if sys.argv[1] == "test28":
   html = urlopen('http://en.wikipedia.org/wiki/Python_(programming_language)')
   bs = BeautifulSoup(html, 'html.parser')
   content = bs.find('div', {'id':'mw-content-text'}).get_text()
   print ( ":" + str(len(content)) + ": " + content[1:70] + " :")

   content = re.sub('\n|[[\d+\]]', ' ', content)
   print ( ":" + str(len(content)) + ": " + content[1:70] + " :")

   content = bytes(content, 'UTF-8')
   content = content.decode('ascii', 'ignore')
   print ( ":" + str(len(content)) + ": " + content[1:70] + " :")


   # ngrams = getNgrams(content, 2)
   # print(ngrams)
   # print('2-grams count is: '+str(len(ngrams)))
   sys.exit()

# ---------------------------------------------------------------------
if sys.argv[1] == "test27":
   # how to act like human

   session = requests.Session()
   headers = {'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5)'
           'AppleWebKit 537.36 (KHTML, like Gecko) Chrome',
           'Accept':'text/html,application/xhtml+xml,application/xml;'
           'q=0.9,image/webp,*/*;q=0.8'}
   url = 'https://www.whatismybrowser.com/'\
       'developers/what-http-headers-is-my-browser-sending'
   req = session.get(url, headers=headers)

   bs = BeautifulSoup(req.text, 'html.parser')
   print(bs.find('table', {'class':'table-striped'}).get_text)

   sys.exit()

# ---------------------------------------------------------------------
if sys.argv[1] == "test26":
   getLinks('')
   sys.exit()

# ---------------------------------------------------------------------
if sys.argv[1] == "test241":
   # nb = raw_input ('Press ENTER....')
   nb = input ('Enter number> ')
   try:
      mode = int(nb)
   except ValueError:
      print ("Not a number.")

   pswd = getpass.getpass ('Enter password> ')
   print (':' + pswd + ':')
   sys.exit()

# ---------------------------------------------------------------------
if sys.argv[1] == "test24":
   html = urlopen('http://en.wikipedia.org/wiki/Kevin_Bacon')
   bs = BeautifulSoup(html, 'html.parser')
   for link in bs.find('div', {'id':'bodyContent'}).find_all(
       'a', href=re.compile('^(/wiki/)((?!:).)*$')):
       if 'href' in link.attrs:
          print(link.attrs['href'])
   sys.exit()

# ---------------------------------------------------------------------
if sys.argv[1] == "test25":
   links = getLinks('/wiki/Kevin_Bacon')
   while len(links) > 0:
       newArticle = links[random.randint(0, len(links)-1)].attrs['href']
       print(newArticle)
       links = getLinks(newArticle)
   sys.exit()

# ---------------------------------------------------------------------
if sys.argv[1] == "test23":
   html = urlopen('http://www.pythonscraping.com/pages/page3.html')
   bs = BeautifulSoup(html, 'html.parser')
   images = bs.find_all('img',
       {'src':re.compile('\.\.\/img\/gifts/img.*\.jpg')})
   for image in images: 
       print(image['src'])
   sys.exit()

# ---------------------------------------------------------------------
if sys.argv[1] == "test21":
   res = requests.get('http://inventwithpython.com/page_that_does_not_exist')
   try:
       res.raise_for_status()
   except Exception as exc:
       print('There was a problem: %s' % (exc))
   sys.exit()

# ---------------------------------------------------------------------
# write in binary 'wb' to preserve unicode
if sys.argv[1] == "test22":
   res = requests.get('http://www.gutenberg.org/cache/epub/1112/pg1112.txt')
   res.raise_for_status()
   playFile = open('RomeoAndJuliet.txt', 'wb')
   for chunk in res.iter_content(100000):
       playFile.write(chunk)

   playFile.close()
   sys.exit()


# ---------------------------------------------------------------------
# exit so nothing below will be executed
sys.exit()

# ---------------------------------------------------------------------

# extras
try:
    sys.exit()
    # something
except HTTPError as e:
    print(e)
    sys.exit()
    # return null, break, or do some other "Plan B"

except URLError as e:
    print('The server could not be found!')
    sys.exit()

else:
    # program continues. Note: If you return or break in the  
    # exception catch, you do not need to use the "else" statement
    bs = BeautifulSoup(html.read(), 'html.parser')
    print(bs.h1)

