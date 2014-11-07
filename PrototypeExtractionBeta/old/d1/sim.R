library(lsa)

prototype <- c(0,0,0,1,1,1,1,0,1,0,0,0,1,0,1,0,0,0,0,1)

first2 <- read.table("~/Desktop/PrototypeExtractionBeta/d.2/testNet-first2.out", quote="\"", skip = 4)

last2 <- read.table("~/Desktop/PrototypeExtractionBeta/d.2/testNet-last2.out", quote="\"", skip = 4)

first2 <- cbind(first2, prototype)
last2 <- cbind(last2, prototype)

cosine(first2$V1, first2$prototype)
cosine(last2$V1, last2$prototype)
cosine(first2$V1, last2$V1)
