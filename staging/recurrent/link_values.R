################################################################################
# This script uses LENS numering convensions
# That means things are most likely going to be 0 indexed
# instead of what R normally is in, 1 indexed
#

rm(list = ls())

library(stringr)
library(reshape2)
library(dplyr)
library(foreach)
library(ggplot2)
library(parallel)

source('helper.R')

link_values <- read.table(file = 'link.values',
                          header = FALSE,
                          stringsAsFactors = FALSE)

head(link_values)
tail(link_values)
dim(link_values)

link_values <- parse_link_values_file(link_values)
head(link_values)
tail(link_values)
dim(link_values)

################################################################################
#
# Same bank values
#
################################################################################
same_bank <- get_same_bank_df(link_values)
dim(same_bank)
head(same_bank)
tail(same_bank)

## same_bank <- randomize_weights(same_bank, 'V2', -10, 10)
## dim(same_bank)
## head(same_bank)
## tail(same_bank)

same_bank_sub <- get_same_bank_sub_df(same_bank)
dim(same_bank_sub)
head(same_bank_sub)
tail(same_bank_sub)

#
# reshape and sort rows & columns
#
weight_df <- reshape_weights_df(same_bank_sub)
weight_df

weight_df <- sort_rows_columns_df(weight_df)
weight_df

#
# turn dataframe into matrix
#
weight_matrix <- as.matrix(weight_df)
weight_matrix

weight_matrix[lower.tri(weight_matrix)] <- NA
weight_matrix

# if you take the bottom half of the matrix you would not need to transpose
list_weights <- unlist(as.data.frame(weight_matrix))
# list_weights <- list_weights[!is.na(list_weights)]
list_weights

################################################################################
#
# Opposite bank values
#
################################################################################
weights_opposite_bank <- get_opposite_bank_df(link_values,
                                              randomize_weights = FALSE)
weights_opposite_bank

################################################################################
#
# Hidden bank values
#
################################################################################
weights_hidden_bank <- get_hidden_bank_df(link_values, randomize_weights = FALSE)
weights_hidden_bank

################################################################################
#
# Config Values
#
################################################################################

# these are 0 indexed values, aka the values in LENS
a_i_index <- 3
a_j_index <- 7

ij_index_in_matrix <- nrow(weight_matrix) * (a_j_index) + (a_i_index + 1)
ij_index_in_matrix

ai <- 0
aj <- 0

ai_aj_sets <- expand.grid(ai = seq(0, 1, .2),
                          aj = seq(0, 1, .2))
ai_aj_sets


