library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(data.table)
library(shinyWidgets)

vrs_all = read.csv("./VAERS14-19.csv", stringsAsFactors = F)

