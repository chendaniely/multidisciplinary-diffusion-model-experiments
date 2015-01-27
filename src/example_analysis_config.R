###############################################################################
# USER CONFIGURATIONS
###############################################################################
config_name_batch_simulation_output_folder <-
    '02-lens_batch_2014-12-23_03:41:22_sm_partial'
#     'bkup_02-lens_batch_2014-12-23_03:41:22





###############################################################################
# DEFAULT CONFIGURATIONS
###############################################################################
config_simulation_results_folder <- '../results/simulations/'
config_save_df_list <- TRUE
config_num_cores <- get_num_cores_to_use()


###############################################################################
# READ CONFIG FILE
###############################################################################
config_batch_folder_path <- paste(config_simulation_results_folder,
                                  config_name_batch_simulation_output_folder,
                                  sep='')


###############################################################################
# Parameters from config file
###############################################################################
config_num_processing_units <- 20
config_num_sims_per_sim_set <- 5
config_num_agents <- 10
config_num_ticks <- 10000

config_num_parameter_sets_no_a <- 30 # number of parameter sets w/out num agents
config_num_delta_values <- 5
config_num_epsilon_values <- 6

config_activation_value_columns <-
    calculate_activation_value_columns(config_num_processing_units)
config_prototype_value_columns <-
    calculate_prototype_value_columns(config_num_processing_units)
