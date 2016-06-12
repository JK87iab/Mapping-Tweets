#Shiny Server script
# Jonas.Krueger.h71@gmail.com
# V1.0



Sys.setlocale("LC_TIME", "English")


shinyServer(function(session,input, output){


output$tweet <- renderText({
  validate(
    need(input$tweet_sel != "", "Please select a tweet ID")
  )
  sel_tweet()
})
output$map <- renderLeaflet({
  
  
  leaflet() %>% setView(lng = -71.0589, lat = 42.3601, zoom = 5) %>% addTiles() 
   
    
  
})
output$state <- renderLeaflet({
  col_hc <- colorpal_hc()
  state_popup_hc <- paste0(df_map_state_hc()$NAME, 
                        "<br><strong>Mean sentiment: </strong>", 
                        df_map_state_hc()$pos_neg)
                       
   col_trump <- colorpal_trump()
   state_popup_trump <- paste0(df_map_state_trump()$NAME, 
                            "<br><strong>Mean sentiment: </strong>", 
                            df_map_state_trump()$pos_neg)
  leaflet() %>%
    setView(lng = -71.0589, lat = 42.3601, zoom = 4) %>% 
    addTiles() %>%
    addPolygons(data=df_map_state_hc(), stroke = F,fillOpacity = 0.8, smoothFactor=0.2,group = "Hillary Clinton" ,color = ~col_hc(pos_neg), 
                popup = state_popup_hc)%>% 
    addPolygons(data=df_map_state_trump(), stroke = F,fillOpacity = 0.8, smoothFactor=0.2,group = "Donald J. Trump" ,color = ~col_trump(pos_neg), 
                popup = state_popup_trump)%>% 
    addLayersControl(baseGroups =  c("Hillary Clinton","Donald J. Trump"),  options = layersControlOptions(collapsed = F))
  
  
  
})

output$data <- DT::renderDataTable(df_map())

#Observer map, change map depending on user input. Without rerendering the whole map
observe({
    leafletProxy("map")  %>%
    clearMarkerClusters() %>%
  addAwesomeMarkers(data = (filter(df_map(), sentiment < 0))
                    ,clusterOptions = markerClusterOptions()
                    ,icon = icon.red
                    ,lng = ~place_lon
                    ,lat= ~place_lat
                    ,popup = ~as.character(text)
                    ,clusterId = "neg"
                    
                    ) %>%
  addAwesomeMarkers(data = (filter(df_map(), sentiment > 0))
                            ,clusterOptions = markerClusterOptions()
                            ,icon = icon.green
                            ,lng = ~place_lon
                            ,lat= ~place_lat
                            ,popup = ~as.character(text)
                            ,clusterId = "pos"
                           
  )
  #addPolygons(data = Map, weight = 2,  smoothFactor = 6)
 }) 

#-------------------------------------------#
#User selected tweet 
sel_tweet <- reactive({
  df_input <- eval(parse(text=paste("tweet_",input$candidate, sep="")))
  text <- df_input[df_input$in_reply_to_status_id_str %in% input$tweet_sel,]
 return(text$text)
   
 }) 
  
#Updating UI depending on prior selections
 observeEvent(input$candidate,{
   if(input$candidate != ""){
     updateSelectInput(session,"tweet_sel",choices =c( ""))
     updateSelectInput(session,"tweet_sel",choices = eval(parse(text=(paste("tweet_",input$candidate,"$in_reply_to_status_id_str",sep="")))))
     
   }
 })
 observeEvent(input$tweet_sel,{
    #min und max date vom tweet map frame auslesen
    if(input$tweet_sel != "") {
      
    #If user select tweet we need to update the time slider
    #Selected tweet
    tweet <- input$tweet_sel
    #From which candidate
    df_input <- eval(parse(text=paste("df_map_",input$candidate, sep="")))
    
    #Select the time stamps from selected tweet
    time_tweet <- df_input[df_input$in_reply_to_status_id_str %in% input$tweet_sel,]
    #Convert from string to POSIX
    time <- as.data.frame(as.POSIXct(time_tweet$created_at, format="%a %b %d %H:%M:%S +0000 %Y", tz="GMT"))
    names(time)[1]<-"time"
    #Select min/max
    time %>% arrange(desc(time)) %>% filter(row_number()==1 | row_number()==n()) -> min_max_time
    
    
    #Update Slider
    updateSliderInput(session,"date_range1",min = (min_max_time[2,]),
                      max = (min_max_time[1,]), value=min_max_time[1,], step = 60)
    
    
    }
  }
  )


#When Go button pressed filter data 
 df_map <- eventReactive(input$start_button,{
          #User selected time
           time1 <- format(input$date_range1[1])
          #Tweet ID
           tweet <- as.numeric(input$tweet_sel)
          #HC or trump DF
           df_input <- eval(parse(text=paste("df_map_",input$candidate, sep="")))
           
           tweet_input <- df_input
           tweet_input %>% filter(in_reply_to_status_id_str == tweet ) %>% 
             mutate(time = as.POSIXct(created_at, format="%a %b %d %H:%M:%S +0000 %Y", tz="GMT") ) %>%
             filter(time < time1) -> tweet_sel
           
   
   return(tweet_sel)
   
 })

})
#Map for states
df_map_state_hc <- reactive({
  df_map_hc %>% dplyr::select(sentiment,map_id_hc) %>% group_by(map_id_hc) %>% 
    summarise(pos_neg = round(mean(sentiment),2)) -> map_hc_temp
  
  map_hc <- append_data(usgeomain, map_hc_temp, key.shp = "NAME", key.data="map_id_hc")
  
 
  return(map_hc)
})

df_map_state_trump <- reactive({
  
  
  map_trump_temp <- dplyr::select(df_map_trump,sentiment,map_id_trump) %>% group_by(map_id_trump) %>% summarise(pos_neg = mean(sentiment))
  
  map_trump <- append_data(usgeomain, map_trump_temp, key.shp = "NAME", key.data="map_id_trump")
  return(map_trump)
})
colorpal_hc <- reactive({
  colorNumeric("Greens", df_map_state_hc()$pos_neg)
  
})

colorpal_trump <- reactive({
  colorNumeric("Reds", df_map_state_trump()$pos_neg)
  
})
