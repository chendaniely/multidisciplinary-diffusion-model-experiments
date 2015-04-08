library(dplyr)

base_dir <- "../../results/simulations/02-lens_single_2015-04-07_21:25:50/"

network_of_agents <- read.csv(paste0(base_dir, 'output/network_of_agents.pout'), header=FALSE)
d <- network_of_agents
d <- d[d$V1 > -2, ]

avg <- d %>%
  mutate(avg_pos = (V4 + V5 + V6 + V7 + V8) / 5,
         avg_neg = (V9 + V10 + V11 + V12 + V13) / 5,
         avg_all = (V4 + V5 + V6 + V7 + V8 + V9 + V10 + V11 + V12 + V13) / 10)

for(selected_time in seq(-1, 249, 1)){
  file_name_to_use <- sprintf("%soutput/t_%04d.csv", base_dir, selected_time)
  print(file_name_to_use)

  sub <- avg[avg$V1 == selected_time ,names(avg) %in% c('V1', 'V2', 'avg_pos', 'avg_neg')]
  write.csv(x = sub, file = file_name_to_use)
}
