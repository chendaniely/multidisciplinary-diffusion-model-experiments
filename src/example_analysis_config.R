source(file = 'R/helper.R')

simulation_results_folder <- '../results/simulations/'
###############################################################################
# READ CONFIG FILE
###############################################################################
batch_folder <- paste(simulation_results_folder,
                      '02-lens_batch_2014-12-23_03:41:22_sm_partial',
                      # 'bkup_02-lens_batch_2014-12-23_03:41:22,
                      sep='')

num_processing_units <- 20
num_sims_per_sim_set <- 5

num_parameter_sets_no_a <- 30 # number of parameter sets w/out num agents

activation_value_columns <- get_activation_value_columns(num_processing_units)
prototype_value_columns <- get_prototype_value_columns(num_processing_units)
