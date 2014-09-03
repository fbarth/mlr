Identificação de agrupamentos em mensagens do Twitter
========================================================



```r
Sys.setenv(NOAWT = TRUE)
library(RXKCD)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
```


Carga do corpus:


```r
load("../data/20140424_economist_brasil.rda")
myCorpus <- Corpus(VectorSource(df$text))
inspect(myCorpus[1:3])
```

```
## A corpus with 3 text documents
## 
## The metadata consists of 2 tag-value pairs and a data frame
## Available tags are:
##   create_date creator 
## Available variables in the data frame are:
##   MetaID 
## 
## [[1]]
## Acorda BBRASIL ---&gt;  Brazil’s economy: The 50-year snooze | The Economist http://t.co/oUkc1GTcMm #brasil #brasil
## 
## [[2]]
## RT @soutojuliano: Boa reflexao ! #bastadeferiados "@SergipeNoticias: Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist”http…
## 
## [[3]]
## Como somos vistos lá fora?: O jornal The Economist mais uma vez ao se referir ao Brasil, associa o Brasil a al... http://t.co/BE42Ev1UX8
```


Aplicando transformações no corpus, removendo acentos e convertendo para caixa baixa:


```r
myCorpus <- tm_map(myCorpus, function(x) iconv(x, to = "ASCII//TRANSLIT"))
myCorpus <- tm_map(myCorpus, tolower)
```


Removendo pontuação, números e stop-words: 


```r
myCorpus <- tm_map(myCorpus, removePunctuation)
myCorpus <- tm_map(myCorpus, removeNumbers)
myCorpus <- tm_map(myCorpus, removeWords, stopwords("portuguese"))
myCorpus <- tm_map(myCorpus, removeWords, c("mim", "alguem", "nao", "pra"))
inspect(myCorpus[1:3])
```

```
## A corpus with 3 text documents
## 
## The metadata consists of 2 tag-value pairs and a data frame
## Available tags are:
##   create_date creator 
## Available variables in the data frame are:
##   MetaID 
## 
## [[1]]
## acorda bbrasil gt  brazils economy the year snooze  the economist httptcooukcgtcmm brasil brasil
## 
## [[2]]
## rt soutojuliano boa reflexao  bastadeferiados sergipenoticias trabalhador  brasil  gloriosamente improdutivo diz economisthttp
## 
## [[3]]
##   vistos la   jornal the economist   vez   referir  brasil associa  brasil  al httptcobeevux
```


Construindo uma matriz de documentos versus termos:


```r
myTable <- TermDocumentMatrix(myCorpus)
myTable
```

```
## A term-document matrix (540 terms, 199 documents)
## 
## Non-/sparse entries: 1972/105488
## Sparsity           : 98%
## Maximal term length: 27 
## Weighting          : term frequency (tf)
```

```r
inspect(myTable[1:10, 1:10])
```

```
## A term-document matrix (10 terms, 10 documents)
## 
## Non-/sparse entries: 4/96
## Sparsity           : 96%
## Maximal term length: 10 
## Weighting          : term frequency (tf)
## 
##             Docs
## Terms        1 2 3 4 5 6 7 8 9 10
##   aaa        0 0 0 0 0 0 0 0 0  0
##   abrir      0 0 0 0 0 0 0 0 0  0
##   acorda     1 0 0 0 0 0 0 0 0  0
##   acordar    0 0 0 0 0 0 0 1 1  1
##   acreditam  0 0 0 0 0 0 0 0 0  0
##   acredite   0 0 0 0 0 0 0 0 0  0
##   adianta    0 0 0 0 0 0 0 0 0  0
##   against    0 0 0 0 0 0 0 0 0  0
##   agora      0 0 0 0 0 0 0 0 0  0
##   aguerreiro 0 0 0 0 0 0 0 0 0  0
```


Identificando os termos mais frequentes:


```r
findFreqTerms(myTable, lowfreq = 20)
```

