rm(list = ls())
gc()

library(parallel)
library(doParallel)
library(reshape2)
library(ggplot2)

source(file = 'R/helper_config.R')
source(file = 'R/helper.R')
source(file = 'R/helper_plot_subtract_prototype.R')

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

print('subtract prototype from each processing unit')
strt <- Sys.time()
list_only_updated_sub_proto <- lapply(X = list_stacked_df,
                                      FUN = subtract_prototype_from_pu)
print_difftime_prompt('subtract prototype from each processing unit',
                      diff_time = Sys.time() - strt)

rm(list_stacked_df)
gc()

print('melt dataframs in list_only_updated_sub_proto')
strt <- Sys.time()
list_only_updated_melt_sub_proto <- lapply(X = list_only_updated_sub_proto,
                                 FUN = melt,
                                 id.vars=c('time', 'agent', 'isUpdated',
                                           'run_number'))
print_difftime_prompt('melt dataframs in list_only_updated_sub_proto',
                      diff_time = Sys.time() - strt)

rm(list_only_updated_sub_proto)
gc()

print('save list_only_updated_melt_sub_proto')
strt <- Sys.time()
save(list_only_updated_melt_sub_proto,
     file = paste(config_batch_folder_path,
                  'df_stacked_runs_updated_melt_list_sub_proto.RData',
                  sep = '_'))
print_difftime_prompt('save list_only_updated_melt_sub_proto',
                      diff_time = Sys.time() - strt)
