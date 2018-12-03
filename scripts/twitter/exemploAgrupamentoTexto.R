Sys.setenv(NOAWT=TRUE)
library(RXKCD)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)

# Abrindo o corpus

load("data//eleicoes.rda")
#load("data//bolsonaro.Rda")

# Aplicando transformações no corpus, removendo acentos e convertendo para caixa baixa:
text <- iconv(df$text,to="ASCII//TRANSLIT")
text <- tolower(text)
text <- removePunctuation(text)
text <- removeNumbers(text)
text <- removeWords(text, stopwords('portuguese'))
myCorpus <- Corpus(VectorSource(text))

# Construindo uma matriz de documentos versus termos:

myTable <- TermDocumentMatrix(myCorpus)
myTable
inspect(myTable[1:10,1:10])

# Identificando os termos mais frequentes:

findFreqTerms(myTable, lowfreq=20)

# Identificando as palavras que estão associadas com alguma palavra de
# interesse.

# substituir 'palavra' por algo de interesse.
# findAssocs(myTable, 'palavra', 0.3)

#Identificando os agrupamentos
#-----------------------------
# Construindo uma matriz termos versus documentos para iniciar o processo de clustering:


# aplicando algoritmo de stemming para reduzir a dimensao da matriz
text <- stemDocument(text, language = "portuguese")
myCorpus <- Corpus(VectorSource(text))

inspect(myCorpus[1:3])
docs_term <- DocumentTermMatrix(myCorpus)
inspect(docs_term[1:10,1:10])

# Implementação da função _elbow_ utilizada na 
# identificação do melhor número de agrupamentos.

set.seed(1234)
elbow <- function(dataset) {
  wss <- numeric(15)
  for (i in 1:15) wss[i] <- sum(kmeans(dataset, centers = i, nstart = 100)$withinss)
    plot(1:15, wss, type = "b", main = "Elbow method", xlab = "Number of Clusters",
          ylab = "Within groups sum of squares", pch = 8)
}

# Resultado da função _elbow_ e o tempo de processamento:

system.time(elbow(docs_term))

# Execução do _k-means_ com 7 agrupamentos:

cluster_model <- kmeans(docs_term, centers= 7, nstart= 100)
table(cluster_model$cluster)
cluster_model$withinss

# Visualização dos agrupamentos:

df[cluster_model$cluster == 1, c('text')]
df[cluster_model$cluster == 2, c('text')]
df[cluster_model$cluster == 3, c('text')]
df[cluster_model$cluster == 4, c('text')]
df[cluster_model$cluster == 5, c('text')]
df[cluster_model$cluster == 6, c('text')]
df[cluster_model$cluster == 8, c('text')]

#Apresentando os resultados
#--------------------------

my_wordcloud <- function(text){
  myCorpus <- Corpus(VectorSource(text))
  myTable <- TermDocumentMatrix(myCorpus)
  m <- as.matrix(myTable)
  v <- sort(rowSums(m),decreasing=TRUE)
  d <- data.frame(word = names(v),freq=v)
  pal <- brewer.pal(8, "Dark2")
  pal <- pal[-(1:2)]
  wordcloud(d$word,d$freq, scale=c(6,1), min.freq=5,max.words=100, random.order=FALSE, colors=pal)
}

png("results/cluster1.png", height = 1000, width = 1000)
my_wordcloud(Corpus(VectorSource(df[cluster_model$cluster == 1, c('text')])))
dev.off()

png("results/cluster2.png", height = 1000, width = 1000)
my_wordcloud(Corpus(VectorSource(df[cluster_model$cluster == 3, c('text')])))
dev.off()

png("results/cluster3.png", height = 1000, width = 1000)
my_wordcloud(Corpus(VectorSource(df[cluster_model$cluster == 4, c('text')])))
dev.off()

png("results/cluster4.png", height = 1000, width = 1000)
my_wordcloud(Corpus(VectorSource(df[cluster_model$cluster == 5, c('text')])))
dev.off()
