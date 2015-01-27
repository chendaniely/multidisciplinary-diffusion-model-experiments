library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Multi-Agent Neural-Network Simulation Visualizer"),

    # Sidebar with a slider input for the number of bins
    sidebarLayout(
        sidebarPanel(
            h3("Complete Simulation"),
            selectInput("select", label = "Select Plot",
                        choices = list("1" = 1, "2" = 2, "3" = 3),
                        selected = 1),

            h3("Simulation Picker"),
            selectInput("select_subplot_delta", label = "Select Plot Delta",
                        choices = list("0%" = 1, "25%" = 2, "50%" = 3,
                                       "75%" = 4, "100%" = 5)),
            selectInput("select_subplot_epsilon", label = "Select Plot Epsilon",
                        choices = list("0%" = 1, "10%" = 2, "20%" = 3,
                                       "30%" = 4, "40%" = 5, "50%" = 6),
                        selected = 1),
            actionButton("goPick", "Pick!"),

            h3("Simulation Zoomer"),
            sliderInput("sse_adjust", label = "Sum Square Error Zoom",
                        min = 0, max = 20, value = c(0, 20), step = .5),

            sliderInput("activation_adjust", label = "Activation Value Zoom",
                        min = 0, max = 1, value = c(0, 1), step = .05),

            sliderInput("time_adjust", label = "Time Range Zoom",
                        min = 0, max = 10000, value = c(100, 1000), step = 50),
            actionButton("goZoom", "Zoom!")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("facet_plots"),
            plotOutput("selected_facet"),
            plotOutput("selected_facet_pu_run"),
            plotOutput("selected_facet_zoom"),
            plotOutput("selected_facet_pu_run_zoom")
        )
    )
))