calculate_goodness <- function(ai_aj_set){
    ai <- ai_aj_set[1]
    aj <- ai_aj_set[2]
################################################################################
# First term of the Goodness function on the 2 activation units
# 2 activation units share 1 weight between them
# \sum_{i}\sum_{j > i} w_{ij} a_i a_j
################################################################################
t1_list <- foreach(i = (1:length(list_weights))) %do% {
    if(i == ij_index_in_matrix){
        list_weights[i] * ai * aj
    } else{
        list_weights[i] * .5 * .5
    }
}
t1_list
# weight_matrix
t1 <- sum(unlist(t1_list), na.rm = TRUE)
t1

################################################################################
# Second term of the Goodness function
# \sum_{i} a_i input_i
################################################################################
get_input_i <- function(unit_number){
    input <- 0
    return(input)
}

num_units_per_bank_0 <- nrow(unique(same_bank[, c('i_type', 'i_value')])) - 1
num_units_per_bank_0

t2_list <- foreach(i = (0:num_units_per_bank_0)) %do% {
    if(i == a_i_index){
        # print('hello')
        get_input_i(i) * ai
    } else{
        get_input_i(i) * .5
    }
}
t2_list

# weight_matrix
t2 <- sum(unlist(t2_list), na.rm = TRUE)
t2

################################################################################
# Third term of the Goodness function
# \sum_{i} b w_b a_i
################################################################################
get_bias_i <- function(i_j_index_number){
    bias <- 1
    return(bias)
}

t3_list <- foreach(i = (1:length(list_weights))) %do% {
    if(i == ij_index_in_matrix){
        # print('hello')
        get_bias_i(i) * ai
    } else{
        get_bias_i(i) * .5
    }
}
t3_list

t3 <- sum(unlist(t3_list), na.rm = TRUE)
t3

################################################################################
# Fourth term of the Goodness function
# calculating the t, links
# this is for ai
# \sum_{k} a_i a_k w_{ik}
################################################################################

input_and_hidden <- link_values[link_values$i_type == 'Input' |
                                link_values$i_type == "Hidden" |
                                link_values$i_type == 'InputMirror', ]
sample_n(input_and_hidden, 20)
dim(input_and_hidden)
input_and_hidden[!duplicated(input_and_hidden[, c('i_type', 'i_value')]), ]

#' get index values for all other nodes in the
#' 'input', 'hidden', and 'inputmirror' banks
get_ks <- function(i_or_j, i_value, j_value, num_units_per_bank_0,
                   num_units_per_hidden_bank_0){
    all_same_bank_number <- c(0:num_units_per_bank_0)
    same_bank <-all_same_bank_number[!all_same_bank_number %in% c(i_value,
                                                                  j_value)]
    opposite_bank <- ifelse(i_or_j == 'i', i_value, j_value)
    hidden_bank <- c(0:num_units_per_hidden_bank_0)
    return(list(same_bank = same_bank,
                opposite_bank = opposite_bank,
                hidden_bank = hidden_bank))
}

k_ai <- get_ks('i', a_i_index, a_j_index, num_units_per_bank_0, 9)
k_ai

#' get activation value for a_k
#' currently returns 0.5
get_a_k <- function(){
    return(0.5)
}

#'get
get_w_ij_k <- function(index_in_unlist_k_ai){

}

k_ai
unlisted_k_ai <- unlist(k_ai)
unlisted_k_ai

weight_matrix_mirror <- weight_matrix
weight_matrix_mirror[lower.tri(weight_matrix_mirror)] <-
    t(weight_matrix_mirror)[lower.tri(t(weight_matrix_mirror))]
weight_matrix_mirror

#
# Create Hidden matrix
#
t4_list <- foreach(i = (1:length(unlisted_k_ai))) %do% {
    if(i <= length(k_ai$same_bank)){
        # print('same_bank')
        # w_i_k <- weight_matrix[as.character(ai), as.character(k_ai$same_bank[i])]
        w_i_k <- weight_matrix_mirror[as.character(a_i_index),
                                      as.character(unlisted_k_ai[[i]])]
        ai * get_a_k() * w_i_k
    } else if(i == length(k_ai$same_bank) + 1){
        # print('opposite')
        # j_value <- weights_opposite_bank[weights_opposite_bank$j_value == ai, ]
        w_i_k <- weights_opposite_bank[weights_opposite_bank$j_value == ai, 'V2']
        ai * get_a_k() * w_i_k
    } else if(i > length(k_ai$same_bank) + 1){
        # print('hidden')
        connected_hidden <- weights_hidden_bank[weights_hidden_bank$i_value ==
                                                    a_i_index, ]
        w_i_k <- connected_hidden[connected_hidden$j_value == unlisted_k_ai[[i]], 'V2']
        ai * get_a_k() * w_i_k
    } else{
        stop("Unknown index passed into t4_list")
    }
 }

t4_list


t4 <- sum(unlist(t4_list), na.rm = TRUE)
t4

################################################################################
# Fifth term of the Goodness function, same as 4th, but using unit 'j'
# calculating the t, links
# this is for ai
# \sum_{k} a_j a_k w_{jk}
################################################################################

k_ai <- get_ks('j', a_i_index, a_j_index, num_units_per_bank_0, 9)
k_ai

unlisted_k_ai <- unlist(k_ai)
unlisted_k_ai

weight_matrix_mirror <- weight_matrix
weight_matrix_mirror[lower.tri(weight_matrix_mirror)] <-
    t(weight_matrix_mirror)[lower.tri(t(weight_matrix_mirror))]
weight_matrix_mirror

#
# Create Hidden matrix
#
t5_list <- foreach(i = (1:length(unlisted_k_ai))) %do% {
    if(i <= length(k_ai$same_bank)){
        # print('same_bank')
        # w_i_k <- weight_matrix[as.character(ai), as.character(k_ai$same_bank[i])]
        w_i_k <- weight_matrix_mirror[as.character(a_i_index),
                                      as.character(unlisted_k_ai[[i]])]
        ai * get_a_k() * w_i_k
    } else if(i == length(k_ai$same_bank) + 1){
        # print('opposite')
        # j_value <- weights_opposite_bank[weights_opposite_bank$j_value == ai, ]
        w_i_k <- weights_opposite_bank[weights_opposite_bank$j_value == ai, 'V2']
        ai * get_a_k() * w_i_k
    } else if(i > length(k_ai$same_bank) + 1){
        # print('hidden')
        connected_hidden <- weights_hidden_bank[weights_hidden_bank$i_value ==
                                                    a_i_index, ]
        w_i_k <- connected_hidden[connected_hidden$j_value == unlisted_k_ai[[i]], 'V2']
        ai * get_a_k() * w_i_k
    } else{
        stop("Unknown index passed into t4_list")
    }
 }

t5_list


t5 <- sum(unlist(t5_list), na.rm = TRUE)
t5

goodness <- t1 + t2 + t3 + t4 + t5
    return(goodness)
}

g <- calculate_goodness(c(0, 0))
g

ai_aj_sets$goodness <- apply(ai_aj_sets, 1, calculate_goodness)
ai_aj_sets

write.csv(ai_aj_sets, 'goodness.csv')

png('goodness.png')

ggplot(ai_aj_sets, aes(ai, aj)) +
    geom_tile(aes(fill = goodness), color = 'white') +
    scale_fill_gradient(low = 'white', high = 'steelblue')

dev.off()

persp(ai_aj_sets$ai, ai_aj_sets$aj, goodness, phi = 45, theta = 45,
  xlab = "ai", ylab = "aj",
  main = "Goodness Surface"
)

persp(seq(10, 300, 5), seq(10, 300, 5), z, phi = 45, theta = 45,
  xlab = "X Coordinate (feet)", ylab = "Y Coordinate (feet)",
  main = "Surface elevation data"
)


png('goodness_surface.png')

wireframe(goodness ~ ai * aj, data = ai_aj_sets,
  xlab = "ai", ylab = "aj",
  main = "Goodness Surface",
  drape = TRUE,
  colorkey = TRUE,
  screen = list(z = -60, x = -60)
)

dev.off()
