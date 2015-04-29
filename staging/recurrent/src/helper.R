################################################################################
#
# Preping data functions
#
################################################################################
#' parse columns from the link.values dataframe such that
#' a separate column represents the influencing node type, influencing node
#' index, and link (weight) value between the link
#' note: links unidirectional
parse_link_values_file <- function(link_values_file_df){
    link_values <- link_values_file_df

    link_values$from <-sapply(str_split(link_values$V1, '->'), "[[", 1)
    link_values$to <-sapply(str_split(link_values$V1, '->'), "[[", 2)
    dim(link_values)

    link_values$j_type <-sapply(str_split(link_values$from, ':'), "[[", 1)
    link_values$j_value <-sapply(str_split(link_values$from, ':'), "[[", 2)
    dim(link_values)

    link_values$i_type <-sapply(str_split(link_values$to, ':'), "[[", 1)
    link_values$i_value <-sapply(str_split(link_values$to, ':'), "[[", 2)
    dim(link_values)

    return(link_values)
}

get_same_bank_df <- function(link_values_df){
     same_bank <- link_values_df[link_values_df$j_type == 'Input' &
                                link_values_df$i_type == 'Input', ]
     return(same_bank)
}

get_same_bank_sub_df <- function(same_bank_df,
                                 cols = c('j_value', 'i_value', 'weights')){
    return(same_bank_df[, cols])
}

reshape_weights_df <- function(df, value_var = 'weights'){
    wide <- dcast(df, i_value ~ j_value, value.var = value_var)
    wide
    row.names(wide) <- wide$i_value
    wide <- wide[, !names(wide) %in% c('i_value')]
    return(wide)
}

sort_rows_columns_df <- function(df){
    column_order <- order_vector_index(names(df))
    df <- df[, column_order]
    row_order <- order_vector_index(row.names(df))
    df <- df[row_order, ]
    return(df)
}

order_vector_index <- function(unsorted){
    sorted <- sort(as.numeric(unsorted))
    sorted_order <- sapply(sorted, function(x){pattern <- sprintf('^%s$', x);
                                               grep(pattern, unsorted)})
    return(sorted_order)
}

randomize_weights <- function(link_values_df,
                              name_of_weight_column,
                              randomize_min,
                              randomize_max){
    link_values_df[, name_of_weight_column] <-
        apply(link_values_df, 1, function(x){
            round(runif(1, -10, 10), 4)
        })
    return(link_values_df)
}

get_opposite_bank_df <- function(link_values_df,
                                 weight_col_name = 'weights',
                                 keep = 'odd',
                                 randomize_weights = FALSE,
                                 randomize_min = -10,
                                 randomize_max = 10){
    opposite_bank <- link_values[link_values$j_type == 'InputMirror' &
                                 link_values$i_type == 'Input', ]
    opposite_bank

    opposite_bank_sub <- opposite_bank[, c('j_value', 'i_value', 'weights')]
    opposite_bank_sub

    if(randomize_weights == TRUE){
    opposite_bank_sub[, weight_col_name] <-
        apply(opposite_bank_sub, 1,
              function(x){
                  runif(n = 1,
                        min = randomize_min,
                        max = randomize_max)
              })
    }
    if(keep == 'odd'){
        keep_rows <- seq(1, nrow(opposite_bank_sub), 2)
    } else{
        keep_rows <- seq(2, nrow(opposite_bank_sub), 2)
    }
    weights_opposite_bank <- opposite_bank_sub[keep_rows, ]
    return(weights_opposite_bank)
}

get_hidden_bank_df <- function(link_values_df,
                               weight_col_name = 'weights',
                               randomize_weights = FALSE,
                               randomize_min = -10,
                               randomize_max = 10){
    hidden_bank <- link_values_df[link_values_df$j_type == 'Hidden' &
                                  link_values$i_type == 'Input', ]
    hidden_bank

    hidden_bank_sub <- hidden_bank[, c('j_value', 'i_value', 'weights')]
    hidden_bank_sub

    if(randomize_weights == TRUE){
        hidden_bank_sub[, weight_col_name] <-
            apply(hidden_bank_sub, 1,
                  function(x){
                      runif(n = 1,
                            min = randomize_min,
                            max = randomize_max)
                  })
    }
    weights_hidden_bank <- hidden_bank_sub
}
