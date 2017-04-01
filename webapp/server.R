# server.R
# Webapp For Autoaquaponics
# Allows users to view statistics about the system as it is running.
#
# Author: Henry J Schmale
#

library(shiny)
library(DBI)
library(DT)
library(dplyr)
library(ggplot2)
library(plotly)

# this toggle table just creates a basic table that datatables 
# understands and can use to create a selectable table.
toggleTable <- matrix(" ", nrow=3, ncol = 24,
                      dimnames = list(
                        c("Circulation Pump", "Air Pump", "Aquarium Lights"),
                        seq.int(0, 23, 1)
                      ))

con <- dbConnect(RSQLite::SQLite(), "../db/database.sqlite")

loadLatestReadings <- function() {
  NewestReadings <- as.data.frame(dbReadTable(con, "vNewestReadings"))
  split(NewestReadings, NewestReadings$sensor)
}


#######################################
# Loads all of the sensor readings
# you must name the table to pull from if you are using a different table for
# the last n days.
#######################################
loadAllReadings <- function(tbname = 'vSensorReadings') {
  AllReadings <- data.frame(dbReadTable(con, tbname))
  
  # Fix timestamps by making them a proper R datatype
  AllReadings$ts <- as.POSIXct(AllReadings$ts, format = '%Y-%m-%d %H:%M:%S',
                               tz = Sys.timezone())
  
  # Select the rows for each sensor
  WaterTemp <- data.frame(AllReadings[AllReadings$sensorId == 1,])
  WaterLvl  <- data.frame(AllReadings[AllReadings$sensorId == 2,])
  Humidity  <- data.frame(AllReadings[AllReadings$sensorId == 3,])
  AirTemp   <- data.frame(AllReadings[AllReadings$sensorId == 4,])
  
  colsToKeep <- c('ts', 'reading')
  
  
  return(list(WaterTemp = WaterTemp[,colsToKeep],
              WaterLvl = WaterLvl[,colsToKeep],
              Humidity = Humidity[,colsToKeep],
              AirTemp = AirTemp[,colsToKeep]
              )
         )
}

loadCurrentConstraints <- function() {
  dbReadTable(con, 'vCurrentConstraints')
}

shinyServer(function(input, output, session) {
  data <- reactive(loadAllReadings(input$timerange))
  latestReadings <- loadLatestReadings()
  
  # observe changes to the constaints
  saveConstraints <- reactive({
    name <- c('water_level', 'air_temp', 'water_temp')
    low  <- c(input$water_lvl_min, input$air_temp_min, input$water_temp_min)
    high <- c(input$water_lvl_max, input$air_temp_max, input$water_temp_max)
    a <- data.frame(name, low, high)
    dbWriteTable(con, 'Constraints', a, append=TRUE)
  })
  
  observeEvent(input$water_lvl_min,  { saveConstraints() })
  observeEvent(input$water_lvl_max,  { saveConstraints() })
  observeEvent(input$water_temp_min, { saveConstraints() })
  observeEvent(input$water_temp_max, { saveConstraints() })
  observeEvent(input$air_temp_min,   { saveConstraints() })
  observeEvent(input$air_temp_max,   { saveConstraints() })

  # Put together the toggle table for setting the schedule
  output$schedule <- DT::renderDataTable({
    datatable(toggleTable,
              options = list(dom = 't',
                             ordering = F),
              selection = list(target = 'cell',
                               selected = data.matrix(
                                  dbReadTable(con, 'Schedule'),
                                  rownames.force = NA)
                               ),
              class = 'cell-border compact') %>%
                formatStyle(1:24, cursor = 'pointer')
  })
  
  observeEvent(input$schedule_cells_selected, {
    print('change cells selected')
    cells <- data.frame(input$schedule_cells_selected)
    dbWriteTable(con, 'Schedule', cells, overwrite = TRUE)
  })
  
  # Do the value boxes  
  output$bHumidity <- renderValueBox({
    infoBox(
      latestReadings$humidity$reading, 
      title = 'Humidity',
      icon = shiny::icon('tint')
    )
  })
  
  output$bAirTemp <- renderValueBox({
    infoBox(
      latestReadings$`air temperature`$reading,
      title = 'Air Temperature',
      icon = shiny::icon('thermometer-full')
    )
  })
  
  output$bWaterTemp <- renderValueBox({
    infoBox(
      latestReadings$`water thermometer`$reading,
      title = 'Water Temperature',
      icon = shiny::icon('thermometer-half')
    )
  })
  
  output$bWaterLevel <- renderValueBox({
    infoBox(
      latestReadings$`water level`$reading,
      title = 'Water Level',
      icon = shiny::icon('shower')
    )
  })
  
  #############################
  # Do Constraints
  #############################
  cc <- loadCurrentConstraints()
  updateNumericInput(session, 'water_level_min',
                     value = cc[cc$name == 'water_level',]$min)
  updateNumericInput(session, 'water_level_max',
                     value = cc[cc$name == 'water_level',]$max)
  updateNumericInput(session, 'water_temp_min',
                     value = cc[cc$name == 'water_temp',]$min)
  updateNumericInput(session, 'water_temp_max',
                     value = cc[cc$name == 'water_temp',]$max)
  updateNumericInput(session, 'air_temp_min',
                     value = cc[cc$name == 'air_temp',]$min)
  updateNumericInput(session, 'air_temp_max',
                     value = cc[cc$name == 'air_temp',]$max)
  
  
  #############################
  # Do Plots
  #############################
  output$pWaterLvl <- renderPlotly({
    t <- ggplot(data()$WaterLvl, aes(x = ts)) + 
      geom_line(aes(y = reading)) +
      ggtitle("Water Level")
    ggplotly(t)
  })
  
  output$pWaterTemp <- renderPlotly({
    t <- ggplot(data()$WaterTemp, aes(x = ts)) +
      geom_line(aes(y = reading)) +
      ggtitle("Water Temperature")
    ggplotly(t)
  })
  
  output$pAirTemp <- renderPlotly({
    t <- ggplot(data()$AirTemp, aes(x = ts)) +
      geom_line(aes(y = reading)) +
      ggtitle("Air Temperature") +
      coord_cartesian(ylim=c(15, 35))
    ggplotly(t)
  })
  
  output$pHumidity <- renderPlotly({
    t <- ggplot(data()$Humidity, aes(x = ts)) +
      geom_line(aes(y = reading)) +
      ggtitle("Relative Humidity") +
      coord_cartesian(ylim=c(0, 100))
    ggplotly(t)
  })
})
