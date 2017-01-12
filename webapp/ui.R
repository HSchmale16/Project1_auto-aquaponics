# ui.R for Autoaquaponics
# Henry J Schmale
#
#

library(shiny)
library(DT)

shinyUI(fluidPage(

  # Application title
  titlePanel("Automated Aquaponics Dashboard"),
  mainPanel(
    tabsetPanel(
      # Panel Displaying all of the plots with a time
      # range selection
      tabPanel("Plots", sidebarLayout(
        sidebarPanel(
          radioButtons(
            "timerange", "Time Range To Display",
            choices = c(
              "All Time" = 'vSensorReadings',
              "Last 30 Days" = 'vLast30DaysReadings',
              "Last 7 Days" = 'vLast7DaysReadings'
            ),
            selected = 'vLast7DaysReadings'
          )
        ),
        mainPanel(
          verbatimTextOutput('text'),
          tableOutput('NewReadings')
        )
      )),
      # Tab for configuring pump and lights schedule
      tabPanel("Schedule Configuration", mainPanel(
        DT::dataTableOutput('schedule', width='100%'),
        verbatimTextOutput('selectedInfo')
      ))
    )
  )
))
