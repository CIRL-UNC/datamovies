
###########################################################################
#
# Purpose: Demonstrate data movie code in R
#
# Author: Jacqueline Rudolph
#
# Last Update: 24 Jan 2023
#
###########################################################################

# Steps:
#   (1) Edit the input and output file paths in the code below.
#   (2) Download and read in the example data set.
#   (3) Adjust the formatting of the data movie as needed.
#   (4) Run the code to produce the data movie.

# Notes:
#   The code generates the Histogram and Line Plot movies from the datamovies.sas file.
#   At the bottom, we include a different animation function in gganimate, that loops over
#      which part of the data is highlighted.
#   All data movies are output in .gif format.
#      To our knowledge, gganimate cannot output .svg files.


# Load packages -----------------------------------------------------------

# Packages used in this demonstration:
#     tidyverse -- for reading in data and simple data management
#     ggplot2 -- create panels of data movie
#     gganimate -- specify data movie parameters 
#         - gganimate can be used to build many types of data movies
#         - For more information, see: <https://gganimate.com/>
#     gifski -- used to render the GIF file

packages <- c("tidyverse", "gganimate", "gifski")
for (package in packages) {
  library(package, character.only=T)
}


# Read in data ------------------------------------------------------------

data <- read_csv("./AtlasPlusTableData.csv") %>% 
  mutate(raceth = factor(raceth),
         sex = factor(sex, levels=c("Male", "Female")),
         age = factor(age),
         year = as.integer(year)) %>% 
  # Data movies produced for demonstration purposes only. 
  # Diagnoses among Asian, American Indian/Alaska Native, 
  # Native Hawaiian/Pacific Islander, and multiracial individuals not shown.
  filter(raceth %in% c("Black/African American", "Hispanic/Latino", "White"))


# Format plots ------------------------------------------------------------

# Customize the formatting of the data movies as desired
thm <- theme_classic() +
  theme(
    # Format plot title
    plot.title = element_text(size=16, color="black"),
          
    # Format axes
    axis.title = element_text(size=16, color="black"),
    axis.text.y = element_text(size=14, color="black"),
    axis.text.x = element_text(size=14, color="black", angle=45, hjust=1),

    # Format legend
    legend.text = element_text(size=14, color="black", margin=margin(t=0.25,b=0.25, unit="lines")),
    legend.title = element_text(size=16, color="black"),
    legend.title.align = 0.5,
    legend.position = "bottom",
    legend.background = element_rect(fill = "transparent", colour = NA),
    legend.key = element_rect(fill = "transparent", colour = NA),
    legend.direction = "horizontal",
    
    #Format facet title
    strip.text = element_text(size=16, color="black"),
    strip.background = element_blank(),
    panel.border = element_rect(size=0.75, fill=NA)
  )

# Specify size of figure in inches
h <- 5 # Height
w <- 7 # Width

# Specify start and stop times
start_time <- min(data$year)
end_time <- max(data$year)


# Type 1: Histogram -------------------------------------------------------

# This code generates a plot showing the number of HIV diagnoses at different age categories 
#   - If the x-axis variable is categorical like age in the example data, use geom_bar() or geom_col()
#   - If the x-axis variable is continuous, use geom_histogram()
# There are two options for animating how the plots change over time
#   - transition_time() -- will interpolate intermediate steps between time points
#   - transition_state() -- can be used with or without interpolation between states
# Other features included in figure:
#   -facet_wrap() produces multipanel figure by binary sex
#   -fill=raceth shows counts by race/ethnicity group

# Variables in data <variable type>:
  # year <integer w/ range [2008, 2019]>
  # age <factor w/ 5 levels>
  # raceth <factor w/ 3 levels>
  # sex <factor w/ 2 levels>

# Bar chart with interpolation between time points:
plot <- ggplot(data=data, aes(x=age, y=diagnoses, fill=raceth)) + thm +
  theme(plot.title = element_text(size=20, color="gray", hjust=0.97, vjust=-12)) +
  labs(x="Age group", y="Number of HIV diagnoses", fill="",
       title="{frame_time}") + # Show year in plot title
  geom_col() + 
  scale_y_continuous(expand=c(0, 0)) +
  scale_fill_manual(values=c("#34ace0", "#ffb142", "#ff5252")) +
  facet_wrap(vars(sex)) +
  # All steps from here on create the movie
  transition_time(time=year, 
                  range=c(start_time, end_time))
