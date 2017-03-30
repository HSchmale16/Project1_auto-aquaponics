# setup.R

for(x in c('DT', 'shiny', 'shinydashboard', 'plotly', 'DBI', 'dplyr', 'ggplot2', 'rjson')){
  install.packages(x, repos='http://cran.us.r-project.org')
}
