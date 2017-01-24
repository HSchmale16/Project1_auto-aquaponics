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

con <- dbConnect(RSQLite::SQLite(), "../db/database.sqlite")
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
  return(list(WaterTemp = WaterTemp,
              WaterLvl = WaterLvl,
              Humidity = Humidity,
              AirTemp = AirTemp
              )
         )
}


shinyServer(function(input, output) {
  loadLatestReadings()
  output$NewReadings <- renderTable({
    readings <- loadAllReadings(input$timerange)
    readings$WaterTemp[,c("ts", "reading", "name", "units")]
  })
  output$schedule <- DT::renderDataTable({
    datatable(toggleTable,
              options = list(dom = 't',
                             ordering = F),
              selection = list(target = 'cell'),
              class = 'cell-border compact') %>%
                formatStyle(1:24, cursor = 'pointer')
  })
  
  output$selectedInfo <- renderPrint({
    input$schedule_cells_selected
  })
  
  output$text <- renderText(input$timerange)
})
