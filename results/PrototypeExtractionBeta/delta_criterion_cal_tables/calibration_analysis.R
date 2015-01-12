library(ggplot2)
delta_calibration_tables <- read.csv("~/Desktop/delta_calibration_tables.csv",
                                     stringsAsFactors=FALSE)

data <- delta_calibration_tables

# plot number of epochs



# plot errors
ggplot(data = data, aes(x=epochs)) + geom_histogram(binwidth=100) +  facet_grid(~delta)

ggplot(data = data[data$delta == 0.5, ], aes(x=error)) + geom_histogram()

ggplot(data = data[data$], aes(x=epochs)) + geom_histogram(binwidth=1000) +
  scale_x_continuous(breaks = round(seq(min(data$epochs),
                                        max(data$epochs),
                                        by = 1000),
                                    1000)) +
  theme(axis.text.x=element_text(angle = -90, hjust = 0))
