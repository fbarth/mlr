#Faça a carga dos dados;
data(iris)

#Divida o dataset em treinamento (80%) e teste (20%);
set.seed(1234)
ind <- sample(2, nrow(iris), replace=TRUE, prob=c(0.8, 0.2))
treinamento <- iris[ind==1,]
teste <- iris[ind==2,]

#Crie uma árvore de decisão usando o conjunto de treinamento;
library(party)
model <- ctree(Species ~., treinamento)

#Teste a árvore de decisão no conjunto de teste;
mc <- table(predict(model, teste), teste$Species)

#Imprima a árvore de decisão;
plot(model)

#Imprima a matriz de confusão;
mc

#Calcule a acuracidade do classificador.
acuracia <- (mc[1,1]+mc[2,2]+mc[3,3])/sum(mc)

#
# outra forma para calcular a acuracia e 
# a matrix de confusao
#

library(caret)
confusionMatrix(predict(model, teste), teste$Species)

