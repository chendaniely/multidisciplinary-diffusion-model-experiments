library(testthat)
library(parallel)

calculate_activation_value_columns <- function(num_processing_units,
                                         beginning_info=5){
    first_activation_value <- beginning_info + 1
    end_activation_value <- first_activation_value + num_processing_units - 1

    activation_value_columns <- c(first_activation_value:end_activation_value)

    expect_equal(length(activation_value_columns), num_processing_units)

    return(activation_value_columns)
}

calculate_prototype_value_columns <- function(num_processing_units,
                                        beginning_info=5,
                                        number_of_sections=4){
    end_value <- (number_of_sections * num_processing_units) + beginning_info
    begin_value <-end_value - num_processing_units + 1

    prototype_value_columns <- c(begin_value:end_value)

    expect_equal(length(prototype_value_columns), num_processing_units)

    return(prototype_value_columns)
}

get_num_cores_to_use <- function(){
    num_cores <- detectCores()
    if(num_cores <= 8){
        return(num_cores)
    } else {
        return(ceiling(num_cores * (2/3)))
    }
}
