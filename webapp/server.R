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

con <- dbConnect(RSQLite::SQLite(), "../db/database.sqlite")

# this toggle table just creates a basic table that datatables 
# understands and can use to create a selectable table.
toggleTable <- matrix(" ", nrow=3, ncol = 24,
                      dimnames = list(
                        c("Aquarium Lights", "Circulation Pump", "Air Pump"),
                        seq.int(1, 24, 1)
                      ))

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
  
  
  return(list(WaterTemp = WaterTemp,
              WaterLvl = WaterLvl,
              Humidity = Humidity,
              AirTemp = AirTemp
              )
         )
}


shinyServer(function(input, output) {
  data <- reactive(loadAllReadings(input$timerange))
  
  
  output$schedule <- DT::renderDataTable({
    datatable(toggleTable,
              options = list(dom = 't',
                             ordering = F),
              selection = list(target = 'cell'),
              class = 'cell-border compact') %>%
                formatStyle(1:24, cursor = 'pointer')
  })
  output$selectedInfo <- renderPrint({
    str(input$schedule_cells_selected)
    cells <- data.frame(input$schedule_cells_selected)
    dbWriteTable(con, 'Schedule', cells, overwrite = TRUE)
  })
})
