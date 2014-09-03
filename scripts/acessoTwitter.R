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

#vagasTweets <- userTimeline('vagas')
#fbarthTweets <- userTimeline('fbarth')

about_protesto <- searchTwitter('protesto', n=250)
df <- twListToDF(about_protesto)
save(df, file="data/20130612_protesto.rda")

dados <- searchTwitter('economist brasil', n=250)
df <- twListToDF(dados)
save(df, file="data/20140903_economist_brasil.rda")
