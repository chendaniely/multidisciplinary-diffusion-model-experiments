library(dplyr)

group_by_time <- function(simulation_data_frame){
    simulation_by_time_update_sub <- simulation_data_frame %>%
        group_by(time, isUpdated, run_number) %>%
        select(time, agent, isUpdated, V6:V25) %>%
        filter(isUpdated == 1)
    return(simulation_by_time_update_sub)
}

plot_processing_units_time <- function(df_data){
    ggplot() +
        geom_line()
}
