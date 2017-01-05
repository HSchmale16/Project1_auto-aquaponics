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

loadAllReadings <- function() {
  AllReadings <- as.data.frame(dbReadTable(con, 'vSensorReadings'))
  WaterTemp <- as.data.frame(AllReadings[AllReadings$sensorId == 1,])
  WaterLvl <- as.data.frame(AllReadings[AllReadings$sensorId == 2,])
  Humidity <- as.data.frame(AllReadings[AllReadings$sensorId == 3,])
  AirTemp <- as.data.frame(AllReadings[AllReadings$sensorId == 4,])
}

shinyServer(function(input, output) {
  loadLatestReadings()
  loadAllReadings()
  output$NewReadings <- renderTable({
    NewestReadings[,c("ts", "reading", "sensor", "units")]
  })
})
