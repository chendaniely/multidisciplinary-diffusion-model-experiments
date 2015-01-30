library(shiny)
library(ggplot2)
library(scales)
library(foreach)
library(doParallel)

source(file = '../helper.R')
source(file = '../helper_config.R')
source(file = 'helper_shiny.R')

source(file = '../../analysis_config.R')

base_folder_path <- paste0('../../',
                           config_batch_folder_path)

list_stacked_df_grouped_path <- paste0(base_folder_path,
                                       '_df_grouped_runs_list.RData')
list_only_updated_melt_path <-
    paste0(base_folder_path,
           '_df_stacked_runs_updated_melt_list.RData')

list_only_updated_melt_sub_proto_path <-
    paste0(base_folder_path,
           '_df_stacked_runs_updated_melt_list_sub_proto.RData')

shinyServer(function(input, output) {
    #
    # Enviornment of stuff that can be passed into different renderPlot calls
    #
    plot_env <- new.env()

    ###########################################################################
    # Load datasets needed reactively
    ###########################################################################

    strt <- Sys.time()
    # load list_stacked_df_grouped
    load(list_stacked_df_grouped_path)
    print_difftime_prompt('load grouped data', diff_time = Sys.time() - strt)

    strt <- Sys.time()
    # load list_only_updated_melt
    load(list_only_updated_melt_path)
    print_difftime_prompt('load stacked updated only long data',
                          diff_time = Sys.time() - strt)

    strt <- Sys.time()
    # load list_only_updated_melt_sub_proto
    load(list_only_updated_melt_sub_proto_path)
    print_difftime_prompt('load list_only_updated_melt_sub_proto',
                          diff_time = Sys.time() - strt)

    ###########################################################################
    # Create Faceted Plots
    # Average SSE of agents who have been updated over time
    # Faceted by Delta and Epsilon
    # This plot will be used to pick a delta/epsilon simulation to zoom later
    ###########################################################################
#     cl <- makeCluster(config_num_cores)
#     registerDoParallel(cl)

    starts <- seq(from = 1, to = ncol(reshape_files),
                  by = config_num_parameter_sets_no_a)
    strt <- Sys.time()
    plots_facet <- foreach(i = 1:length(starts), .packages=c('ggplot2'),
                           .export=c('config_num_parameter_sets_no_a')) %do% {
        start <- starts[i]
        end <- start + config_num_parameter_sets_no_a - 1
        df_all_n <- plyr::ldply(list_stacked_df_grouped[start:end], data.frame)
        g <- ggplot(df_all_n[df_all_n$ever_updated == 1, ],
                    aes(time, color = as.factor(run_number))) +
            theme_bw() +
            theme(legend.position="none") +
            geom_line(aes(y = avg_sse)) + scale_y_continuous(limits=c(0, 20)) +
            theme(axis.text.x=element_text(angle = -90, hjust = 0)) +
            facet_grid(delta_value~epsilon_value, labeller = label_both)
        g
    }
    print(sprintf("number of faceted plots generated: %s",
                  length(plots_facet)))
    print_difftime_prompt('generate faceted plots',
                          diff_time = Sys.time() - strt)

#     stopCluster(cl)
#     registerDoSEQ()


    # Expression that generates a plot The expression is
    # wrapped in a call to renderPlot to indicate that:
    #  1) It is "reactive" and therefore should re-execute automatically
    #     when inputs change
    #  2) Its output type is a plot

    ###########################################################################
    #
    # PLOT 1
    #
    # Plot of all experiment runs faceted by delta and epsilon
    #
    output$facet_plots <- renderPlot({
        plots_facet[1]
    })

    ###########################################################################
    #
    # This reactive call will capture which delta epsilon experiment to show
    # it will save this go plot g
    # where it will first plot just the facet cell // todo
    # then plot the PU for each simulation run
    # and the sliders will react and zoom into the x and y axis accordingly
    #
    getFacetCells <- reactive({
        # the way list_stacked_df_grouped is ordered,
        # epsilon increases first then delta
        delta_picked <- input$select_subplot_delta
        epsilon_picked <- input$select_subplot_epsilon
        print(sprintf('delta value picked: %s; epsilon value picked: %s',
                      delta_picked, epsilon_picked))
        return_value <- c(delta_picked, epsilon_picked)
        return(return_value)
    })

    ###########################################################################
    #
    # PLOT 2
    #
    # Selected cell in faceted plot
    #
    output$selected_facet <- renderPlot({
        input$goPick
        plot_index <- plot_index_from_d_e(isolate(getFacetCells()))
        print(sprintf('subsetting plot #%s', plot_index))
        picked_df <- list_stacked_df_grouped[[plot_index]]

        strt <- Sys.time()
        g1 <- ggplot(data = picked_df[picked_df$ever_updated == 1, ]) +
            theme_bw() +
            geom_line(aes(x = time, y = avg_sse,
                          color=as.factor(run_number))) +
            theme(axis.text.x = element_text(angle=90, vjust=0.5)) +
            scale_color_discrete(name = 'Run')
        print_difftime_prompt('create ggplot object',
                              diff_time = Sys.time() - strt)

        input$goVline
        draw_vline <- isolate(input$vlineRadio)
        if(draw_vline == 1){
            lower_vline <-isolate(as.numeric(input$vline_draw[[1]]))
            upper_vline <-isolate(as.numeric(input$vline_draw[[2]]))
            print(g1 +
                      geom_vline(xintercept = lower_vline) +
                      geom_vline(xintercept = upper_vline))
        } else{
            strt <- Sys.time()
            print(g1)
            print_difftime_prompt('show ggplot object',
                                  diff_time = Sys.time() - strt)
        }
        plot_env$sse_plot <- g1

    })

    ###########################################################################
    #
    # PLOT 3
    #
    output$selected_facet_pu_run <- renderPlot({
        input$goPick
        plot_index <- plot_index_from_d_e(isolate(getFacetCells()))
        print(sprintf('subsetting plot #%s', plot_index))

        strt <- Sys.time()
        g1 <- ggplot(data = list_only_updated_melt[[plot_index]]) +
            theme_bw() +
            geom_line(aes(x = time, y = value, color=variable)) +
            facet_grid(run_number~variable) +
            theme(legend.position="none",
                  axis.text.x = element_text(angle=90, vjust=0.5)) +
            scale_x_continuous(breaks=pretty_breaks()) +
            scale_y_continuous(limits = c(0, 1))
        print_difftime_prompt('create ggplot object',
                              diff_time = Sys.time() - strt)

        strt <- Sys.time()
        print(g1)
        print_difftime_prompt('show ggplot object',
                              diff_time = Sys.time() - strt)
        plot_env$pu_plot <- g1
    })

    output$selected_facet_minus_proto_run <- renderPlot({
        input$goPick
        plot_index <- plot_index_from_d_e(isolate(getFacetCells()))
        print(sprintf('subsetting plot #%s', plot_index))

        strt <- Sys.time()
        g2 <- ggplot(data = list_only_updated_melt_sub_proto[[plot_index]]) +
            theme_bw() +
            geom_line(aes(x = time, y = value, color=variable)) +
            facet_grid(run_number~variable) +
            theme(legend.position="none",
                  axis.text.x = element_text(angle=90, vjust=0.5)) +
            scale_x_continuous(breaks=pretty_breaks()) +
            scale_y_continuous(limits = c(-1, 1))
        print_difftime_prompt('create ggplot object',
                              diff_time = Sys.time() - strt)

        strt <- Sys.time()
        print(g2)
        print_difftime_prompt('show ggplot object',
                              diff_time = Sys.time() - strt)
        plot_env$proto_minus_plot <- g2
    })

    ###########################################################################
    #
    # PLOT 4
    #
    output$selected_facet_zoom <- renderPlot({
        input$goZoom
        strt <- Sys.time()
        g1_sub <- plot_env$sse_plot +
            scale_y_continuous(limits=isolate(input$sse_adjust),
                               breaks=pretty_breaks()) +
            scale_x_continuous(limits=isolate(input$time_adjust),
                               breaks=pretty_breaks())
        print_difftime_prompt('create sse ggplot object subset x/y-axis',
                              diff_time = Sys.time() - strt)

        strt <- Sys.time()
        print(g1_sub)
        print_difftime_prompt('show sse ggplot object subset x/y-axis',
                              diff_time = Sys.time() - strt)

    }, env=plot_env)

    ###########################################################################
    #
    # PLOT 5
    #
    output$selected_facet_pu_run_zoom <- renderPlot({
        input$goZoom
        strt <- Sys.time()
        g1_sub <- plot_env$pu_plot +
            scale_y_continuous(limits=isolate(input$activation_adjust),
                               breaks=pretty_breaks()) +
            scale_x_continuous(limits=isolate(input$time_adjust),
                               breaks=pretty_breaks())
        print_difftime_prompt('create pu ggplot object subset x/y-axis',
                              diff_time = Sys.time() - strt)

        strt <- Sys.time()
        print(g1_sub)
        print_difftime_prompt('show pu ggplot object subset x/y-axis',
                              diff_time = Sys.time() - strt)

    }, env=plot_env)

    output$selected_facet_minus_proto_run_zoom <- renderPlot({
        input$goZoom
        strt <- Sys.time()
        g2_sub <- plot_env$proto_minus_plot +
            scale_y_continuous(limits=isolate(input$minus_proto_adjust),
                               breaks=pretty_breaks()) +
            scale_x_continuous(limits=isolate(input$time_adjust),
                               breaks=pretty_breaks())
        print_difftime_prompt('create pu ggplot object subset x/y-axis',
                              diff_time = Sys.time() - strt)

        strt <- Sys.time()
        print(g2_sub)
        print_difftime_prompt('show pu ggplot object subset x/y-axis',
                              diff_time = Sys.time() - strt)

    }, env=plot_env)

    ###########################################################################
}) # close shinyServer({})
