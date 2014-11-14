library(lsa)

prototype <- c(0,0,0,1,1,1,1,0,1,0,0,0,1,0,1,0,0,0,0,1)

dirs <- list.files()
dirs
pattern <- "^d"
index <- grep(pattern = pattern, x = dirs)
dirs <- dirs[index]
dirs

files <- c("first2", "last2", "proto", "zeros", "anti")

i <- 1
j <- 1

results <- matrix(data = NA, ncol = 4)
results
for(i in c(1:length(dirs))){
  folder <- dirs[i]
  folder

  for(j in c(1:length(files))){
    file <- paste("testNet-", files[j],".out", sep = "")
    file
    lens.out.file <- paste("~/Desktop/PrototypeExtractionBeta/", folder, "/", file, sep = "")
    lens.out.file
    data <- read.table(lens.out.file, quote="\"", skip = 4)
    data <- cbind(data, prototype)

    cosine.similarity <- cosine(data$V1, data$prototype)
    cosine.similarity
    angle <- acos(cosine.similarity) * (180/pi)
    angle

    append.values <- c(folder, file, cosine.similarity, angle)
    append.values
    results <- rbind(results, append.values)
    results
  }
}

results

results2 <- results
results2
results2 <- results2[-1, ]
results2

results2 <- as.data.frame(results2, row.names = paste(results2[,1], results2[,2], sep = ""))
results2

write.csv(results2, './cosine.csv')
