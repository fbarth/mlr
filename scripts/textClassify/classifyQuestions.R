library(tm)
library(SnowballC)

questoes <- read.csv("data/questoesProfessorBarthComma.csv")

# Aplicando transformações no corpus, removendo acentos e convertendo para caixa baixa:
text <- iconv(questoes$text,to="ASCII//TRANSLIT")
text <- tolower(text)
text <- removePunctuation(text)
text <- removeNumbers(text)
text <- removeWords(text, stopwords('portuguese'))

# Construindo uma matriz de documentos versus termos:
text <- stemDocument(text, 
                     language = "portuguese")
myCorpus <- Corpus(VectorSource(text))
docs_term <- DocumentTermMatrix(myCorpus)

dataset <- as.data.frame(
  cbind(
    inspect(docs_term), 
    questoes)
  )
dataset$text <- NULL

# separando os datasets em treino e teste
set.seed(1234)
ind <- sample(
  2, 
  nrow(dataset), 
  replace=TRUE,
  prob = c(0.8, 0.2))

treino <- dataset[ind == 1, ]
teste <- dataset[ind == 2, ]

# criando o modelo
library(randomForest)
model <- randomForest(
  classes ~ ., 
  data = treino, 
  importance = TRUE, 
  do.trace = 100)
model
plot(model)
varImpPlot(model)

preditos <- predict(model, teste)

library(caret)
confusionMatrix(preditos, teste$classes)