```
##  [1] "acordar"       "anos"          "brasil"        "brasileiro"   
##  [5] "diz"           "economico"     "economist"     "gloriosamente"
##  [9] "improdutivo"   "precisa"       "rosana"        "soneca"       
## [13] "the"           "trabalhador"   "valor"         "via"
```


Identificando as palavras que estão associadas com a palavra "improdutivo":


```r
findAssocs(myTable, "improdutivo", 0.8)
```

```
## gloriosamente     economico         valor   trabalhador 
##          0.95          0.82          0.82          0.81
```


Identificando os agrupamentos
-----------------------------

Construindo uma matriz termos versus documentos para iniciar o processo de clustering:


```r
# aplicando algoritmo de stemming para reduzir a dimensao da matriz
myCorpus <- tm_map(myCorpus, stemDocument, language = "portuguese")
inspect(myCorpus[1:3])
```

```
## A corpus with 3 text documents
## 
## The metadata consists of 2 tag-value pairs and a data frame
## Available tags are:
##   create_date creator 
## Available variables in the data frame are:
##   MetaID 
## 
## [[1]]
## acord bbrasil gt  brazils economy the year snooz  the economist httptcooukcgtcmm brasil brasil
## 
## [[2]]
## rt soutojulian boa reflexa  bastadeferi sergipenotic trabalh  brasil  glorios improdut diz economisthttp
## 
## [[3]]
##   vist la   jornal the economist   vez   refer  brasil assoc  brasil  al httptcobeevux
```

```r
docs_term <- DocumentTermMatrix(myCorpus)
```


Implementação da função _elbow_ utilizada na identificação do melhor número de agrupamentos.


```r
set.seed(1234)
elbow <- function(dataset) {
    wss <- numeric(15)
    for (i in 1:15) wss[i] <- sum(kmeans(dataset, centers = i, nstart = 100)$withinss)
    plot(1:15, wss, type = "b", main = "Elbow method", xlab = "Number of Clusters", 
        ylab = "Within groups sum of squares", pch = 8)
}
```


Resultado da função _elbow_ e o tempo de processamento:


