import urllib.request
import json

songlist =
artist = 'lorde'
song = 'royals'

songid_url = 'http://developer.echonest.com/api/v4/song/search?api_key=QOEISO4ZCNSPLKQOQ&artist=' + artist + '&title=' + song
songid_dict = json.loads(bytes.decode(urllib.request.urlopen(songid_url).read()))
song_id = songid_dict['response']['songs'][0]['id']

factors_url = 'http://developer.echonest.com/api/v4/song/profile?api_key=QOEISO4ZCNSPLKQOQ&id=' + song_id + '&bucket=audio_summary'
factors_dict = json.loads(bytes.decode(urllib.request.urlopen(factors_url).read()))
duration = factors_dict['response']['songs'][0]['audio_summary']['duration']
print(duration)
