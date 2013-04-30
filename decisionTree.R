#
# This file tests packages party and RWeka for classification problems.
#
# References:
#
# http://cran.r-project.org/web/packages/RWeka/RWeka.pdf
# http://cran.r-project.org/doc/contrib/Zhao_R_and_data_mining.pdf
# 

# create trainning and test sets
set.seed(1234)
ind <- sample(2, nrow(iris), replace=TRUE, prob=c(0.7, 0.3))
trainData <- iris[ind==1,]
testData <- iris[ind==2,]

# load package party, build a decision tree, and check the prediction
library(party)
myFormula <- Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width
iris_ctree <- ctree(myFormula, data=trainData)

# check the prediction
table(predict(iris_ctree), trainData$Species)

print(iris_ctree)
plot(iris_ctree)
plot(iris_ctree, type="simple")

# predict on test data
testPred <- predict(iris_ctree, newdata = testData)
table(testPred, testData$Species)

#=========================================================

library(RWeka)
iris_j48 <- J48(myFormula, data=trainData)
table(predict(iris_j48), trainData$Species)
print(iris_j48)
plot(iris_j48)
