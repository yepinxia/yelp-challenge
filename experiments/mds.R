library("NLP") 
library("tm") 
library("SnowballC") 
library("RColorBrewer")
library("wordcloud") 
library('proxy')

norm_eucl <- function(m) m/apply(m, MARGIN=1, FUN=function(x) sum(x^2)^.5)

#preprocess
catnames <- list.files("/Users/pinxiaye/Documents/MS-CS/522/project/restdata", full.names=FALSE)
filepath <- list.files("/Users/pinxiaye/Documents/MS-CS/522/project/restdata", full.names=TRUE)

dat<-c("/Users/pinxiaye/Documents/MS-CS/522/project/restdata")

ds <- Corpus(DirSource(dat, recursive=TRUE),readerControl = list(reader=readPlain))

ds <- tm_map(ds, tolower)
ds <- tm_map(ds, stemDocument)
my_stopwords <- c(stopwords("english"),"food", "drink","restaurant","business",
                  "service","staff", "great","location","place", "time","atmosphere", "best","store","price")
ds <- tm_map(ds, removeWords, my_stopwords )
ds <- tm_map(ds, removePunctuation)
ds <- tm_map(ds, stripWhitespace) 
ds <- tm_map(ds , PlainTextDocument)

dtm <- DocumentTermMatrix(ds,control=list(wordLengths=c(4,Inf)))
tdm <- TermDocumentMatrix(ds,control=list(wordLengths=c(4,Inf))) #Term

# rowTotals <- apply(dtm , 1, sum)
# as.data.frame(dtm[rowTotals = 0, ]) 
# dtm.new   <- dtm[rowTotals > 0, ]  

dtm_tfxidf<- weightTfIdf(dtm) 

sing <-svd(dtm_tfxidf)
#sing <-svd(dtm)
u5<-as.matrix(sing$u[, 1:20])
v5<-as.matrix(sing$v[, 1:20])
d5<-as.matrix(diag(sing$d)[1:20, 1:20])

docm  <-as.matrix(u5%*%d5%*%t(v5),type='blue')
dtmt_5d_norm<-norm_eucl(docm)
#docm<-as.matrix(dtm_tfxidf)
rownames(dtmt_5d_norm) <- catnames
#distance
dism <- dist(docm, method="cosine")
write.csv(dismm, file="/Users/pinxiaye/Documents/MS-CS/522/project/cosinedist.csv")
dist_euc<-dist(scale(dtmt_5d_norm))
#dist_j<-dist(docm,method="eJaccard")
#dist_jf<-dist(docm,method="fJaccard")
#hist(dist_j, main="Histogram of Jaccard Distance")

fit <- cmdscale(dist_euc,eig=TRUE, k=2) # k is the number of dim
fit # view results

# plot solution 
x <- fit$points[,1]
y <- fit$points[,2]

png("/Users/pinxiaye/Documents/MS-CS/522/project/mygraph.png",  width = 1500, height = 1500, units = "px")
plot(x, y, main="MDS Map of Categories",	type="n")
text(x, y, labels = catnames)
dev.off() 
  
png("/Users/pinxiaye/Documents/MS-CS/522/project/mygraph.png",  width = 2000, height = 1600, units = "px")
plot(res_fit, cex=0.9, hang = -1, main="Restaurant Cluster Dendrogram")
dev.off()
#cut tree
rect.hclust(res_fit, k = 5)