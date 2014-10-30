#LENGTH OF PROTOTYPE
len.of.input <- 20

#MAKE PROTOTYPE
a <- rep(NA,len.of.input) #x is len.of.input
for(i in 1:len.of.input) {
    a[i] <- sample(c(0,1),1,prob=c(.5,.5))
}

#ASSIGN PROTOTYPE
prototype <- a

#MAKE ABSTRACTIONS

n.exs <- 50 #NO EXAMPLES AS PROTOTYPES
catch.abstractions <- matrix(rep(prototype,n.exs),nrow=n.exs,ncol=len.of.input,byrow=TRUE)
prob.flip <- .2
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
    write(as.character(y),ncolumns=1+u+1,file="prototype.ex",append=TRUE)
    o <- prototype
    z <- c("B:",o,";")
    write(as.character(z),ncolumns=1+u+1,file="prototype.ex",append=TRUE)
}
#CHECKED BY HAND

#SHOULD WRITE OUT SOME PARTIAL INPUTS BASED ON PROTOTYPE
#WAIT ON THIS

#WRITE n ABSTRACTIONS ON PROTOTYPE
#MCCLELLAND AND RUMEL DID 20% INDEPENDENT ON EACH (BUT IF YES, THEN CHANGED THE SIGN)
rm(n,u,y,o,z)
n <- length(catch.abstractions[,1])
u <- len.of.input

# agentNum <- Sys.getenv(c("a"))
# print("lens agentnum")
# print(agentNum)
# f = paste('weights/AgentWgt', agentNum, '.ex', sep = "")
# f = 'catch.abstractions.ex'

args <- commandArgs(trailingOnly = TRUE)
print(args)
f = args[1]

for(j in 1:n) {

    y <- paste("name: sit",j,sep="")
    write(as.character(y),ncolumns=1+u+1,file=f,append=TRUE)
    o <- catch.abstractions[j,]
    z <- c("B:",o,";")
    write(as.character(z),ncolumns=1+u+1,file=f,append=TRUE)
}

#USE TO CHECK BY HAND
# write.table(cbind(catch.abstractions[v,],v),file="tmp.txt")

#EOF
# c between 4, 10, 20
# mutation% 2, 10, 20
# 1000 agents
# 1000 time
