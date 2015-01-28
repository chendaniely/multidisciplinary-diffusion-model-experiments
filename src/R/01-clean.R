rm(list=ls())

library(parallel)
library(foreach)
library(doParallel)
library(stringr)

source(file = 'R/helper_config.R')
source(file = 'analysis_config.R')
source(file = 'R/helper_clean.R')
source(file = 'R/helper.R')

###############################################################################
# Get list of .pout files in the results/simulations/SIM_FOLDER/
###############################################################################
pout_files <- get_batch_pout_files(config_batch_folder_path)
pout_files
sprintf('number of files found: %d', length(pout_files))

###############################################################################
# Reshape into matrix such that teach column are all the simulations for a
# given set of simulation parameters
# E.g. if there were 20 runs for each simulation, the nrow == 20
#      if there were 5 different deltas, and 6 different epsilons
#      the ncol == 30
###############################################################################
reshape_files <- matrix(data = pout_files, nrow = config_num_sims_per_sim_set)
reshape_files
sprintf('Each sim has %d runs. Total of %d sims',
        dim(reshape_files)[1], dim(reshape_files)[2])

###############################################################################
# For each column (all the simulation runs for a given set) we want to combine
# the data sets into a single dataframe so we can analyse the entire simulaiton
# set as a whole
#
# The end results of the parallelization is a list of dataframes
# each element of the list should be the results of all simulation runs
###############################################################################
cl <- makeCluster(config_num_cores)
registerDoParallel(cl)

print('get stacked dfs for all sim runs in parallel')
strt <- Sys.time()
list_stacked_df <- foreach(i = 1:ncol(reshape_files),
                           .packages=c('stringr', 'foreach', 'doParallel')) %dopar% {
    # read in each set of parameter sweeps into separate dataframe
    strt <- Sys.time()
    df <- get_model_simulation_df_parallel(i, config_num_agents,
                                           config_num_ticks,
                                           config_num_sims_per_sim_set)
    print(Sys.time() - strt)

    plot_name <- str_split(string = reshape_files[1, i], pattern = '/')[[1]][5]
    plot_name

    delta_value <- str_split(string = plot_name, pattern = '_')[[1]][2]
    delta_value <- str_replace(string = delta_value,
                               pattern = 'd', replacement = '')
    delta_value <- as.numeric(delta_value)
    delta_value

    epsilon_value <- str_split(string = plot_name, pattern = '_')[[1]][3]
    epsilon_value <- str_replace(string = epsilon_value,
                                 pattern = 'e', replacement = '')
    epsilon_value <- as.numeric(epsilon_value)
    epsilon_value

    df$delta_value <- delta_value
    df$epsilon_value <- epsilon_value

    to_list_stacked_df <- df
    to_list_stacked_df
}
print_difftime_prompt('get stacked dfs for all sim runs in parallel',
                      diff_time = Sys.time() - strt)

###############################################################################
# Generate df that is average sse of only agents who were updated by time
###############################################################################
# for each dataframe in list_stacked_df we will calculate a new df
print('get grouped dfs from list_stacked_df')
strt <- Sys.time()
list_stacked_df_grouped <- lapply(X = list_stacked_df,
                                  FUN = get_model_simulation_df_group_avg)
print_difftime_prompt('get grouped dfs from list_stacked_df',
                      diff_time = Sys.time() - strt)

###############################################################################
# Save to binary RData filesand rm list_stacked_df
###############################################################################
print('save list_stacked_df')
strt <- Sys.time()
save(list_stacked_df, reshape_files,
     file = paste(config_batch_folder_path,
                  'df_stacked_runs_list.RData', sep = '_'))
print_difftime_prompt('save list_stacked_df', diff_time = Sys.time() - strt)
# save list_stacked_df took: 37.5720306118329 min # using bzip -9

print('save list_stacked_df_grouped')
strt <- Sys.time()
save(list_stacked_df_grouped, reshape_files,
     file = paste(config_batch_folder_path,
                  'df_grouped_runs_list.RData', sep = '_'))
print_difftime_prompt('save list_stacked_df_grouped',
                      diff_time = Sys.time() - strt)

###############################################################################
# rm datasets
###############################################################################
strt <- Sys.time()
rm(list_stacked_df)
print_difftime_prompt('rm list_stacked_df', diff_time = Sys.time() - strt)

strt <- Sys.time()
rm(list_stacked_df_grouped)
print_difftime_prompt('rm list_stacked_df_grouped',
                      diff_time = Sys.time() - strt)

stopCluster(cl)
registerDoSEQ()
