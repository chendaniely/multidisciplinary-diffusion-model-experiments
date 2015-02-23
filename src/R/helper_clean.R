library(foreach)
library(doParallel)
library(dplyr)
library(testthat)

get_pout_files <- function(folder, sim_type){
  if sim_type == 'batch'{
    # returns a list of *.pout files from results/simulations/
    batch_experiments <- list.files(batch_folder)
    pout_files <- c()
    for(batch_experiment in batch_experiments){
      pout_path <- paste(batch_folder, batch_experiment, 'output', sep = '/')
      pout_path_file <- paste(pout_path, 'network_of_agents.pout', sep = '/')
      pout_files <- c(pout_files, pout_path_file)
    }
    return(pout_files)
  }

}


get_pout_df <- function(pout_file, activation_value_columns,
                     prototype_value_columns){
    # for a given .pout file, returns a dataframe of the data
    df <- read.csv(pout_file, header = FALSE,
                   na.strings = c("None", " None"), stringsAsFactors=FALSE)
    names(df)[1:5] <- c('time', 'agent', 'numUpdate', 'isUpdated', 'inflId')
    activationValues <- activation_value_columns
    prototype <- prototype_value_columns
    return(df)
}


calculate_sse <- function(row_vector, activation_value_columns,
                          prototype_value_columns){
    activationValues <- row_vector[activation_value_columns]
    prototype <- row_vector[prototype_value_columns]
    difference <- as.numeric(activationValues) - as.numeric(prototype)
    se <- difference ** 2
    sse <- sum(se)
    return(sse)
}


calculate_cosine_sim <- function(row_vector, activation_value_columns,
                                 prototype_value_columns){
    activationValues <- row_vector[activation_value_columns]
    prototype <- row_vector[prototype_value_columns]

    v1 <- as.vector(as.matrix(as.numeric(activationValues) + 1))
    v2 <- as.vector(as.matrix(as.numeric(prototype) + 1))

    cosine <- lsa::cosine(v1, v2)
    return(cosine)
}

#' Clean and stack dataframes of all the simulation runs for a given set
#'
#' @note This function relies on a global variable, reshape_files,
#' that is a matrix of all simulations (rows) for a given set of
#' simulation parameters (columns)
#'
#' @param col_in_sim_set, number, column index from reshape_files
#' @param num_agents, number, represents number of agents in the simulation
#' @param num_ticks, number
#' @param num_sims_per_sim_set, number
#'
get_model_simulation_df <- function(col_in_sim_set, num_agents, num_ticks,
                                    num_sims_per_sim_set){
    # return a df that contains all the simulations for a given parameter set
    # that is all the runs for a given simulation set
#     min       lq     mean   median       uq      max neval
#     59.22262 60.16209 63.55249 60.47024 63.25996 74.64754     5

#     # preallocate data structure
#     # time    ever_updated    avg_sse	avg_cos	run_number
    max_obs <- ((num_agents * num_ticks) + (num_agents * 4)) *
        num_sims_per_sim_set

    df <- data.frame(time = rep(NA, max_obs), ever_updated = rep(NA, max_obs),
                     avg_sse = rep(NA, max_obs), avg_cos = rep(NA, max_obs),
                     run_number = rep(NA, max_obs),
                     delta_value = rep(NA, max_obs),
                     epsilon_value = rep(NA, max_obs))
    start <- 1
    for(j in 1:num_sims_per_sim_set){
        df_value <-get_pout_df(reshape_files[j, col_in_sim_set],
                            activation_value_columns =
                                config_activation_value_columns,
                            prototype_value_columns =
                                config_prototype_value_columns)
        df_name <- letters[j]
        df_value$ever_updated <- ifelse(test = df_value$numUpdate > 0, 1, 0)
        df_value$sse <- apply(df_value, 1, calculate_sse)
        df_value$cos <- apply(df_value, 1, calculate_cosine_sim)

        df_by_time_update <- df_value %>%
            group_by(time, ever_updated) %>%
            summarize(avg_sse = mean(sse), avg_cos = mean(cos)) %>%
            mutate(run_number = j)

        end <- start + nrow(df_by_time_update) - 1

        df[start:end, ] <- df_by_time_update

        start <- end + 1
        # assign(x = df_name, value = df_by_time_update)
    }
    return(na.omit(df))
}

#' Same as get_model_simulation_df, but uses a foreach loop in parallel
#'
get_model_simulation_df_parallel <- function(col_in_sim_set, num_agents,
                                             num_ticks,
                                             num_sims_per_sim_set){
    #####
    ##### for each row of the column, we load the dataframe, manimulate it, and
    ##### add it to a list of dataframes
    #####
    strt <- Sys.time()
    clean_df_1_sim <- foreach(j = c(1:num_sims_per_sim_set),
                              .packages=c('dplyr'),
                              .export=c('get_pout_df', 'reshape_files',
                                        'config_activation_value_columns',
                                        'config_prototype_value_columns',
                                        'calculate_sse')) %dopar% {
        df_1_sim_run <- get_pout_df(pout_file =
                                        reshape_files[j, col_in_sim_set],
                                 activation_value_columns =
                                     config_activation_value_columns,
                                 prototype_value_columns =
                                     config_prototype_value_columns)

        df_1_sim_run$ever_updated <-
            ifelse(test = df_1_sim_run$numUpdate > 0, 1, 0)

        df_1_sim_run$sse <- apply(df_1_sim_run, 1, calculate_sse,
                                  activation_value_columns =
                                      config_activation_value_columns,
                                  prototype_value_columns =
                                      config_prototype_value_columns)

        df_1_sim_run$run_number <- j

        df_1_sim_run

        # turn off cosine similarity because it's results are not intuitive
        # df_1_sim_run$cos <- apply(df_value, 1, calculate_cosine_sim)

#         to_clean_df_1_sim <- df_1_sim_run %>%
#             group_by(time, ever_updated) %>%
#             # summarize(avg_sse = mean(sse), avg_cos = mean(cos)) %>%
#             summarize(avg_sse = mean(sse)) %>%
#             mutate(run_number = j)
#         to_clean_df_1_sim
    }

    print_difftime_prompt('add simulation dataframes to list',
                          Sys.time() - strt)
    # add simulation dataframes to list took: 26.3673622608185 secs

    strt <- Sys.time()
    stacked_df <- do.call("rbind", clean_df_1_sim)
    # plyr::ldply(clean_df_1_sim, rbind) # ldply is MUCH slower
    print_difftime_prompt('stack dataframes in list', Sys.time() - strt)
    # stack dataframes in list took: 0.000382423400878906 secs
    return(stacked_df)
}

get_model_simulation_df_group_avg <- function(df_1_sim_run){
    expect_equal(length(unique(df_1_sim_run$delta_value)), 1)
    expect_equal(length(unique(df_1_sim_run$epsilon_value)), 1)

    delta <- unique(df_1_sim_run$delta_value)
    epsilon <- unique(df_1_sim_run$epsilon_value)

    to_clean_df_1_sim <- df_1_sim_run %>%
        group_by(time, ever_updated, run_number) %>%
        # summarize(avg_sse = mean(sse), avg_cos = mean(cos)) %>%
        summarize(avg_sse = mean(sse)) %>%
        mutate(delta_value = delta, epsilon_value = epsilon)
    return(to_clean_df_1_sim)
}
