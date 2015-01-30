print_difftime_prompt <- function(str_what_did_you_time, diff_time, sep=':'){
    parse_time <- unclass(diff_time)[1]
    parse_units <- attr(unclass(diff_time), 'units')
    prompt_string <- sprintf('%s took: %s %s', str_what_did_you_time, parse_time, parse_units)
    cat(prompt_string, '\n')
    # return(prompt_string)
}

load_file <- function(file_suffix){
    print(sprintf('load %s', file_suffix))
    file_path <- paste0(config_batch_folder_path, file_suffix)

    strt <- Sys.time()
    # load list_stacked_df
    load(file = file_path, envir = globalenv())
    print_difftime_prompt(sprintf('load %s', file_suffix),
                          diff_time = Sys.time() - strt)
}
