library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(data.table)
library(shinyWidgets)
library(tidyr)
library(data.table)

vrs_all = read.csv("./VAERS14-19.csv", stringsAsFactors = F)

