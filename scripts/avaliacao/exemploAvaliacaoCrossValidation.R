library(party)
set.seed(1234)

#Faça a carga dos dados e faca o modelo
data(iris)
dataset <- iris

#Utilize cross validation 10-fold para criar e validar o classificador;

formula <- Species ~.
k <- 10
ids <- sample(1:k, nrow(dataset), replace=TRUE)
list <- 1:k
erros <- 1:k

for(i in 1:k){
  treinamento <- subset(dataset, ids %in% list[-i])
  teste <- subset(dataset, ids %in% c(i))
  model <- ctree(formula, treinamento)
  plot(model)
  erros[i] <- sum(predict(model, teste) != teste$Species) / nrow(teste)
}

mean(erros)
sd(erros)
