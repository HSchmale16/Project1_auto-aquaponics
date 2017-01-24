# ui.R for Autoaquaponics
# Henry J Schmale
#
#

library(shiny)
library(DT)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = 'Automated Aquaponics Dashboard'),
  dashboardSidebar(
    radioButtons(
      "timerange", "Time Range To Display",
      choices = c(
        "All Time" = 'vSensorReadings',
        "Last 30 Days" = 'vLast30DaysReadings',
        "Last 7 Days" = 'vLast7DaysReadings'
      )
    )
  ),
  dashboardBody(
    tabsetPanel(
      tabPanel("Plots"
        
      ),
      tabPanel("Schedule Configuration", mainPanel(
          DT::dataTableOutput('schedule', width='100%')
        )
      )
    )
  )
)