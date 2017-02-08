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
                        seq.int(1, 24, 1)
                      ))

con <- dbConnect(RSQLite::SQLite(), "../db/database.sqlite")

loadLatestReadings <- function() {
  NewestReadings <- as.data.frame(dbReadTable(con, "vNewestReadings"))
  split(NewestReadings, NewestReadings$sensor)
}

loadAllReadings <- function(tbname = 'vSensorReadings') {
  AllReadings <- data.frame(dbReadTable(con, tbname))
  AllReadings$ts <- as.POSIXct(AllReadings$ts, format = '%Y-%m-%d %H:%M:%S',
                               tz = "UTC")
  AllReadings <- sample_n(AllReadings, 200)
  WaterTemp <- data.frame(AllReadings[AllReadings$sensorId == 1,])
  WaterLvl <- data.frame(AllReadings[AllReadings$sensorId == 2,])
  Humidity <- data.frame(AllReadings[AllReadings$sensorId == 3,])
  AirTemp <- data.frame(AllReadings[AllReadings$sensorId == 4,])
  
  colsToKeep <- c('ts', 'reading')
  
  
  return(list(WaterTemp = WaterTemp[,colsToKeep],
              WaterLvl = WaterLvl[,colsToKeep],
              Humidity = Humidity[,colsToKeep],
              AirTemp = AirTemp[,colsToKeep]
              )
         )
}


shinyServer(function(input, output) {
  data <- reactive(loadAllReadings(input$timerange))
  latestReadings <- loadLatestReadings()
  
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
  
  # Do the value boxes  
  output$bHumidity <- renderValueBox({
    infoBox(
      latestReadings$humidity$reading, 
      title = 'Humidity'
    )
  })
  
  output$bAirTemp <- renderValueBox({
    infoBox(
      latestReadings$`air temperature`$reading,
      title = 'Air Temperature'
    )
  })
  
  output$bWaterTemp <- renderValueBox({
    infoBox(
      latestReadings$`water thermometer`$reading,
      title = 'Water Temperature'
    )
  })
  
  output$bWaterLevel <- renderValueBox({
    infoBox(
      latestReadings$`water level`$reading,
      title = 'Water Level'
    )
  })
  
  # Do Plots
  output$pWaterLvl <- renderPlotly({
    t <- ggplot(data()$WaterLvl, aes(x = ts)) + 
      geom_line(aes(y = reading)) +
      ggtitle("Water Level")
    ggplotly(t)
  })
  
  output$pAirTemp <- renderPlotly({
    t <- ggplot(data()$AirTemp, aes(x = ts)) +
      geom_line(aes(y = reading)) +
      ggtitle("Air Temperature")
    ggplotly(t)
  })
  
  output$pWaterTemp <- renderPlotly({
    t <- ggplot(data()$WaterTemp, aes(x = ts)) +
      geom_line(aes(y = reading)) +
      ggtitle("Water Temperature")
    ggplotly(t)
  })
  
  output$pHumidity <- renderPlotly({
    t <- ggplot(data()$Humidity, aes(x = ts)) +
      geom_line(aes(y = reading)) +
      ggtitle("Humidity")
    ggplotly(t)
  })
})
