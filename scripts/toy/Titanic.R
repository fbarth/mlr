#
# Carga dos dados
# 


library(UsingR)
data(Titanic)

expandir <- function(dataset){  
  final <- data.frame(Class = NA, 
                      Sex = NA, 
                      Age = NA,
                      Survived = NA)
  count <- 1
  for(i in 1:nrow(dataset)){
    if(dataset[i,5] > 0){
      for(j in 1:dataset[i,5]){
        final[count,] <- c(paste(dataset[i,1]), 
                           paste(dataset[i,2]), 
                           paste(dataset[i,3]), 
                           paste(dataset[i,4]))
        count <- count + 1
      } 
    }
  }
  return (final)
}

titanic <- expandir(data.frame(Titanic))
rm(Titanic)

titanic$Class <- as.factor(titanic$Class)
titanic$Sex <- as.factor(titanic$Sex)
titanic$Age <- as.factor(titanic$Age)
titanic$Survived <- as.factor(titanic$Survived)

#
# construcao do modelo
#

library(randomForest)
set.seed(1234)

ids <- sample(2, nrow(titanic), replace = TRUE, prob = c(0.8,0.2))
treinamento <- titanic[ids == 1,]
teste <- titanic[ids == 2,]

model <- randomForest(Survived ~., data=treinamento)
t <- table(predict(model, teste), teste$Survived)
t
