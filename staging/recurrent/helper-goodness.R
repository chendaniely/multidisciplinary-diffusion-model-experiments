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
calculate_goodness_t1 <- function(weights_same_bank_list){

}
