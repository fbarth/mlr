library(twitteR)
library(yaml)

config = yaml.load_file("scripts/config.yml")

cred <- OAuthFactory$new(consumerKey=config$user$key, 
                         consumerSecret=config$user$secret, 
                         requestURL="https://api.twitter.com/oauth/request_token", 
                         accessURL="https://api.twitter.com/oauth/access_token", 
                         authURL="http://api.twitter.com/oauth/authorize")

cred$handshake()
registerTwitterOAuth(cred)