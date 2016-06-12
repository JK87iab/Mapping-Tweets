


library(shiny)
library(shinythemes)
library(leaflet)
library(dplyr)
library(DT)
library(maps)

library(sp)
library(maps)
library(rgdal)
library(maptools)
library(RColorBrewer)
library(tmap)

load("df_map_hc.Rda")
load("df_map_trump.Rda")
load("tweet_trump.Rda")
load("tweet_hc.Rda")


#Icons using the github leaflet package
icon.red <- makeAwesomeIcon(icon = 'fa-twitter', markerColor = 'red', library='fa',
                           iconColor = 'black')

icon.green <- makeAwesomeIcon(icon = 'fa-twitter', markerColor = 'green', library='fa',
                           iconColor = 'black')

#shapefile 


  

usgeo <-  read_shape("tl_2014_us_state.shp")
usgeo$NAME <- tolower(usgeo$NAME)


usgeomain <- usgeo[usgeo@data$NAME!="alaska" 
                   &usgeo@data$NAME!="hawaii"
                   &usgeo@data$NAME!="united states virgin islands"
                   &usgeo@data$NAME!="commonwealth of the northern mariana islands"
                   &usgeo@data$NAME!="guam"
                   &usgeo@data$NAME!="american samoa"
                   &usgeo@data$NAME!="puerto rico"
                  
                   ,]
