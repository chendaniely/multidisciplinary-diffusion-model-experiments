print_difftime_prompt <- function(str_what_did_you_time, diff_time, sep=':'){
    parse_time <- unclass(diff_time)[1]
    parse_units <- attr(unclass(diff_time), 'units')
    prompt_string <- sprintf('%s took: %s %s', str_what_did_you_time, parse_time, parse_units)
    cat(prompt_string, '\n')
    # return(prompt_string)
}
