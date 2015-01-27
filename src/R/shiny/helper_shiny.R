plot_index_from_d_e <- function(vector_d_e){
    vector_d_e_num <- as.numeric(vector_d_e)
    d <- vector_d_e_num[1]
    e <- vector_d_e_num[2]
    x <- config_num_epsilon_values

    expect_true(e <= config_num_epsilon_values)
    return_value <- (d * x) - x + e

    expect_true(return_value <= config_num_delta_values * config_num_epsilon_values)
    return(return_value)
}
