c###############################################################################
#
# Script to calculate goodness function for a given link_values LENS output
# link_values contain the direction and weight between processing units
#
# This script uses LENS numering convensions
# That means things are most likely going to be 0 indexed
# instead of what R normally is in, 1 indexed
#
# i is on the y-axis
# j is on the x-axis
#
###############################################################################
rm(list = ls())

library(stringr)
library(igraph)
library(ggplot2)

source('helper.R')

###############################################################################
#
# Config Values
#
###############################################################################
num_units_per_bank <- 14

# these are 0 indexed values, aka the values in LENS
# these are the processing units picked to calculate goodness
a_i_index <- 0
a_j_index <- 1

# activation values for ai, and aj
# these are initially set to 0, but during the goodness calculation
# they are each swept though values from 0 to 1, inclusive
ai <- 0
aj <- 0

# values of ai and aj to calculate goodness
ai_aj_sets <- expand.grid(ai = seq(0, 1, .01),
                          aj = seq(0, 1, .01))
ai_aj_sets
dim(ai_aj_sets)


###############################################################################
#
# Read in data
#
###############################################################################

link_values <- read.table(file = '../data/link.values_old',
                          header = FALSE,
                          stringsAsFactors = FALSE)
head(link_values)
tail(link_values)
dim(link_values)

# clean up dataframe
link_values <- parse_link_values_file(link_values)
head(link_values)
tail(link_values)
dim(link_values)

hist(link_values$weights)

#
#
# add bias links
#
#
original <- rep(NA, num_units_per_bank)
weights <- rep(1, num_units_per_bank)
from <- rep(NA, num_units_per_bank)
to <- rep(NA, num_units_per_bank)
j_type <- rep("bias", num_units_per_bank)
j_value <- rep(1, num_units_per_bank)
i_type <- rep("Input", num_units_per_bank)
i_value <- c(0:(num_units_per_bank - 1))
bias_input_df <- data.frame(original, weights, from, to, j_type, j_value,
                            i_type, i_value)
link_values <- rbind(link_values, bias_input_df)

bias_input_mirror_df <- bias_input_df
bias_input_mirror_df$i_type <- "InputMirror"
link_values <- rbind(link_values, bias_input_mirror_df)

head(link_values)
tail(link_values)
dim(link_values)

#
#
# Add external input values
#
#
original <- rep(NA, num_units_per_bank)
weights <- rep(1, num_units_per_bank)
from <- rep(NA, num_units_per_bank)
to <- rep(NA, num_units_per_bank)
j_type <- rep("ExternalInput", num_units_per_bank)
j_value <- c(0:(num_units_per_bank - 1))
i_type <- rep("Input", num_units_per_bank)
i_value <- c(0:(num_units_per_bank - 1))
external_input_df <- data.frame(original, weights, from, to, j_type, j_value,
                                i_type, i_value)
link_values <- rbind(link_values, external_input_df)

#
#
# Add another external to input mirror
#
#
original <- rep(NA, num_units_per_bank)
weights <- rep(1, num_units_per_bank)
from <- rep(NA, num_units_per_bank)
to <- rep(NA, num_units_per_bank)
j_type <- rep("ExternalMirror", num_units_per_bank)
j_value <- c(0:(num_units_per_bank - 1))
i_type <- rep("InputMirror", num_units_per_bank)
i_value <- c(0:(num_units_per_bank - 1))
external_input_mirror_df <- data.frame(original, weights,
                                       from, to,
                                       j_type, j_value,
                                       i_type, i_value)
link_values <- rbind(link_values, external_input_mirror_df)


#external_input_mirror_df <- external_input_df
#external_input_mirror_df$i_type <- "InputMirror"
#link_values <- rbind(link_values, external_input_mirror_df)


head(link_values)
tail(link_values)
dim(link_values)

link_values

#
#
# make values in 2 digit form
#
#

link_values$j_value <- sprintf("%02d", as.numeric(link_values$j_value))
link_values$i_value <- sprintf("%02d", as.numeric(link_values$i_value))
head(link_values)
tail(link_values)
dim(link_values)

#
#
# recode type columns and create shorthand names for edge list
#
#
link_values$j_type_s <- sapply(link_values$j_type, abr_type)
link_values$i_type_s <- sapply(link_values$i_type, abr_type)
head(link_values)
tail(link_values)
dim(link_values)

