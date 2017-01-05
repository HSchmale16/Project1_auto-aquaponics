# ui.R for Autoaquaponics
# Henry J Schmale
#
#

library(shiny)
library(DT)

shinyUI(fluidPage(

  # Application title
  titlePanel("Automated Aquaponics"),
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("timerange", label=h3("Time Period"),
                   choices = list(
                     "All Time" = 1, "Last 7 Days" = 2, "Last 30 Days" = 3
                   ),
                   selected = 0)
    ),

    mainPanel(
    )
  )
))
