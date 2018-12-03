library(twitteR)
library(yaml)

config = yaml.load_file("scripts/twitter/config.yml")

consumer_key=config$user$key 
consumer_secret=config$user$secret
access_token=config$user$accessToken
access_secret=config$user$accessTokenSecret

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

tw = twitteR::searchTwitter('bolsonaro', 
                            n = 1000, 
                            since = '2018-12-01', 
                            retryOnRateLimit = 1e3)
dt = twitteR::twListToDF(tw)
save(dt, file = "data/bolsonaro.Rda")
