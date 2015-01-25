rm(list = ls())
gc()
library(parallel)
library(doParallel)
library(reshape2)
library(ggplot2)

source(file = 'analysis_config.R')
source(file = 'R/helper.R')
source(file = 'R/helper_plot_processing_units.R')

strt <- Sys.time()
# load list_stacked_df
load(file = '../results/simulations/02-lens_batch_2014-12-23_03:41:22_sm_partial_df_stacked_runs_list.RData')
print_difftime_prompt('load list of df .RData', diff_time = Sys.time() - strt)
# load list of df .RData took: 1.93490279515584 mins

# list_stacked_df <- list_stacked_df[1:3]

strt <- Sys.time()
list_only_updated <- lapply(X = list_stacked_df, FUN = group_by_time)
print_difftime_prompt('add run number to each df in list', diff_time = Sys.time() - strt)

rm(list_stacked_df)
gc()

strt <- Sys.time()
list_only_updated_melt <- lapply(X = list_only_updated,
                            FUN = melt,
                            id.vars=c('time', 'agent', 'isUpdated', 'run_number'))
print_difftime_prompt('melt dataframs in list_only_updated', diff_time = Sys.time() - strt)

rm(list_only_updated)
gc()

# test_df <- list_only_updated[[1]]

# test_df_melt <- melt(data = test_df, id.vars=c('time', 'agent', 'isUpdated', 'run_number'))

# start <- (nrow(test_df_melt)-100)
# end <- (nrow(test_df_melt))

strt <- Sys.time()
save(list_only_updated_melt,
     file = paste(config_batch_folder_path, 'df_stacked_runs_updated_melt_list.RData', sep = '_'),
     compress = 'bzip2',
     compression_level = 9)
print_difftime_prompt('save list_only_updated_melt', diff_time = Sys.time() - strt)
