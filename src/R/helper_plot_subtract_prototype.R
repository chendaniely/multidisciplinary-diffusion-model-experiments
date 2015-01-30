library(dplyr)

subtract_prototype_from_pu <- function(simulation_data_frame){
    new_col_start <- ncol(simulation_data_frame) + 1
    new_col_end <- ncol(simulation_data_frame) + config_num_processing_units
    simulation_data_frame[, new_col_start:new_col_end] <-
        simulation_data_frame[, config_activation_value_columns] -
        simulation_data_frame[, config_prototype_value_columns]

    columns_by_name <- c('time', 'agent', 'isUpdated', 'run_number')
    columns_by_index <- c(new_col_start:new_col_end)

    pattern <- paste(columns_by_name, collapse = '|')
    columns <- grep(pattern = pattern, x = names(simulation_data_frame))
    simulation_data_frame <-
        simulation_data_frame[, c(columns, columns_by_index)]

    simulation_data_frame <- simulation_data_frame %>%
        filter(isUpdated == 1)

    return(simulation_data_frame)
}
