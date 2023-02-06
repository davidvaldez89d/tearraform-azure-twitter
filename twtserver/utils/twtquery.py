twtquery = {
    "add": [
        #Earthquake in several languages:
        # {"value": "地震"},
        # {"value": "deprem"},
        # {"value": "भूकम्प"},
        # {"value": "bhukamp"},
        # {"value": "زلزله"},
        # {"value": "zelzeleh"},
        # {"value": "dìzhèn"},
        # {"value": "भूकंप"},
        # {"value": "bhūkampa"},
        # {"value": "lindol"},
        # {"value": "σεισμός"},
        # {"value": "seismos"},
        # {"value": "землетрясение"},
        # {"value": "zemletryasenie"},
        # {"value": "tërmet"},
        # {"value": "земетресение"},
        # {"value": "zemotresenie"},
        # {"value": "երկրաշարժ"},
        # {"value": "erkrasharzh"},
        # {"value": "მიწისძვრა"},
        # {"value": "mits'idzghvra"},
        {"value": "earthquake -is:retweet "},
        {"value": "jishin -is:retweet"},
        {"value": "gempa bumi -is:retweet"},
        {"value": "terremoto -is:retweet"},
        {"value": "temblor -is:retweet"},
        {"value": "sismo -is:retweet"},
        
        #Earthquake in several languages with hashtags:
        {"value": "(#earthquake OR #jishin OR #gempabumi OR #terremoto OR #temblor OR #sismo) -is:retweet"},
        
        #Entities:
        {"value":"(entity:EmergencyEvents OR entity:Weather OR entity:Events OR entity:LocalNews)"},
        
        #Twitter accounts that tweet about earthquakes:
        # {"value":"(from:SismologicoMX OR from:sismos_chile OR from:Sismos_Peru_IGP) -is:retweet"},
        {"value":"(from:USGSted OR from:LastQuake OR from:EmsC OR from:QuakesToday OR from:earthquakeBot OR from:SismoDetector OR from:InfoEarthquakes OR from:SeismosApp OR fromeveryEarthquake OR from:eqgr) -is:retweet"}
        ]
    }