################################################################################
#
# Goodness calculation functions
#
################################################################################
get_input_i <- function(unit_number){
    input <- 0
    return(input)
}

get_bias_i <- function(i_j_index_number){
    bias <- 1
    return(bias)
}

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


#' First term of the Goodness function on the 2 activation units
#' 2 activation units share 1 weight between them
#' \sum_{i}\sum_{j > i} w_{ij} a_i a_j
calculate_goodness_t1 <- function(ai, aj, a_i_pu_index, a_j_pu_index,
                                  same_bank_values){
    w <- same_bank_weight_matrix[
                                 row.names(same_bank_weight_matrix) ==
                                    a_i_pu_index,
                                 colnames(same_bank_weight_matrix) ==
                                     a_j_pu_index]
    t1 <- w * ai * aj
    if (is.na(t1)){
        stop("t1 value is NA")
    }
    return(w * ai * aj)
}

calculate_goodness_t2 <- function(ai, input_i){
    t2 <- ai * input_i
    if (is.na(t2)){
        stop("t2 is null")
    }
    return(t2)
}

calculate_goodness <- function(ai_aj_set, a_i_pu_index, a_j_pu_index,
                               same_bank_values,
                               opposite_bank_values,
                               hidden_bank_values){
    ai <- ai_aj_set[1]
    aj <- ai_aj_set[2]

    t1 <- calculate_goodness_t1(ai, aj, a_i_pu_index, a_j_pu_index,
                                same_bank_values)
    t2 <- calculate_goodness_t2(ai, 1)

    return(sum(t1, t2))
}
