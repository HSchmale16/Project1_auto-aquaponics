# server.R
# Webapp For Autoaquaponics
# Allows users to view statistics about the system as it is running.
#
# Author: Henry J Schmale
#

library(shiny)
library(DBI)
library(DT)

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
  return(list(AllReadings = AllReadings,
              WaterTemp = WaterTemp,
              WaterLvl = WaterLvl,
              Humidity = Humidity,
              AirTemp = AirTemp
              )
         )
}


shinyServer(function(input, output) {
  loadLatestReadings()
  readings <- loadAllReadings()
  output$NewReadings <- renderTable({
    readings$AllReadings[,c("ts", "reading", "name", "units")]
  })
  output$text <- renderText(input$timerange)
})
