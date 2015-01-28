rm(list=ls())
gc()
library(ggplot2)
library(scales)

source(file = 'R/helper.R')
source('R/helper_config.R')

source('analysis_config.R')

file_path <- paste0(config_batch_folder_path,
                   '_df_stacked_runs_updated_melt_list.RData')
df_stacked_runs_updated_melt_list <-file_path

strt <- Sys.time()
load(df_stacked_runs_updated_melt_list)
print_difftime_prompt('load data', diff_time = Sys.time() - strt)

test_df_melt <- list_only_updated_melt[[1]]

strt <- Sys.time()
g <- ggplot(data = test_df_melt) +
    geom_line(aes(x = time, y = value, color=variable)) + facet_grid(run_number~variable) +
    theme(legend.position="none", axis.text.x = element_text(angle=90, vjust=0.5))
print_difftime_prompt('create ggplot object', diff_time = Sys.time() - strt)

strt <- Sys.time()
g
print_difftime_prompt('show ggplot object', diff_time = Sys.time() - strt)

strt <- Sys.time()
g + scale_x_continuous(limits=c(50, 60), breaks=pretty_breaks())
print_difftime_prompt('create ggplot object subset y-axis', diff_time = Sys.time() - strt)
