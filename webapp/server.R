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
}

loadAllReadings <- function(tbname = 'vSensorReadings') {
  AllReadings <- data.frame(dbReadTable(con, tbname))
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
  
  output$schedule <- DT::renderDataTable({
    datatable(toggleTable,
              options = list(dom = 't',
                             ordering = F),
              selection = list(target = 'cell',
                               selected = data.matrix(dbReadTable(con, 'Schedule'),
                                                      rownames.force = NA)),
              class = 'cell-border compact') %>%
                formatStyle(1:24, cursor = 'pointer')
  })
  
  output$pWaterLvl <- renderPlot({
    ggplot(data()$WaterLvl, aes(x = ts)) + geom_point(aes(y = reading)) + ggtitle("Water Level")
  })
  
  output$pAirTemp <- renderPlot({
    ggplot(data()$AirTemp, aes(x = ts)) + geom_point(aes(y = reading)) + ggtitle("Air Temperature")
  })
  
  output$pWaterTemp <- renderPlot({
    ggplot(data()$WaterTemp, aes(x = ts)) + geom_point(aes(y = reading)) + ggtitle("Water Temperature")
  })
  
  output$pHumidity <- renderPlot({
    ggplot(data()$Humidity, aes(x = ts)) + geom_point(aes(y = reading)) + ggtitle("Humidity")
  })
})
