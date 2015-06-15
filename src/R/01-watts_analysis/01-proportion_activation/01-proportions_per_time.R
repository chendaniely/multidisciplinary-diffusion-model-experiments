library(readr)
library(dplyr)

data <- readr::read_csv('../../../01-watts/output/network_of_agents.pout',
                        col_names = c('time', 'agent', 't_num_update',
                                      'up_state', 'state'))

prop <- data %>%
    group_by(time) %>%
    summarize(total_1 = sum(state),
              prop_1 = total_1 / n())
head(prop, 100)
tail(prop, 100)
