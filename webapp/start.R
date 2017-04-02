#!/usr/bin/env Rscript
# use for the init script to start this up

library(shiny)

serverOptions <- list(
  port = 7900,
  host = '0.0.0.0'
)

shinyAppDir('.', options = serverOptions)
