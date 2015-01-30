rm(list=ls())
gc()
library(scales)

source(file = 'R/helper_config.R')
source(file = 'R/helper.R')

source(file = 'analysis_config.R')

load_file('_df_stacked_runs_updated_melt_list_sub_proto.RData')

test_df_melt <- list_only_updated_melt_sub_proto[[1]]

strt <- Sys.time()
g <- ggplot(data = test_df_melt) +
    theme_bw() +
    geom_line(aes(x = time, y = value, color=variable)) +
    facet_grid(run_number~variable) +
    theme(legend.position="none",
          axis.text.x = element_text(angle=90, vjust=0.5))
print_difftime_prompt('create ggplot object', diff_time = Sys.time() - strt)

strt <- Sys.time()
g
print_difftime_prompt('show ggplot object', diff_time = Sys.time() - strt)

strt <- Sys.time()
g + scale_x_continuous(limits=c(50, 60), breaks=pretty_breaks())
print_difftime_prompt('create ggplot object subset y-axis',
                      diff_time = Sys.time() - strt)

#
# Time if subsetting is faster, it is...
#
strt <- Sys.time()
g <- ggplot(data = test_df_melt[test_df_melt$time %in% c(50:80), ]) +
    theme_bw() +
    geom_line(aes(x = time, y = value, color=variable)) +
    facet_grid(run_number~variable) +
    theme(legend.position="none",
          axis.text.x = element_text(angle=90, vjust=0.5))
print_difftime_prompt('create ggplot object', diff_time = Sys.time() - strt)

strt <- Sys.time()
g
print_difftime_prompt('show ggplot object', diff_time = Sys.time() - strt)
