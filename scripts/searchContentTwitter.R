source('scripts//acessoTwitter.R')

#vagasTweets <- userTimeline('vagas')
#fbarthTweets <- userTimeline('fbarth')

about_protesto <- searchTwitter('protesto', n=250)
df <- twListToDF(about_protesto)
save(df, file="data/20130612_protesto.rda")

dados <- searchTwitter('economist brasil', n=250)
df <- twListToDF(dados)
save(df, file="data/20140903_economist_brasil.rda")
