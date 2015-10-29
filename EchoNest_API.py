__author__ = 'jason'

import urllib.request
import json
import pandas as pd
import time


def get_factors(Artist, Recording):
        songid_url = 'http://developer.echonest.com/api/v4/song/search?api_key=QOEISO4ZCNSPLKQOQ&artist=' \
                      + Artist + '&title=' + Recording + '&bucket=audio_summary'
        songid_dict = json.loads(bytes.decode(urllib.request.urlopen(songid_url).read()))
        song_id = songid_dict['response']['songs'][0]['audio_summary']

        return(song_id)

unique = pd.read_csv('unique_artists_songs.csv', encoding='utf-8')
unique['oneartist'] = unique['oneartist'].map(lambda x: x.replace(' ', '+'))
unique['Recording1'] = unique['Recording1'].map(lambda x: x.replace(' ', '+'))

#print(unique.head(10))
attr = []
for i in range(0, 40, 20):
    for i in unique[i:i+20].index:
        try:
            attr.append(get_factors(unique.ix[i].oneartist, unique.ix[i].Recording1))
        except IndexError:
            attr.append('could_not_find')
        except UnicodeEncodeError:
            attr.append('unicode_error')
        else:
            continue
    time.sleep(61)
#print(get_factors(unique.ix[19].oneartist, unique.ix[19].Recording1))

#print(int(unique.ix[4].pos))
print(attr[1])
#print(unique[5:7].index)
