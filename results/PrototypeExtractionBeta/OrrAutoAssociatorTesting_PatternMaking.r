#LENGTH OF PROTOTYPE
len.of.input <- 20
sample.values <- c(0, 1)
prototype.name <- "prototype.ex"
abstractions.name <- "catch.abstractions.ex"
prob.flip <- 0.9

#MAKE PROTOTYPE
a <- rep(NA,len.of.input) #x is len.of.input
for(i in 1:len.of.input) {
    a[i] <- sample(sample.values, 1, prob=c(.5,.5))
}

#ASSIGN PROTOTYPE
# prototype <- a
prototype <- c(0,0,0,1,1,1,1,0,1,0,0,0,1,0,1,0,0,0,0,1)

#MAKE ABSTRACTIONS

n.exs <- 50 #NO EXAMPLES AS PROTOTYPES
catch.abstractions <- matrix(rep(prototype,n.exs),nrow=n.exs,ncol=len.of.input,byrow=TRUE)

prob.no.flip <- 1-prob.flip

for (i in 1:50){
    rm(v.tmp)
    v.tmp <- prototype

    #LOOP TO FLIP THE BIT AT THE BIT LEVEL
    for (j in 1:len.of.input){
        #FLIP OR NOT WHERE 1 IS FLIP
        if(sample(c(0,1),1,prob=c(prob.no.flip,prob.flip))==1){ #second arg in prob gives prob of bit flip & sum of both args = 1
            #FLIP
            ifelse(v.tmp[j]==0,v.tmp[j] <- 1,v.tmp[j] <- 0)
            catch.abstractions[i,j] <- v.tmp[j]
        }
        else{}
    }
}

#WHAT IS AVERAGE INPUT ACROSS ABSTRACTIONS
ave.input <- apply(catch.abstractions,2,mean)

#SANITY CHECK
rbind(prototype,ave.input)





#SHOULD WRITE THE PROTOTYPE OUT
#AS A TESTING INPUT
rm(n,u,y,o,z)
n <- 1
u <- len.of.input

for(j in 1:n) {

    y <- paste("name: sit",j,sep="")
    write(as.character(y),ncolumns=1+u+1,file=prototype.name,append=TRUE)
    o <- prototype
    z <- c("B:",o,";")
    write(as.character(z),ncolumns=1+u+1,file=prototype.name,append=TRUE)
}
#CHECKED BY HAND

#SHOULD WRITE OUT SOME PARTIAL INPUTS BASED ON PROTOTYPE
#WAIT ON THIS

#WRITE n ABSTRACTIONS ON PROTOTYPE
#MCCLELLAND AND RUMEL DID 20% INDEPENDENT ON EACH (BUT IF YES, THEN CHANGED THE SIGN)
rm(n,u,y,o,z)
n <- length(catch.abstractions[,1])
u <- len.of.input

for(j in 1:n) {

    y <- paste("name: sit",j,sep="")
    write(as.character(y),ncolumns=1+u+1,file=abstractions.name,append=TRUE)
    o <- catch.abstractions[j,]
    z <- c("B:",o,";")
    write(as.character(z),ncolumns=1+u+1,file=abstractions.name,append=TRUE)
}

#USE TO CHECK BY HAND
write.table(cbind(catch.abstractions[v,],v),file="tmp.txt")








#PULLING IN PAST GENERATED EXAMPLE SETS
#options(stringsAsFactors = FALSE)
#PULL PROTOTYPE
test.ex <- scan(prototype.name, what=list(name=character(0),sitNo=character(0),inputType=character(0),n1=numeric(0),n2=numeric(0),n3=numeric(0),n4=numeric(0),n5=numeric(0),n6=numeric(0),n7=numeric(0),n8=numeric(0),n9=numeric(0),n10=numeric(0),n11=numeric(0),n12=numeric(0),n13=numeric(0),n14=numeric(0),n15=numeric(0),n16=numeric(0),n17=numeric(0),n18=numeric(0),n19=numeric(0),n20=numeric(0),endLine=character(0)))
#CONVERT TO DATAFRAME
#test.ex.df <- data.frame(matrix(as.numeric(unlist(test.ex))),nrow=1,byrow=FALSE)
test.ex.df <- data.frame(matrix(as.numeric(unlist(test.ex)),nrow=1,byrow=FALSE))
test.ex.use <- test.ex.df[,4:23]
test.ex.mat <- as.matrix(test.ex.use)
test.ex.mat <- as.matrix(test.ex.use)
test.ex.mat[test.ex.mat==0] <- -1

#PULL GENERATED EXAMPLES
train.ex <- scan(abstractions.name, what=list(name=character(0),sitNo=character(0),inputType=character(0),n1=numeric(0),n2=numeric(0),n3=numeric(0),n4=numeric(0),n5=numeric(0),n6=numeric(0),n7=numeric(0),n8=numeric(0),n9=numeric(0),n10=numeric(0),n11=numeric(0),n12=numeric(0),n13=numeric(0),n14=numeric(0),n15=numeric(0),n16=numeric(0),n17=numeric(0),n18=numeric(0),n19=numeric(0),n20=numeric(0),endLine=character(0)))
#CONVERT TO DATAFRAME
train.ex.df <- data.frame(matrix(as.numeric(unlist(train.ex)),nrow=50,byrow=FALSE))
train.ex.use <- train.ex.df[,4:23]
train.ex.mat <- as.matrix(train.ex.use)
train.ex.mat[train.ex.mat==0] <- -1



catch.sim <- rep(NA,length(train.ex.mat[,1]))

#COMPUTE SIMILARITY
for(i in 1:length(train.ex.mat[,1])){
    catch.sim[i] <- train.ex.mat[i,]%*%test.ex.mat[1,]
}

#EOF
