#
# Objetivo: Comparar a capacidade de generalizacao de um
# algoritmo indutor de arvore de decisão que faz uso de poda contra
# um que nao faz uso de poda.
#

library(caret)
library(rpart)
library(randomForest)

#
# Adquirindo o dataset e dividindo em conjunto de treinamento e teste
#

dataset <- read.csv("data/dataset-har-PUC-Rio-ugulino.csv", sep=";", dec=",")
set.seed(1234)
trainIndex <- createDataPartition(dataset$class, p = 0.6, list = FALSE, times = 1)
treinamento <- dataset[trainIndex, ]
teste <- dataset[-trainIndex, ]

#
# Construcao dos modelos com algoritmo indutor de arvore de decisao sem poda
#

#
# Definindo a formula e o dataset para os resultados

formula <- class ~ x1 + y1 + z1 + x2 + y2 + z2 + x3 + y3 + z3 + x4 + y4 + z4

percentuais <- c(0.0001, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1)
results <- data.frame(percentuais = percentuais, 
                      err_train = rep(0, length(percentuais)), 
                      err_test = rep(0, length(percentuais)))

#
# Criando os modelos

for(i in 1:length(percentuais)){
  indice <- createDataPartition(treinamento$class, p = percentuais[i], list = FALSE, times = 1)
  model <- rpart(formula, 
                 data = treinamento[indice,], 
                 method='class',
                 control = rpart.control(minsplit=1))
  x <- confusionMatrix(predict(model,treinamento[indice,], type="class"), 
                       treinamento[indice,c('class')])
  results[i,c('err_train')] <- 1 - x$overall[1]
  x <- confusionMatrix(predict(model,teste, type="class"), teste[,c('class')])
  results[i,c('err_test')] <- 1 - x$overall[1]   
}

#
# Imprimindo os resultados

png(filename="results/avaliacaoIDTsemPoda.png", height=400, width=600)
plot(results$percentuais, 
     results$err_train, 
     type="l", 
     col="red", 
     ylim=c(0,1), main="Análise de erro do algoritmo sem poda (rpart)",
     xlab="Percentual do dataset de treinamento utilizado no modelo",
     ylab="Erro do modelo")
lines(results$percentuais, results$err_test, type="l", col="blue")
legend("top", c("Validação com treinamento", "Validação com teste"),
       lty=c(1,1),
       col = c("red","blue"))
dev.off()

#
# Construcao dos modelos com algoritmo indutor de arvore de decisao com poda
#

#
# Definindo a formula e o dataset para os resultados

formula <- class ~ x1 + y1 + z1 + x2 + y2 + z2 + x3 + y3 + z3 + x4 + y4 + z4

percentuais <- c(0.0001, 0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1)
results <- data.frame(percentuais = percentuais, 
                      err_train = rep(0, length(percentuais)), 
                      err_test = rep(0, length(percentuais)))

#
# Criando os modelos

for(i in 1:length(percentuais)){
  indice <- createDataPartition(treinamento$class, p = percentuais[i], list = FALSE, times = 1)
  model <- J48(formula, treinamento[indice,])
  x <- confusionMatrix(predict(model,treinamento[indice,], type="class"), 
                       treinamento[indice,c('class')])
  results[i,c('err_train')] <- 1 - x$overall[1]
  x <- confusionMatrix(predict(model,teste, type="class"), teste[,c('class')])
  results[i,c('err_test')] <- 1 - x$overall[1]   
}

#
# Imprimindo os resultados

png(filename="results/avaliacaoIDTcomPoda.png", height=400, width=600)
plot(results$percentuais, 
     results$err_train, 
     type="l", 
     col="red", 
     ylim=c(0,1), main="Análise de erro do algoritmo com poda (J48)",
     xlab="Percentual do dataset de treinamento utilizado no modelo",
     ylab="Erro do modelo")
lines(results$percentuais, results$err_test, type="l", col="blue")
legend("top", c("Validação com treinamento", "Validação com teste"),
       lty=c(1,1),
       col = c("red","blue"))
dev.off()