animate(plot, height=h, width=w, units="in", res=300, renderer=gifski_renderer(loop = TRUE))
anim_save(paste0("./histogram.gif"))

# Bar chart without interpolation between time points:
plot <- ggplot(data=data, aes(x=age, y=diagnoses, fill=raceth)) + thm +
  theme(plot.title = element_text(size=20, color="gray", hjust=0.97, vjust=-12)) +
  labs(x="Age group", y="Number of HIV diagnoses", fill="",
       title="{closest_state}") + # Show year in plot title
  geom_col() + 
  scale_y_continuous(expand=c(0, 0)) +
  scale_fill_manual(values=c("#34ace0", "#ffb142", "#ff5252")) +
  facet_wrap(vars(sex)) +
  # All steps from here on create the movie
  transition_states(states=as.factor(year), 
                    transition_length=0, # Immediate transitions
                    state_length=1, # How long each frame is
                    wrap=T)
animate(plot, height=h, width=w, units="in", res=300, renderer=gifski_renderer(loop = TRUE))
anim_save(paste0("./histogram.gif"))


# Type 2: Line plot -------------------------------------------------------

# This code generates a plot showing the rate of HIV diagnoses by  age group 
#   - To create a line plot, we use geom_line()
# For this example, we will just use transition_state()
#   - See example above for how to use transition_time()
# Other features included in figure:
#   -facet_wrap() produces multipanel figure by binary sex
#   -fill=raceth shows counts by race/ethnicity group

# Line plot without interpolation between time points:
plot <- ggplot(data=data, aes(x=age, y=rate, color=raceth, group=raceth)) + thm +
  theme(plot.title = element_text(size=20, color="gray", hjust=0.97, vjust=-12)) +
  labs(x="Age group", y="HIV diagnoses per 100,000 population", color="",
       title="{closest_state}") + # Show year in plot title
  geom_line(size=1) + 
  scale_y_continuous(expand=c(0, 0), limits=c(0, 160), breaks=seq(0, 150, 25)) +
  scale_color_manual(values=c("#34ace0", "#ffb142", "#ff5252")) +
  facet_wrap(vars(sex)) +
  # All steps from here on create the movie
  transition_states(states=as.factor(year), 
                    transition_length=0, # Immediate transitions
                    state_length=1, # How long each frame is
                    wrap=T)
animate(plot, height=h, width=w, units="in", res=300, renderer=gifski_renderer(loop = TRUE))
anim_save(paste0("./line.gif"))


# Extra Movie: Highlight data ---------------------------------------------

# This example is not included in datamovies.sas and does not use the example data
# This code generates a plot showing the proportion of observations
#   that are assigned to 8 groups over calendar time. 
# The code uses transition_filter() to loop over which trend line is being higlighted

# Variables in data:
  # time <numeric w/ range [2007, 2019]>
  # group <factor w/ 8 levels>
  # prop <continuous numeric w/ range [0, 0.5]>

plot <- ggplot(data=data, aes(x=time, y=prop, color=group)) + thm +
  labs(title="Group {closest_filter}", # Show group being highlighted in plot title
       x="\nCalendar Year", y="Proportion of Observations\n", color="Group") +
  geom_line(size=1) +
  scale_x_continuous(breaks=seq(2007, 2019, 1)) +
  scale_y_continuous(breaks=seq(0.0, 0.5, 0.1), limits=c(0, 0.5)) +
  scale_color_brewer(palette="Dark2") +
  guides(color=guide_legend(nrow=1)) +
  # All steps from here on create the movie
                   # How long should transition between groups be?
  transition_filter(transition_length = 0, 
                    # How long does animation stay on group?
                    filter_length = 80,    
                    # Specify frame and what that frame filters on
                    "1" = group==1,        
                    "2" = group==2,
                    "3" = group==3,
                    "4" = group==4,
                    "5" = group==5,
                    "6" = group==6,
                    "7" = group==7,
                    "8" = group==8,
                    # Does previous group stay in plot after moving to the next group?
                    keep=TRUE,             
                    # Does the animation wrap around? 
                        # Here the answer is "no" because we want the animation 
                        # to loop but restart from a blank slate
                    wrap=FALSE) +  
  # What happens to a group after we move to the next group?
            # It becomes more transparent
  exit_fade(alpha = 0.25)
# Generate the animation
animate(plot, height=5, width=6, units="in", res=300, renderer=gifski_renderer(loop = TRUE))
# Save the movie to your computer
anim_save(paste0("file_path_location.gif"))

