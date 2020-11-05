# Add Geocodes to Tweets

# Setup 
chunk_size <- 10
OVERWRITE_FILE <- F

# Load Tweets ------------------------------------------------------------------
tweets_df <- readRDS(file.path(data_tweets_dir, "processed_data", "tweets_classified.Rds"))

tweets_df <- tweets_df %>%
  filter(crash_tweet_algorithm %in% T) %>%
  arrange(desc(created_at_nairobitime))

tweets_df <- tweets_df[tweets_df$name %in% "Ma3Route",]

# Algorithm Inputs/Parameters --------------------------------------------------
## Gazetteers
roads <- readRDS(file.path(data_roadgaz_dir, "processed_data", "osm_roads_aug.Rds"))
landmarks <- readRDS(file.path(data_landmarkgaz_dir, "processed_data", "landmark_gazetter_aug.Rds"))
estates <- readRDS(file.path(data_estates_dir, "nairobi_estates.Rds"))

prepositions <- list(c("EVENT_WORD after", "EVENT_WORD near", "EVENT_WORD outside", 
                       "EVENT_WORD past", "around", "hapo", "just after", "just before", 
                       "just past", "near", "next to", "opposite", "outside", "past", 
                       "you approach", "apa", "apo", "hapa", "right after", 
                       "right before", "right past", "just before you reach"), 
                     c("EVENT_WORD at", "before"), 
                     c("after"),
                     c("at",
                       "happened at", "at the", "pale"), 
                     c("between", "from",
                       "btw", "btwn"), 
                     c("along", "approach", "in", "on", "opp", "to", "towards",
                       "toward") 
)

event <- c("accidents", "accident", "crash", "crush", "overturn", "overturned", 
           "collision", "wreck", "wreckage", "pile up", "pileup", "incident", 
           "hit and run", "hit", "roll", "rolled", "read end", "rear ended")
junction <- c("intersection", "junction")
false_positive <- c("githurai bus", "githurai matatu", 
                    "githurai 45 bus", "githurai 45 matatu",
                    "city hoppa bus", "hoppa bus",
                    "rongai bus", "rongai matatu", "rongai matatus",
                    "machakos bus", "machakos minibus", "machakos matatu",
                    "at ntsa kenya", 
                    "service lane", "star bus",
                    "prius", "mpya bus",
                    "heading towards") 
type_list <- list(c("bus_station","transit_station","stage_added", "stage", "bus_stop"),
                  c("mall", "shopping_mall"),
                  c("restaurant", "bakery", "cafe"),
                  c("building"),
                  c("parking"))


# landmarks <- readRDS(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm",
#                                "augmented_gazetteers", "landmarks_aug.Rds"))
# roads <- readRDS(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm",
#                            "augmented_gazetteers", "osm_roads_aug.Rds"))
# 
# estates <- readRDS(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm", 
#                              "raw_gazetteers", "nairobi_estates.Rds"))
# 
# # TODO: Could separate tier 1: two words then one word (tier two)?? hmmm, maybe not?
# prepositions <- list(c("EVENT_WORD after", "EVENT_WORD near", "EVENT_WORD outside", "EVENT_WORD past", "around", "hapo", "just after", "just before", "just past", "near", "next to", "opposite", "outside", "past", "you approach",
#                        "apa", "apo", "hapa", "right after", "right before", "right past", "just before you reach"), # manually adding these
#                      c("EVENT_WORD at", "before"), # manually adding these
#                      c("after"),
#                      c("at",
#                        "happened at", "at the", "pale"), # manually added
#                      c("between", "from",
#                        "btw", "btwn"), # manually added
#                      c("along", "approach", "in", "on", "opp", "to", "towards", # removed: of (mispelling of "on"?)
#                        "toward"), # manually added
#                      c("under", "inbound",
#                        "into") # manually added
# )
# 
# event <- c("accidents", "accident", "crash", "overturn", "overturned", "collision", "wreck", "pile up", "incident", "hit and run", "hit")
# junction <- c("intersection", "junction")
# false_positive <- c("githurai bus", "githurai matatu", 
#                     "githurai 45 bus", "githurai 45 matatu",
#                     "city hoppa bus", "hoppa bus",
#                     "rongai bus", "rongai matatu", "rongai matatus",
#                     "machakos bus", "machakos minibus", "machakos matatu",
#                     "at ntsa kenya", # original tweet... check for @ at end?
#                     "service lane", "star bus",
#                     "prius", "mpya bus",
#                     "heading towards") 
# type_list <- list(c("bus_station","transit_station","stage_added", "stage", "bus_stop"),
#                   c("mall", "shopping_mall"),
#                   c("restaurant", "bakery", "cafe"),
#                   c("building"),
#                   c("parking"),
#                   c("furniture_store"),
#                   c("pharmacy"),
#                   c("meal_delivery"),
#                   c("liquor_store"),
#                   c("movie_theater", "cinema"),
#                   c("shoe_store"),
#                   c("jewelry_store"),
#                   c("hindu_temple", "sikh"),
#                   c("travel_agency"),
#                   c("laundry"))

