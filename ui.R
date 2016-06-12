



 shinyUI(navbarPage("Explore responses to Candidate Tweets", id= "twitter" ,inverse=TRUE, footer= "Jonas.Krueger.h71@gmail.com",
                    
                    
      tabPanel("Tweets",
               tags$head(tags$style(
             HTML('
             input[type="number"] {
                    max-width: 80%;
                  }
                  
                  div.outer {
                  position: fixed;
                  top: 41px;
                  left: 0;
                  right: 0;
                  bottom: 0;
                  overflow: hidden;
                  padding: 0;
                  }
                  
                  /* Customize fonts */
                  body, label, input, button, select { 
                  font-family: "Helvetica Neue", Helvetica;
                  font-weight: 200;
                  }
                  h1, h2, h3, h4 { font-weight: 400; }
                  


                  #controls {
                  /* Appearance */
                  background-color: white;
                  padding: 0 20px 20px 20px;
                  opacity: 0.9;
                  
                  }
             ')
        )),
               leafletOutput("map",height = "600" ),
               # Shiny versions prior to 0.11 should use class="modal" instead. 
                     absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, 
                                               draggable = FALSE , top = 60, left = "auto", right = 20, bottom = "auto", 
                                               width = 330, height = "auto", 
                                      
                                      
                                        strong(h4("Explore responses to tweetes")),
                                        selectInput("candidate", strong("Choose candidate"), multiple = F, choices=c("Select" = "", "Donald J. Trump" = "trump"," Hillary Clinton" = "hc")),
                                        selectInput("tweet_sel", strong("Choose tweet"), multiple = F, choices=c("Select candidate first" = "")),
                                        h5(strong("Tweet:")),
                                        textOutput("tweet"),br(),
                                        sliderInput("date_range1", 
                                                    strong("Choose Date Range:"), 
                                                    min = as.POSIXct("2016-02-01 01:00"),
                                                    max = as.POSIXct("2016-03-01 23:00"),
                                                    value = c(as.POSIXct("2016-02-01 02:00"))
                                                              , timeFormat = "%a %H:%M", ticks = T, animate = F, timezone = "GMT"
                                        ),
                                        h6("Start date equals the earliest reply.Timezone is GMT"),
                                        actionButton("start_button","go")
                                    
                                
                                             
                                             ) 
               
               
               ),# Ende tabPanel map
      
      
      tabPanel("Sentiment by state", 
               paste("Loading the map takes a couple of seconds."),
               
               leafletOutput("state",height = "600" ))
 
   
))
  