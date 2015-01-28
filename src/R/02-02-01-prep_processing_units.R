rm(list = ls())
gc()
library(parallel)
library(doParallel)
library(reshape2)
library(ggplot2)

source(file = 'R/helper_config.R')
source(file = 'R/helper.R')
source(file = 'R/helper_plot_processing_units.R')

source(file = 'analysis_config.R')

print('load list of df .RData')
file_path <- paste0(config_batch_folder_path,
                    '_df_stacked_runs_list.RData')
df_stacked_runs_list <-file_path

strt <- Sys.time()
# load list_stacked_df
load(file = df_stacked_runs_list)
print_difftime_prompt('load list of df .RData', diff_time = Sys.time() - strt)
# load list of df .RData took: 1.93490279515584 mins

print('add run number to each df in list')
strt <- Sys.time()
list_only_updated <- lapply(X = list_stacked_df, FUN = group_by_time)
print_difftime_prompt('add run number to each df in list', diff_time = Sys.time() - strt)

rm(list_stacked_df)
gc()

print('melt dataframs in list_only_updated')
strt <- Sys.time()
list_only_updated_melt <- lapply(X = list_only_updated,
                            FUN = melt,
                            id.vars=c('time', 'agent', 'isUpdated', 'run_number'))
print_difftime_prompt('melt dataframs in list_only_updated', diff_time = Sys.time() - strt)

rm(list_only_updated)
gc()

print('save list_only_updated_melt')
strt <- Sys.time()
save(list_only_updated_melt,
     file = paste(config_batch_folder_path,
                  'df_stacked_runs_updated_melt_list.RData', sep = '_'))
print_difftime_prompt('save list_only_updated_melt', diff_time = Sys.time() - strt)
