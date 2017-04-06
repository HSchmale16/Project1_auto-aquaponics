#!/usr/bin/env Rscript
# setup.R

# pkgs <- c('DT', 'shiny', 'shinydashboard', 'plotly', 'DBI', 
#           'dplyr', 'ggplot2', 'rjson', 'RSQLite')
for(x in pkgs){
  install.packages(x, repos='http://cran.us.r-project.org')
}
