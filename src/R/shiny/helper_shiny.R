plot_index_from_d_e <- function(vector_d_e){
    vector_d_e_num <- as.numeric(vector_d_e)
    d <- vector_d_e_num[1]
    e <- vector_d_e_num[2]
    x <- config_num_epsilon_values

    expect_true(e <= config_num_epsilon_values)
    return_value <- (d * x) - x + e

    expect_true(return_value <= config_num_delta_values * config_num_epsilon_values)
    return(return_value)
}

get_data_sets <- function(vector_datasets){
    print('loading datasets')
    strt <- Sys.time()
    # load list_stacked_df_grouped
    load(vector_datasets[1])
    print_difftime_prompt('load grouped data', diff_time = Sys.time() - strt)

    strt <- Sys.time()
    # load list_only_updated_melt
    load(vector_datasets[2])
    print_difftime_prompt('load stacked updated only long data',
                          diff_time = Sys.time() - strt)
}

###############################################################################
# Functions used in ui.R
###############################################################################
get_only_file_name <- function(full_file_name){
    split_string <- str_split(string = full_file_name, pattern = '/')
    last_item <- length(split_string[[1]])
    return(split_string[[1]][[last_item]])
}

get_simplified_file_name <- function(file_name){
    file_name <- str_replace(string = file_name,
                             pattern = '[a-zA-Z]{0,4}[0-9]{2}-.*_batch_',
                             replacement = '')
    file_name

    file_name <- str_split(string = file_name, pattern = '_df_')[[1]][1]
    file_name

    file_name <- str_replace(string = file_name,
                             pattern = '\\.RData', replacement = '')
    file_name

    file_name <- str_replace_all(string = file_name,
                                 pattern = '_', replacement = '-')
    file_name
}

get_base_file_path <- function(file_name_path){
    file_name <- str_split(string = file_name_path, pattern = '_df_')[[1]][1]
    file_name
}
