__author__ = 'jason'

import urllib.request
import json
import pandas as pd
import time


def get_factors(Artist, Recording, i):
        songid_url = 'http://developer.echonest.com/api/v4/song/search?api_key=QOEISO4ZCNSPLKQOQ&artist=' \
                      + Artist + '&title=' + Recording + '&bucket=audio_summary'
        songid_dict = json.loads(bytes.decode(urllib.request.urlopen(songid_url).read()))
        song_id = songid_dict['response']['songs'][0]['audio_summary']
        song_id["index"] = i
        return(song_id)

unique = pd.read_csv('unique_artists_songs.csv', encoding='utf-8')
unique['oneartist'] = unique['oneartist'].map(lambda x: x.replace(' ', '+'))
unique['Recording1'] = unique['Recording1'].map(lambda x: x.replace(' ', '+'))

attr = []
for i in range(0, 500, 20):
    for j in unique[i:i+20].index:
        try:
            attr.append(get_factors(unique.ix[j].oneartist, unique.ix[j].Recording1, j))
        #except IndexError:
        #    continue
            #attr.append('could_not_find')
        #except UnicodeEncodeError:
        #    continue
            #attr.append('unicode_error')
        except:
            continue
        else:
            continue
    time.sleep(61)



a = pd.DataFrame(attr)

a.to_csv('song_attributes.csv')

