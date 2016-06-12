#Read tweets,clean, filter for answers to candidate and calculate sentiment.
# Jonas.Krueger.h71@gmail.com
# V1.0

library(streamR)
library(dplyr)
library(leaflet)
library(syuzhet)
library(tm)
library(RColorBrewer)

#Read tweets from json 
df0 <- parseTweets("tweets_hc_dt_0906.json", simplify = FALSE, verbose = TRUE)
df1 <- parseTweets("tweets_hc_dt_1006.json", simplify = FALSE, verbose = TRUE)
df2 <- parseTweets("tweets_hc_dt_1106.json", simplify = FALSE, verbose = TRUE)

df <- rbind(df0,df1, df2)
rm(df0, df1, df2)
# check what hilliary tweeted
df %>% select(text, retweet_count, user_id_str, id_str, created_at) %>% filter(user_id_str == "1339835893") -> tweet_hc
# check what trump tweeted
df %>% select(text, retweet_count, user_id_str, id_str, created_at) %>% filter(user_id_str == "25073877") -> tweet_trump

#Select the uniqe tweet IDs of candidate
tweet_trump %>% distinct(id_str ) %>% select(id_str) -> trump_id
tweet_hc %>% distinct(id_str ) %>% select(id_str) -> hc_id

#Now we get all the answers to the tweets via the tweet ids
#Only select direct replies
df_retweet_trump <- df[  df[["in_reply_to_status_id_str"]] %in% trump_id$id_str,]
df_retweet_hc <- df[  df[["in_reply_to_status_id_str"]] %in% hc_id$id_str,]

#We select the top 5 tweet (tweets with most answers)
#Hillary
df_retweet_hc%>% 
  select(in_reply_to_status_id_str) %>% 
  group_by(in_reply_to_status_id_str) %>% 
  summarise(tweetnumber=n()) -> top_tweets_hc

arrange(top_tweets_hc, desc(tweetnumber)) %>% 
  slice( 1:5) %>% inner_join(tweet_hc,  by = c("in_reply_to_status_id_str" = "id_str"))-> top5_hc
#Trump
df_retweet_trump%>% 
  select(in_reply_to_status_id_str) %>% 
  group_by(in_reply_to_status_id_str) %>% 
  summarise(tweetnumber=n()) -> top_tweets_trump

arrange(top_tweets_trump, desc(tweetnumber)) %>% 
  slice( 1:5) %>% inner_join(tweet_trump,  by = c("in_reply_to_status_id_str" = "id_str"))-> top5_trump
  
#Drop some variables 
df_retweet_hc %>% select(text, user_id_str, 
                      id_str, retweet_count, 
                      in_reply_to_status_id_str, 
                      geo_enabled, place_id, place_lat, created_at, time_zone,
                      place_lon) -> answer_df_hc

df_retweet_trump %>% select(text, user_id_str, 
                         id_str, retweet_count, 
                         in_reply_to_status_id_str, 
                         geo_enabled, place_id, place_lat, created_at, time_zone,
                         place_lon) -> answer_df_trump

#clean tweets
#Delete links, numbers etc. There might be some better packages, but it does the job done and its fast (If you have enough memory)
clean_trump = answer_df_trump
clean_hc = answer_df_hc
clean_trump$text = gsub("&amp", "", clean_trump$text)
clean_trump$text = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", clean_trump$text)
clean_trump$text = gsub("@\\w+", "", clean_trump$text)
clean_trump$text = gsub("[[:punct:]]", "", clean_trump$text)
clean_trump$text = gsub("[[:digit:]]", "", clean_trump$text)
clean_trump$text = gsub("http\\w+", "", clean_trump$text)
clean_trump$text = gsub("[ \t]{2,}", "", clean_trump$text)
clean_trump$text = gsub("^\\s+|\\s+$", "", clean_trump$text) 
clean_hc$text = gsub("&amp", "", clean_hc$text)
clean_hc$text = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", clean_hc$text)
clean_hc$text = gsub("@\\w+", "", clean_hc$text)
clean_hc$text = gsub("[[:punct:]]", "", clean_hc$text)
clean_hc$text = gsub("[[:digit:]]", "", clean_hc$text)
clean_hc$text = gsub("http\\w+", "", clean_hc$text)
clean_hc$text = gsub("[ \t]{2,}", "", clean_hc$text)
clean_hc$text = gsub("^\\s+|\\s+$", "", clean_hc$text) 



#Caluclate Sentiment syuzhet package
#Its looks for key words, so its kinda bad at irony detection. There might be some better way with machine learning instead
#of key word matching. But it works fast and is not to far off
Tweet_sentiment_hc <- get_nrc_sentiment(clean_hc$text)
Tweet_sentiment_trump <- get_nrc_sentiment(clean_trump$text)

#Bind them together 
tweet_result_trump <- cbind(clean_trump,Tweet_sentiment_trump)
tweet_result_hc <- cbind(clean_hc,Tweet_sentiment_hc)

#delete empty tweets and tweets without geo location
tweet_result_hc %>% filter(grepl("[a-zA-Z]",text)  & !is.na(place_lat))%>% mutate(sentiment = (positive-negative)) -> df_map_hc
tweet_result_trump %>% filter(grepl("[a-zA-Z]",text)  & !is.na(place_lat))%>% mutate(sentiment = (positive-negative)) -> df_map_trump

#Last step is to map the long/lat cordinates to states for the mapping
#Map the geo data from twitter to us states
library(sp)
library(maps)
library(maptools)

latlong2state <- function(pointsDF) {
  #source: http://stackoverflow.com/questions/8751497/latitude-longitude-coordinates-to-state-code-in-r
  # Prepare SpatialPolygons object with one SpatialPolygon
  # per state (plus DC, minus HI & AK)
  states <- map('state', fill=TRUE, col="transparent", plot=FALSE)
  IDs <- sapply(strsplit(states$names, ":"), function(x) x[1])
  states_sp <- map2SpatialPolygons(states, IDs=IDs,
                                   proj4string=CRS("+proj=longlat +datum=WGS84"))
  
  # Convert pointsDF to a SpatialPoints object 
  pointsSP <- SpatialPoints(pointsDF, 
                            proj4string=CRS("+proj=longlat +datum=WGS84"))
  
  # Use 'over' to get _indices_ of the Polygons object containing each point 
  indices <- over(pointsSP, states_sp)
  
  # Return the state names of the Polygons object containing each point
  stateNames <- sapply(states_sp@polygons, function(x) x@ID)
  stateNames[indices]
}

long_lat_hc <- select(df_map_hc,place_lon, place_lat )
long_lat_trump <- select(df_map_trump,place_lon, place_lat )
map_id_hc <-latlong2state(long_lat_hc)
map_id_trump <-latlong2state(long_lat_trump)
map_hc <- cbind(df_map_hc, map_id_hc)
map_hc <- filter(map_hc,!is.na(map_id_hc))
map_trump <- cbind(df_map_trump, map_id_trump)
map_trump <- filter(map_trump,!is.na(map_id_trump))



#Save the results for shiny app
tweet_trump <- top5_trump
tweet_hc <- top5_hc
df_map_trump <- map_trump
df_map_hc <- map_hc

save(df_map_hc,file="C:/Users/Jonas/Desktop/twitter/df_map_hc.Rda")
save(tweet_hc,file="C:/Users/Jonas/Desktop/twitter/tweet_hc.Rda")

save(df_map_trump,file="C:/Users/Jonas/Desktop/twitter/df_map_trump.Rda")
save(tweet_trump,file="C:/Users/Jonas/Desktop/twitter/tweet_trump.Rda")