link_values$j_name <- paste0(link_values$j_type_s, link_values$j_value)
link_values$i_name <- paste0(link_values$i_type_s, link_values$i_value)
head(link_values)
tail(link_values)
dim(link_values)

#
#
# Create edge list values
#
#

edge_list_values <- link_values[, names(link_values) %in%
                                    c("j_name", "i_name", "weights")]
head(edge_list_values)
tail(edge_list_values)
dim(edge_list_values)

#
#
# append i j values to dataframe
#
#
edge_list_values$a_i <- ifelse(
    edge_list_values$i_name == sprintf("in%02d", a_i_index),
    ai_aj_sets[4, 1],
    0)

head(edge_list_values)
tail(edge_list_values)
dim(edge_list_values)

edge_list_values$a_j <- ifelse(
    edge_list_values$j_name == sprintf("in%02d", a_j_index),
    ai_aj_sets[4, 2],
    0)

head(edge_list_values)
tail(edge_list_values)
dim(edge_list_values)


g <- graph.edgelist(as.matrix(edge_list_values[, names(edge_list_values) %in%
                                                   c("j_name", "i_name")]))
g
png('../output/networkgraph_edgelist.png', 800, 800)
plot(g)
dev.off()

E(g)$weight <- as.numeric(edge_list_values$weights)
E(g)$a_i <- as.numeric(edge_list_values$a_i)
E(g)$a_j <- as.numeric(edge_list_values$a_j)

m <- as.matrix(get.adjacency(g, attr = 'weight'))
m[m == 0] <- NA
m_sort <- sort_rows_columns_matrix(m)
dim(m_sort)
m_sort

mi <- as.matrix(get.adjacency(g, attr = 'a_i'))
#m[m == 0] <- NA
mi_sort <- sort_rows_columns_matrix(mi)
dim(mi_sort)
mi_sort

mj <- as.matrix(get.adjacency(g, attr = 'a_j'))
m[m == 0] <- NA
m_sort <- sort_rows_columns_matrix(m)
dim(m_sort)
m_sort


diff <- m_sort - t(m_sort)
diff
hist(diff[lower.tri(diff)])

# write.csv(m_sort, file = '../output/m_sort.csv')
# write.csv(m_sort, file = '../output/mi_sort.csv')
# write.csv(m_sort, file = '../output/mj_sort.csv')

###############################################################################
#
# Calculating goodness
#
###############################################################################

#
#
# Single Partial
#
#

edge_list_values$partial_goodness <- edge_list_values$weights *
    edge_list_values$a_i *
    edge_list_values$a_j

goodness <- sum(edge_list_values$partial_goodness, na.rm = TRUE)
goodness

goodness <- goodness / 2 # account for duplicated bi-directionality
goodness

#
#
# All
#
#

calculate_goodness_from_ai_aj_set <- function(x, a_i_index, a_j_index,
                                              link_values){
    ai <- x[1]
    aj <- x[2]

    edge_list_values <- link_values[, names(link_values) %in%
                                        c("j_name", "i_name", "weights")]

    edge_list_values$a_i <- ifelse(
        edge_list_values$i_name == sprintf("in%02d", a_i_index),
        ai,
        0)

    edge_list_values$a_j <- ifelse(
        edge_list_values$j_name == sprintf("in%02d", a_j_index),
        aj,
        0)

    edge_list_values$partial_goodness <- edge_list_values$weights *
        edge_list_values$a_i *
        edge_list_values$a_j

    goodness <- sum(edge_list_values$partial_goodness, na.rm = TRUE)

    goodness <- goodness / 2 # account for duplicated bi-directionality
    return(goodness)
}

goodness <- ai_aj_sets
goodness$goodness <- apply(X = goodness, MARGIN = 1,
                           FUN = calculate_goodness_from_ai_aj_set,
                           a_i_index=0,
                           a_j_index=1,
                           link_values=link_values)

head(goodness)
tail(goodness)
dim(goodness)
write.csv(x = goodness, file = '../results/goodness.csv')

png('../results/goodness.png')

ggplot(goodness, aes(ai, aj)) +
    geom_tile(aes(fill = goodness), color = 'white') +
    scale_fill_gradient(low = 'white', high = 'steelblue')

dev.off()
