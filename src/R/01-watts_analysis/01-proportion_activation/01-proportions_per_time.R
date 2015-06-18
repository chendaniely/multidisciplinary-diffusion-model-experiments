library(stringr)
library(readr)
library(dplyr)
library(ggplot2)
library(scales)

get_batch_folder <- function(){
    args <- commandArgs(trailingOnly = TRUE)
    if (length(args) == 0){
        return('../../../../results/simulations/01-watts_batch_2015-06-15_20:01:08')
    } else {
        return(args[1])
    }
}

get_sim_param <- function(pout_file_path){
    batch_folder_name <- str_extract(pout_file_path, 'a[:digit:]*_r[:digit:]*')
    params <- str_split(batch_folder_name, '_', )

    num_agents <- substr(params[[1]][1],
                         start = 2,
                         stop = nchar(params[[1]][1])) %>%
        as.numeric()

    run_number <- substr(params[[1]][2],
                         start = 2,
                         stop = nchar(params[[1]][2])) %>%
        as.numeric()

    return(list(num_agents = num_agents,
                run_number = run_number))
}

analyze_prop_single <- function(pout_file_path){
    df <- read_csv(pout_file_path,
                   col_names = c('time', 'agent', 't_num_update',
                                 'up_state', 'state'))
    sim_params <- get_sim_param(pout_file_path)

    prop <- df %>%
        group_by(time) %>%
        summarize(total_1 = sum(state),
                  prop_1 = total_1 / n()) %>%
        mutate(run_number = sim_params$run_number[1])

    return(prop)
}

main <- function(){
    batch_folder_name <- get_batch_folder()
    print(sprintf("Getting data from: %s", batch_folder_name))

    print("Getting individual simulation folders")
    sims <- dir(path = batch_folder_name,
                pattern = '^a',
                full.names = TRUE,
                recursive = FALSE)

    print("Getting individual simulation .pout files")
    pout_files <- sapply(X = paste0(sims, '/output'),
                         FUN = list.files,
                         pattern = '*.pout',
                         full.names = TRUE)

    print("Combining proportion of 1 for each for simulations")
    d <- do.call(rbind,
                 lapply(X = pout_files,
                        FUN = analyze_prop_single))

    print("Creating plot")
    g <- ggplot(data = d) +
        geom_line(aes(x = time,
                      y = prop_1,
                      color = as.factor(run_number))) +
        scale_y_continuous(labels = percent) +
        scale_x_continuous(labels = comma) +
        scale_color_discrete(guide = FALSE) +
        xlab("Time") +
        ylab("Proportion of 1") +
        theme_bw()

    g_y_all <- g + scale_y_continuous(limit = c(0, 1))

    output_dir = paste0(batch_folder_name, '/batch_output')
    plot_file_path = paste0(output_dir, '/prop_1.png')
    dir.create(file.path(batch_folder_name, 'batch_output'), showWarnings = FALSE)

    ggsave(filename = plot_file_path,
           plot = g)
    #     png(filename = plot_file_path)
    #     g
    #     dev.off()
    print(sprintf("Plot saved in: %s", plot_file_path))

    # subset of the plot
    #     g + scale_x_continuous(limit = c(0, 25)) +
    #         scale_y_continuous(limit = c(0, .06)) +
    #         theme_bw()
    #
    #     d_subset <- d[d$time == 10, ]
    #     ggplot(data = d_subset) +
    #         geom_histogram(aes(x = prop_1), binwidth = .0001) +
    #         theme_bw()
    #
    #     dim(d_subset)
    #     plot(d_subset$total_1)
    #     length(unique(d_subset$total_1))
}

main()
