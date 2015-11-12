import urllib.request
import json
import pandas as pd
import time
import os
os.chdir("C:\\$avi\\UVA\\Fall\\6021LinReg\\FinalProject\\Billboard Data")

def get_factors(Artist, Recording, api_method, song_buckets,artist_buckets, i, n):
    for method in api_method:
        print(method)
        if method == 'song_search':
            for bucket in song_buckets:
                print(bucket)
                songid_url = 'http://developer.echonest.com/api/v4/song/search?api_key=QOEISO4ZCNSPLKQOQ&artist=' \
                            + Artist + '&title=' + Recording + '&bucket='+bucket
                print(songid_url)
                if n >= 20:
                    n = 1
                    time.sleep(61)
                print('>>>>'+str(n))
                try:
                    songid_dict = json.loads(bytes.decode(urllib.request.urlopen(songid_url).read()))
                except :
                    continue
                print(songid_dict)
                n = n + 1
                if bucket == 'audio_summary':
                    song_attr = songid_dict['response']['songs'][0][bucket]
                    artist_id = songid_dict['response']['songs'][0]['artist_id']
                    song_attr["index"] = i
                elif bucket == 'song_type':
                    song_attr[bucket] = songid_dict['response']['songs'][0]['song_type'][0]
                else :
                    songs = songid_dict['response']['songs']
                    for i in range(0,len(songs)-1):
                        try:
                            song_attr[bucket] = songid_dict['response']['songs'][i][bucket]
                        except:
                            continue
                        else:
                            break
        if method == 'artist':
            for bucket in artist_buckets:
                print(bucket)
                
                songid_url = 'http://developer.echonest.com/api/v4/artist/profile?api_key=QOEISO4ZCNSPLKQOQ&id=' \
                            + artist_id + '&bucket=' + bucket
                if n >= 20:
                    n = 1
                    time.sleep(61)
                print('>>>>'+str(n))
                songid_dict = json.loads(bytes.decode(urllib.request.urlopen(songid_url).read()))
                n = n + 1
                song_attr[bucket] = songid_dict['response']['artist']['genres'][1]['name']
    print(song_attr)
    return(song_attr,n)

unique = pd.read_csv('unique_artists_songs.csv', encoding='utf-8')
unique['oneartist'] = unique['oneartist'].map(lambda x: x.replace(' ', '+'))
unique['Recording1'] = unique['Recording1'].map(lambda x: x.replace(' ', '+'))

unique['Recording1']

api_method = ['song_search','artist']
song_buckets = ['audio_summary','artist_discovery','artist_discovery_rank','artist_familiarity','artist_familiarity_rank','artist_hotttnesss','artist_hotttnesss_rank','song_currency','song_currency_rank','song_discovery','song_discovery_rank','song_hotttnesss','song_hotttnesss_rank','song_type']
artist_buckets = ['genre']

attr = []
n=1

for j in unique.index:
    print(j)
    try:
        print(unique.ix[j].oneartist)
        print(unique.ix[j].Recording1)
        [songs,num] = get_factors(unique.ix[j].oneartist, unique.ix[j].Recording1, \
                                api_method, song_buckets,artist_buckets, j,n)
        n = num
        songs['Artist'] = unique.ix[j].oneartist
        songs['Recording'] = unique.ix[j].Recording1
        print(songs)
        attr.append(songs)
    except:
        continue
    else:
        continue
    #time.sleep(61)

a = pd.DataFrame(attr)
a.to_csv('song_attributes.csv')

#discovery Score: measure of how unexpectedly popular the artist is
#discovery rank for the song's artist
#familiarity for the song's artist
#familiarity rank for the song's artist
#hotttnesss of artist
#artist_hotttnesss_rank
#song_currency : measure of how recently popular the song is
#song_currency_rank
#song_discovery: measure of how unexpectedly popular the song is
#song_discovery_rank
#song_hotttnesss
#song_hotttnesss_rank
#song_type
#Genre of artist



#song_attr = {}
#bucket="song_discovery_rank"
#songid_url = 'http://developer.echonest.com/api/v4/song/search?api_key=QOEISO4ZCNSPLKQOQ&artist=Katy+Perry&title=Roar&bucket=song_discovery_rank'
#songid_dict = json.loads(bytes.decode(urllib.request.urlopen(songid_url).read()))
#songs = songid_dict['response']['songs']
#for i in range(0,len(songs)-1):
#    try:
#        song_attr[bucket] = songid_dict['response']['songs'][i][bucket]
#    except:
#        continue
#    else:
#        break
        
