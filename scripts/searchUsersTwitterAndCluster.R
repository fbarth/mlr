require(rCharts)
source('scripts//acessoTwitter.R')

user <- getUser("fbarth")
userFollowing <- user$getFriends()
userFollowers <- user$getFollowers()
userNeighbors <- union(userFollowers, userFollowing)
userNeighbors.df = twListToDF(userNeighbors)

par(mfrow=c(2,2))
hist(userNeighbors.df$statusesCount)
hist(userNeighbors.df$followersCount)
hist(userNeighbors.df$friendsCount)
hist(userNeighbors.df$favoritesCount)
par(mfrow=c(1,1))

userNeighbors.df[userNeighbors.df=="0"]<-1

userNeighbors.df$logStatusesCount <- log(userNeighbors.df$statusesCount)
userNeighbors.df$logFollowersCount <-log(userNeighbors.df$followersCount)
userNeighbors.df$logFollowingCount <-log(userNeighbors.df$friendsCount)
userNeighbors.df$logFavoritesCount <-log(userNeighbors.df$favoritesCount)

par(mfrow=c(2,2))
hist(userNeighbors.df$logStatusesCount)
hist(userNeighbors.df$logFollowersCount)
hist(userNeighbors.df$logFollowingCount)
hist(userNeighbors.df$logFavoritesCount)
par(mfrow=c(1,1))


kObject.log <- data.frame(userNeighbors.df$logFollowingCount,
                          userNeighbors.df$logFollowersCount,
                          userNeighbors.df$logStatusesCount)

###elbow
mydata <- kObject.log
wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(mydata,
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")

###k-means

##Run the K Means algorithm, remember to specify centers from 'elbow plot'
userMeans.log <- kmeans(kObject.log, centers=4, iter.max=10, nstart=100)

##Add the vector of specified clusters back to the original vector as a factor
kObject.log$cluster=factor(userMeans.log$cluster)
userNeighbors.df$cluster <- kObject.log$cluster

plot(userNeighbors.df)

p2 <- nPlot(logFollowersCount ~ logFollowingCount, group = 'cluster', 
            data = userNeighbors.df, type = 'scatterChart')
p2$xAxis(axisLabel = 'Followers Count')
p2$yAxis(axisLabel = 'Following Count')
p2$chart(tooltipContent = "#! function(key, x, y, e){
         return e.point.screenName + ' Followers: ' + e.point.followersCount +' Following: ' + e.point.friendsCount
         } !#")
p2
