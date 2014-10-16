#!/usr/bin/env python
import sys
import twitter
import time
import re
import traceback
import httplib
from threading import Thread

args_total = len(sys.argv)
hashtag = 'KoinifyFun' if args_total < 2 else sys.argv[1]
print hashtag
reply = 'Welcome to Koinify!!!!!!!!!'

#Setting up Twitter API
api = twitter.Api(
 consumer_key='5Z4PO17fkpbGKBcetGlqIZhdz',
 consumer_secret='oG8uT8WR7YXwibTicEtfJofDKj0sH5ISmhu3FfSafHIIZABIKB',
 access_token_key='2556329058-bj5GRArrT32bE9sWAGOOvu54DarsKJekn7BJ8po',
 access_token_secret='TvPbAuFtEN4gKpYZbgmMLn0rDMUw3IYfGT2aPO6Nd1eeP'
 )

def printText(txt):
    lines = txt.split('\n')
    for line in lines:
        print line.strip()
 
def myfunc():
	x = 0;
	while True:
		search = api.GetSearch(term='#' + hashtag, result_type='recent', count=100, max_id='')
		for t in search:
			try:
                                text = t.text.encode('utf-8')
                                api.PostUpdate(status='@' + t.user.screen_name + ' ' + reply, in_reply_to_status_id=t.id)
                                poster = t.user.screen_name
                                print 'Tweeter:' + poster
                                print 'Tweet time:' + t.created_at
                                if len(t.hashtags) >= 2:
                                        koin = t.hashtags[1].text 
                                        print koin
                                        httpServ = httplib.HTTPConnection("10.15.2.16", 3000)
                                        httpServ.connect()
                                        httpServ.request('GET', '/api/reward.json?poster=' + poster + '&retweeter=&koin=' + koin)
                                        response = httpServ.getresponse()
                                        if response.status == httplib.OK:
                                                print "Output from request"
                                                printText (response.read())
                                        httpServ.close()
			except:
                                print traceback.format_exc()
		print "%x sleeping 10 sec from thread" %(x)
		x += 1
		time.sleep(10)

t = Thread(target=myfunc)
t.start()