# Locate Crashes ---------------------------------------------------------------
starts <- seq(from = 1, to = length(tweets_df$tweet), by=chunk_size)

for(start_i in starts){
  
  print(paste(start_i, "-----------------------------------------------------"))
  
  out_file <- file.path(data_tweets_dir, "processed_data", "tweets_geocoded_chunks",
                        paste0("tweets_geocoded_chunk_",start_i,".Rds"))
  
  if(!file.exists(out_file) | OVERWRITE_FILE){
    end_i <- min(start_i + chunk_size - 1, length(tweets_df$tweet))
    
    tweets_df_i <- tweets_df[start_i:end_i,]
    
    alg_out_sf <- locate_event(text = tweets_df_i$tweet,
                               landmark_gazetteer = landmarks, 
                               roads = roads, 
                               areas = estates, 
                               prepositions_list = prepositions, 
                               prep_check_order = "prep_then_pattern", # prep_then_pattern
                               event_words = event, 
                               junction_words = junction, 
                               false_positive_phrases = false_positive, 
                               type_list = type_list, 
                               clost_dist_thresh = 500,
                               fuzzy_match = TRUE,
                               fuzzy_match.min_word_length = c(5,11),
                               fuzzy_match.dist = c(1,2),
                               fuzzy_match.ngram_max = 3,
                               fuzzy_match.first_letters_same = TRUE,
                               fuzzy_match.last_letters_same = TRUE,
                               crs_distance = "+init=epsg:21037", 
                               crs_out = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0",
                               quiet = F,
                               mc_cores = 1)
    
    print("Prepping Output")
    # Restrict to points and add to tweets
    alg_out_sf$status_id_str <- tweets_df_i$status_id_str
    alg_out_sf$geometry_type <- alg_out_sf$geometry %>% st_geometry_type() %>% as.character()
    alg_out_sf$geometry_dim <- alg_out_sf$geometry %>% st_dimension()
    
    alg_out_df <- alg_out_sf %>%
      filter(geometry_type %in% "POINT") %>%
      filter(!is.na(geometry_dim)) %>%
      dplyr::select(-text) %>%
      as("Spatial") %>%
      as.data.frame() %>%
      dplyr::rename(lon_alg = coords.x1,
                    lat_alg = coords.x2)
    
    # Add no geo back in
    alg_out_sf_nopoint <- alg_out_sf[!(alg_out_sf$status_id_str %in% alg_out_df$status_id_str),]
    alg_out_sf_nopoint$geometry <- NULL
    alg_out_sf_nopoint <- alg_out_sf_nopoint %>%
      dplyr::select(status_id_str)
    
    alg_out_df <- bind_rows(alg_out_df,
                            alg_out_sf_nopoint)
    
    # Export -----------------------------------------------------------------------
    saveRDS(alg_out_df, out_file)
  }
}




