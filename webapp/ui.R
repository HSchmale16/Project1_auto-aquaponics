# ui.R for Autoaquaponics
# Henry J Schmale
#
#

library(shiny)
library(DT)
library(shinydashboard)
library(plotly)
library(DBI)

# Load the current constraints to set the defaults for the
# constraint setting panel.
con <- dbConnect(RSQLite::SQLite(), "../db/database.sqlite")
cc <- dbReadTable(con, 'vCurrentConstraints')
dbDisconnect(con)

# Prepare the dashboard page
dashboardPage(
  dashboardHeader(title = 'Automated Aquaponics Dashboard'),
  dashboardSidebar(
    radioButtons(
      "timerange", "Time Range To Display",
      choices = c(
        'Todays Readings' = 'vTodaysReadings',
        'Last 24 Hours' = 'vLast24Hours',
        "Last 7 Days"  = 'vLast7DaysReadings',
        "Last 14 Days" = 'vLast14DaysReadings',
        "Last 30 Days" = 'vLast30DaysReadings',
        "All Time"     = 'vSensorReadings'
      )
    )
  ),
  dashboardBody(
    tabsetPanel(
      # The default panel
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
      # Begin The Schedule Panel
      tabPanel("System Schedule Configuration",
        # Make scrollable with the overflow
        wellPanel(id='tPanel', style='overflow-y:scroll;',
          DT::dataTableOutput('schedule', width='100%')
        )
      ),
      # Begin Constraint Panel
      tabPanel("Constraints",
        fluidRow(
          # 2x3 inputs with min on left and max on right for each
          # constraint
          column(3,
            numericInput('water_temp_min', 'Minimum Water Temperature',
                         cc[cc$name == 'water_temp',]$low),
            numericInput('air_temp_min'  , 'Minimum Air Temperature',
                         cc[cc$name == 'air_temp',]$low),
            numericInput('water_lvl_min' , 'Minimum Water Level',
                         cc[cc$name == 'water_level',]$low)
          ),
          column(3, 
            numericInput('water_temp_max', 'Maximum Water Temperature',
                         cc[cc$name == 'water_temp',]$high),
            numericInput('air_temp_max'  , 'Maxium Air Temperature',
                         cc[cc$name == 'air_temp',]$high),
            numericInput('water_lvl_max' , 'Maximum Water Level',
                         cc[cc$name == 'water_level',]$high)
          )
        ),
        actionButton("saveConstraints", "Save Constraints")
      ) # Close Constraints Tab Panel
    )
  )
)