```r
system.time(elbow(docs_term))
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 

```
##    user  system elapsed 
##  22.464   0.331  22.879
```


Execução do _k-means_ com 4 agrupamentos:


```r
cluster_model <- kmeans(docs_term, centers = 4, nstart = 100)
table(cluster_model$cluster)
```

```
## 
##   1   2   3   4 
##  13  50  30 106
```

```r
cluster_model$withinss
```

```
## [1]   2.769 112.140 106.333 877.953
```


Visualização dos agrupamentos:


```r
df[cluster_model$cluster == 2, c("text")]
```

```
##  [1] "RT @soutojuliano: Boa reflexao ! #bastadeferiados \"@SergipeNoticias: Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist”http…"  
##  [2] "Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/V8d9VyyaXJ"                                  
##  [3] "De fato: \"o trabalhador brasileiro é gloriosamente improdutivo\", diz The Economist http://t.co/Ehnq8xuzxf via @DComercio1"                    
##  [4] "Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/3BuEUelvDc"                                  
##  [5] "Ingleses de merda RT Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/VcRSSd8Tdw"             
##  [6] "Trabalhador do Brasil é gloriosamente improdutivo, diz \"Economist\" http://t.co/GeZSCTrCDf via @_usinas"                                       
##  [7] "RT @michelgeek: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/1bZbCwdbOP // Quantas gl…"   
##  [8] "Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/1bZbCwdbOP // Quantas glórias!"              
##  [9] "Trabalhador do Brasil é gloriosamente improdutivo, diz Economist http://t.co/EHmGtZtSjl"                                                        
## [10] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [11] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [12] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [13] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [14] "Chato mas verdade =&gt; RT: @rosana Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” http://t.co/Wgg2aEs5zE"
## [15] "olha que lindo... \nValor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/R1PkPEUjnX"              
## [16] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [17] "RT @rosana Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/06j29eFQpq"                       
## [18] "CERVEJA,CHURRASCO,CARNAVAL E BOLSA FAMÍLIA: \"Trabalhador do Brasil é gloriosamente improdutivo, diz Economist” - http://t.co/0dDPawRzAa"       
## [19] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [20] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [21] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [22] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [23] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [24] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [25] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [26] "Me incomoda de vdd RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/dI5b1tsIj5"   
## [27] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [28] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [29] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [30] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [31] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [32] "RT @rosana: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                      
## [33] "Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GtGwAO1bAH"                                  
## [34] "Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” http://t.co/UjhiPpAXmy"                                                      
## [35] "Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/yKNKPI2G1D"                                  
## [36] "Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/4smeJUehJa"                                  
## [37] "\"Soneca\" de 50 anos? Será?\nValor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/oz2wTorEim"    
## [38] "(E a nossa decantada criatividade/improvisação??)  Trabalhador do Brasil é gloriosamente improdutivo, diz Economist - http://t.co/X9hvyF8e18"   
## [39] "Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/ZtJI3nwzJ8"                                  
## [40] "Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/xvtVLjqrgl"                                                    
## [41] "RT @Luizarauj001: \"@valor_economico: Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” http://t.co/XOK83tJFfr\""              
## [42] "Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/QpreHex4Xz"                                  
## [43] "Trabalhador do Brasil é gloriosamente improdutivo, diz \"Economist\" http://t.co/GeZSCTrCDf via @_usinas"                                       
## [44] "Trabalhador do Brasil é gloriosamente improdutivo, diz Economist http://t.co/yf5dEVjf6T"                                                        
## [45] "Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/dV20zOS09R"                                  
## [46] "RT @FORTISAGRO: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/H81kPtqjDP"                  
## [47] "“ferrisss: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/GTCP1vM2YL”"                      
## [48] "RT @ferrisss: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/7GqQrSTicw"                    
## [49] "RT @ferrisss: Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/7GqQrSTicw"                    
## [50] "Valor Econômico - Trabalhador do Brasil é gloriosamente improdutivo, diz “Economist” - http://t.co/7GqQrSTicw"
```

```r
df[cluster_model$cluster == 1, c("text")]
```

```
##  [1] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
##  [2] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
##  [3] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
##  [4] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
##  [5] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
##  [6] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
##  [7] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
##  [8] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
##  [9] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
## [10] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
## [11] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
## [12] "RT @DesafioNOVO500: Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ htt…"
## [13] "Brasil @TheEconomist: Brazilian workers are gloriously unproductive. For the economy to grow http://t.co/tRLhBpgVmZ http://t.co/o2zNsFahRs"
```


Apresentando os resultados
--------------------------


```r
my_wordcloud <- function(myCorpus) {
    myCorpus <- tm_map(myCorpus, function(x) iconv(x, to = "ASCII//TRANSLIT"))
    myCorpus <- tm_map(myCorpus, tolower)
    myCorpus <- tm_map(myCorpus, removePunctuation)
    myCorpus <- tm_map(myCorpus, removeNumbers)
    myCorpus <- tm_map(myCorpus, removeWords, stopwords("portuguese"))
    myTable <- TermDocumentMatrix(myCorpus)
    m <- as.matrix(myTable)
    v <- sort(rowSums(m), decreasing = TRUE)
    d <- data.frame(word = names(v), freq = v)
    pal <- brewer.pal(8, "Dark2")
    pal <- pal[-(1:2)]
    wordcloud(d$word, d$freq, scale = c(6, 1), min.freq = 5, max.words = 100, 
        random.order = FALSE, colors = pal)
}
```




```
## Warning: httptcotrlhbpgvmz could not be fit on page. It will not be
## plotted.
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14.png) 


![plot of chunk unnamed-chunk-15](figure/unnamed-chunk-15.png) 


![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-16.png) 


![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17.png) 


Este material faz parte da palestra sobre [Web Data Mining com R](http://fbarth.net.br/materiais/webMiningR.html)
