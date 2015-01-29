library(shiny)
library(stringr)

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

config_time_adjust_step <- 50

data_files <- list.files('../../../results/simulations/',
                         pattern = '_df_stacked_runs_updated_melt_list.RData',
                         recursive = TRUE,
                         full.names = TRUE)

data_files <- list(data_files)
data_files_names <- as.character(data_files)
data_files_names <- sapply(X = data_files_names, FUN = get_only_file_name)
data_files_names <- sapply(X = data_files_names, FUN = get_simplified_file_name)
data_files <- data_files_names
names(data_files) <- as.character(data_files_names)
data_files

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Multi-Agent Neural-Network Simulation Visualizer"),

    # Sidebar with a slider input for the number of bins
    sidebarLayout(
        sidebarPanel(
            h3("Simulation Picker"),
            selectInput("select", label = "Select Plot",
                        choices = data_files),
            actionButton("goData", "Load Dataset"),

            h3("Parameter Picker"),
            selectInput("select_subplot_delta", label = "Select Plot Delta",
                        choices = list("0%" = 1, "25%" = 2, "50%" = 3,
                                       "75%" = 4, "100%" = 5)),
            selectInput("select_subplot_epsilon", label = "Select Plot Epsilon",
                        choices = list("0%" = 1, "10%" = 2, "20%" = 3,
                                       "30%" = 4, "40%" = 5, "50%" = 6),
                        selected = 1),
            actionButton("goPick", "Pick!"),

            h4("Draw Vertical lines"),
            p("Vertical lines can indicate where the plot will be subset"),
            radioButtons("vlineRadio", label = "Draw vline for on plot?",
                         choices = list("Yes" = 1, "No" = 2),
                         selected = 2),

            sliderInput("vline_draw", label = "vline draw range",
                        min = 0, max = 10000, value = c(100, 1000),
                        step = config_time_adjust_step),
            actionButton("goVline", "Draw Vline"),

            h3("Simulation Zoomer"),
            sliderInput("sse_adjust", label = "Sum Square Error Zoom",
                        min = 0, max = 20, value = c(0, 20), step = .5),

            sliderInput("activation_adjust", label = "Activation Value Zoom",
                        min = 0, max = 1, value = c(0, 1), step = .05),

            sliderInput("time_adjust", label = "Time Range Zoom",
                        min = 0, max = 10000, value = c(100, 1000),
                        step = config_time_adjust_step),
            actionButton("goZoom", "Zoom!")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            h2("Complete Simulation"),
            plotOutput("facet_plots"),
            h2("Selected Parameter Set"),
            plotOutput("selected_facet"),
            plotOutput("selected_facet_pu_run"),
            h2("Selected Parameter Set Zoomed"),
            plotOutput("selected_facet_zoom"),
            plotOutput("selected_facet_pu_run_zoom")
        )
    )
))
