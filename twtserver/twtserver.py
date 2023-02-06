#Author : Becode5
#Date : 21/11/2022

# Imports
import os
import json
import socket
import requests

# Load bearer token from .env file
from dotenv import load_dotenv
load_dotenv()
bearer_token = os.environ["BEARER_TOKEN"]

# Load query parameters from utils/query_for_twitter.py
from utils.twtquery import twtquery

endpoint_get = "https://api.twitter.com/2/tweets/search/stream"
endpoint_rules = "https://api.twitter.com/2/tweets/search/stream/rules"

# Set localhost socket parameters
HOST = "127.0.0.1"
PORT = 9095

# Create local socket
local_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
local_socket.bind((HOST, PORT))
local_socket.listen(1)
conn, addr = local_socket.accept()
print("Connected by", addr)

def request_headers(bearer_token: str) -> dict:
    """
    Sets up the request headers. 
    Returns a dictionary summarising the bearer token authentication details.
    """
    return {"Authorization": "Bearer {}".format(bearer_token)}

def connect_to_endpoint(endpoint_url: str, headers: dict, parameters: dict) -> json:
    """
    Connects to the endpoint and post customized filter for tweet search.
    Returns a json with data to show if your custom filter rule is created.
    
    """
    response = requests.post(url=endpoint_url, headers=headers, json=parameters)
    
    return response.json()

def get_tweets(url,headers):
    """
    Fetch real-time tweets based on your custom filter rule.
    Returns a Json format data where you can find Tweet id, text and some metadata.
    Sends the data to your defined local port where Spark reads streaming data.
    """
    counts = 0
    params = {
    "tweet.fields":"geo,lang,attachments,context_annotations,conversation_id,created_at,entities,organic_metrics,promoted_metrics,possibly_sensitive,referenced_tweets,public_metrics,source,withheld",
    "user.fields":"created_at,description,entities,location,pinned_tweet_id,profile_image_url,protected,url,username,verified,withheld",
    "place.fields":"contained_within,country,country_code,full_name,geo,id,name,place_type",
    "expansions":"author_id,geo.place_id"
    }
    get_response = requests.get(url=url,headers=headers,stream=True, params=params)

    if get_response.status_code!=200:
        print(get_response.status_code)
    
    else:
        for line in get_response.iter_lines():
            if line==b'':
                pass
            else:
                try:
                    json_response = json.loads(line)

                    tweet_id = json_response["data"]["id"]
                    tweet_raw = json_response

                    data_to_send = {
                        "id":tweet_id, 
                        "tweet_raw":tweet_raw, 
                        }

                    data_to_send_str = str(data_to_send) + "\n"
                    print(f"sent {counts}")
                    conn.send(bytes(data_to_send_str,'utf-8'))
                    
                except Exception as e:
                    print("Error------------")

headers = request_headers(bearer_token)

json_response = connect_to_endpoint(endpoint_rules, headers, query_for_twitter)

get_tweets(endpoint_get,headers)