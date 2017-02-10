# ui.R for Autoaquaponics
# Henry J Schmale
#
#

library(shiny)
library(DT)
library(shinydashboard)
library(plotly)
library(rjson)

constraints <<- fromJSON(file = '../config/constraints.json')

dashboardPage(
  dashboardHeader(title = 'Automated Aquaponics Dashboard'),
  dashboardSidebar(
    radioButtons(
      "timerange", "Time Range To Display",
      choices = c(
        "All Time"     = 'vSensorReadings',
        "Last 30 Days" = 'vLast30DaysReadings',
        "Last 7 Days"  = 'vLast7DaysReadings'
      )
    )
  ),
  dashboardBody(
    tabsetPanel(
      tabPanel("Plots",
        fluidRow(
          # Place Value Boxes For Newest Readings Here
          infoBoxOutput('bHumidity', 3),
          infoBoxOutput('bAirTemp', 3),
          infoBoxOutput('bWaterTemp', 3),
          infoBoxOutput('bWaterLevel', 3)
        ),
        fluidRow(
          column(6, plotlyOutput('pWaterLvl')),
          column(6, plotlyOutput('pHumidity'))
        ),
        fluidRow(
          column(6, plotlyOutput('pWaterTemp')),
          column(6, plotlyOutput('pAirTemp'))
        )
      ),
      tabPanel("System Schedule Configuration",
        DT::dataTableOutput('schedule', width='100%'),
        verbatimTextOutput('selectedInfo')
      ),
      tabPanel("Constraints",
        fluidRow(
          column(3,
            numericInput('water_temp_min', 'Minimum Water Temperature',
                         constraints$water_temp$low),
            numericInput('air_temp_min'  , 'Minimum Air Temperature',
                         constraints$air_temp$low),
            numericInput('water_lvl_min' , 'Minimum Water Level',
                         constraints$water_level$low)
          ),
          column(3, 
            numericInput('water_temp_max', 'Maximum Water Temperature',
                         constraints$water_temp$high),
            numericInput('air_temp_max'  , 'Maxium Air Temperature',
                         constraints$air_temp$high),
            numericInput('water_lvl_max' , 'Maximum Water Level',
                         constraints$water_level$high)
          )
        )
      ) # Close Constraints Tab Panel
    )
  )
)