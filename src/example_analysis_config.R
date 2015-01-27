source(file = 'R/helper.R')

###############################################################################
# USER CONFIGURATIONS
###############################################################################
name_batch_simulation_output_folder <-
    '02-lens_batch_2014-12-23_03:41:22_sm_partial'
#     'bkup_02-lens_batch_2014-12-23_03:41:22





###############################################################################
# DEFAULT CONFIGURATIONS
###############################################################################
simulation_results_folder <- '../results/simulations/'
config_save_df_list <- TRUE
num_cores <- get_num_cores_to_use()


###############################################################################
# READ CONFIG FILE
###############################################################################
batch_folder <- paste(simulation_results_folder,
                      name_batch_simulation_output_folder,
                      sep='')


###############################################################################
# Parameters from config file
###############################################################################
num_processing_units <- 20
num_sims_per_sim_set <- 5
num_agents <- 10
num_ticks <- 10000

num_parameter_sets_no_a <- 30 # number of parameter sets w/out num agents

activation_value_columns <- calculate_activation_value_columns(num_processing_units)
prototype_value_columns <- calculate_prototype_value_columns(num_processing_units)
