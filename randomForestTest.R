#
# Exemplifica o uso do algoritmo random forest.
#
# http://cran.r-project.org/doc/contrib/Zhao_R_and_data_mining.pdf
# http://cran.r-project.org/web/packages/randomForest/randomForest.pdf
#

library(randomForest)
data(iris)

# training
forestIris <- randomForest(Species ~ Petal.Width + Petal.Length, data=iris, prox=TRUE)
forestIris

# getting a single tree
getTree(forestIris, k=2)

# class "centers"
iris.p <- classCenter(iris[,c(3,4)], iris$Species, forestIris$prox)
plot(iris[,3], iris[,4], pch=21, xlab=names(iris)[3], ylab=names(iris)[4], 
     bg=c("red","blue","green")[as.numeric(factor(iris$Species))], main="Iris Data with Prototypes")
points(iris.p[,1], iris.p[,2], pch=21, cex=2, bg=c("red", "blue", "green"))

# combining random forests
forestIris1 <- randomForest(Species~ Petal.Width + Petal.Length, data=iris, prox=TRUE, ntree=50)
forestIris2 <- randomForest(Species~ Petal.Width + Petal.Length, data=iris, prox=TRUE, ntree=50)
forestIris3 <- randomForest(Species~ Petal.Width + Petal.Length, data=iris, prox=TRUE, ntree=50)
forestIris1
forestIris2
forestIris3
model <- combine(forestIris1, forestIris2, forestIris3)

# predicting new values
newdata <- data.frame(Sepal.Length<- rnorm(1000,mean(iris$Sepal.Length),
                                           sd(iris$Sepal.Length)),
                      Sepal.Width <- rnorm(1000,mean(iris$Sepal.Width),
                                           sd(iris$Sepal.Width)),
                      Petal.Width <- rnorm(1000,mean(iris$Petal.Width),
                                           sd(iris$Petal.Width)),
                      Petal.Length <- rnorm(1000,mean(iris$Petal.Length),
                                            sd(iris$Petal.Length)))

pred <- predict(forestIris,newdata)

plot(newdata[,4], newdata[,3], pch=21, xlab="Petal.Length",ylab="Petal.Width",
     bg=c("red", "blue", "green")[as.numeric(pred)],main="newdata Predictions")