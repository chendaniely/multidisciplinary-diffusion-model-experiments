library(lsa)

prototype <- c(0,0,0,1,1,1,1,0,1,0,0,0,1,0,1,0,0,0,0,1)

first2 <- read.table("~/Desktop/PrototypeExtractionBeta/d1/testNet-first2.out", quote="\"", skip = 4)

last2 <- read.table("~/Desktop/PrototypeExtractionBeta/d1/testNet-last2.out", quote="\"", skip = 4)

proto <- read.table("~/Desktop/PrototypeExtractionBeta/d1/testNet-proto.out", quote="\"", skip = 4)

first2 <- cbind(first2, prototype)
last2 <- cbind(last2, prototype)
proto <- cbind(proto, prototype)

cosine(first2$V1, first2$prototype)
cosine(last2$V1, last2$prototype)
cosine(first2$V1, last2$V1)


cosine(proto$V1, proto$prototype)
