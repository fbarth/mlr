library(foreign)
dataset <- read.arff('data/dados_journal_set11.arff')
sapply(dataset,class)

# trabalhando apenas com atributos de conteudo para
# predizer a classe: spam e não spam.

attr_conteudo <- c('qCapitalChar_tip', 'qNumeriChar_tip', 
                   'qPhone_tip', 'qEmail_tip', 'qURL_tip', 
                   'qContacts_tip', 'qWords_tip', 'qCapitalWords_tip', 
                   'qOffensWords_tip', 'hasOffensWords_tip', 'class1')

dataset <- dataset[, attr_conteudo]

# separando o conjunto de treinamento do de testes
library(caret)
set.seed(1234)
trainIndex <- createDataPartition(dataset$class1, p = .8,
                                  list = FALSE,
                                  times = 1)
train <- dataset[trainIndex,]
test <- dataset[-trainIndex,]

# breve analise descritiva 
# utilizando apenas o conjunto de treinamento

sapply(train, summary)

qplot(jitter(train$qWords_tip), 
      jitter(train$qEmail_tip), 
      col=train$class1, size=train$qURL_tip)

library(randomForest)
model <- randomForest(class1 ~ ., data=train, importance=TRUE, do.trace=100)
model

plot(model, lty = c(1, 1, 1), main="Erro estimado na quantidade de árvores utilizadas")
legend("top", c("OOB", "Não spam", "Spam"), lty = c(1, 1, 1), 
       lwd = c(2.5, 2.5, 2.5), col = c("black", "red", "green"))

varImpPlot(model, main="Importância dos atributos ao classificar as observações")

# gerando a matriz de confusao
testPred <- predict(model, newdata = test)
t <- table(testPred, test$class1)
acuracia_teste <- (t[1, 1] + t[2, 2])/sum(t)
t
acuracia_teste

# usando uma funcao jah definida
confusionMatrix(t, positive = 'spam')
