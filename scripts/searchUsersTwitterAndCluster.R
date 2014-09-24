require(rCharts)
source('scripts//acessoTwitter.R')

user <- getUser("fbarth")
userFollowing <- user$getFriends()
userFollowers <- user$getFollowers()
userNeighbors <- union(userFollowers, userFollowing)
userNeighbors.df = twListToDF(userNeighbors)

# plotando a sua lista de vizinhos utilizando os atributos
# quantidade de seguidores e quantidade de amigos 
# (o que é exatamente amigos neste contexto?)

plot(userNeighbors.df$followersCount, userNeighbors.df$friendsCount)

# o resultado deste plot nao eh tao legivel pois a maioria
# dos pontos fica proximo do eixo (0,0)

userNeighbors.df[userNeighbors.df=="0"]<-1
userNeighbors.df$logFollowersCount <-log(userNeighbors.df$followersCount)
# o nome de friends para following eh muito estranho. Por isso estou
# mudando.
userNeighbors.df$logFollowingCount <-log(userNeighbors.df$friendsCount)
kObject.log <- data.frame(userNeighbors.df$logFollowingCount,
                          userNeighbors.df$logFollowersCount)

###elbow
mydata <- kObject.log
wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(mydata,
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")

###k-means

##Run the K Means algorithm, remember to specify centers from 'elbow plot'
userMeans.log <- kmeans(kObject.log, centers=6, iter.max=10, nstart=100)

##Add the vector of specified clusters back to the original vector as a factor
kObject.log$cluster=factor(userMeans.log$cluster)
userNeighbors.df$cluster <- kObject.log$cluster


p2 <- nPlot(logFollowersCount ~ logFollowingCount, group = 'cluster', 
            data = userNeighbors.df, type = 'scatterChart')
p2$xAxis(axisLabel = 'Followers Count')
p2$yAxis(axisLabel = 'Following Count')
p2$chart(tooltipContent = "#! function(key, x, y, e){
         return e.point.screenName + ' Followers: ' + e.point.followersCount +' Following: ' + e.point.friendsCount
         } !#")
p2
