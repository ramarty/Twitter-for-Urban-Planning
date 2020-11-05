# Move File from Dropbox to Replication Package Code

# Setup ------------------------------------------------------------------------
replication_data_path <- file.path(github_file_path, "Replication Code for Outputs", 
                                   "smarTTrans Algorithm Technical Paper", 
                                   "datawork")

# Tweets -----------------------------------------------------------------------
tweets_df <- readRDS(file.path(dropbox_file_path, "Data", "Twitter", "Tweets All", "FinalData", 
                               "Full Tweets", "rds", "tweets_truth.Rds"))

tweets_df <- tweets_df %>%
  filter(name %in% "Ma3Route") %>%
  dplyr::select(tweet_id, status_id_str, created_at_nairobitime, text, name, source,
                accident_truth, latitude_truth, longitude_truth,
                street_name_c1, street_name_c2,
                landmark_c1, landmark_c2, 
                oneyear_truth_sample)

saveRDS(tweets_df, file.path(replication_data_path, "tweets_all", "data", "raw_data", "tweets.Rds"))

# Tweets: Algorithm ------------------------------------------------------------
tweets <- readRDS(file.path(dropbox_file_path, "Data", "Twitter", "Tweets All", "FinalData", "Full Tweets", "rds", "tweets_truth_accidentclassif_geocodedmerged.Rds"))
tweets <- tweets[tweets$name %in% "Ma3Route",]
saveRDS(tweets, file.path(replication_data_path, "tweets_all", "data", "processed_data", "tweets_classified_geoparsed.Rds"))

# Truth Tweets -----------------------------------------------------------------
truth_data <- readRDS(file.path(dropbox_file_path, "Data", "Twitter", "Truth Data", "Truth Data All Rounds", "truth_data_all_crashlandmark.Rds"))

## Add Tweet ID
tweet_id_df <- tweets %>%
  dplyr::select(status_id_str, tweet_id)

truth_data <- merge(truth_data, 
                    tweet_id_df, 
                    by = "status_id_str", all.x=T, all.y=F)

truth_data <- truth_data %>%
  filter(oneyear_truth_sample %in% T,
         potentially_accident_related %in% T) %>%
  mutate(geocoded = (!is.na(latitude_truth) & !is.na(longitude_truth)))

truth_data$latitude_truth[truth_data$accident_truth %in% F] <- NA
truth_data$longitude_truth[truth_data$accident_truth %in% F] <- NA

truth_data <- truth_data %>%
  dplyr::select(status_id_str, tweet_id, tweet, accident_truth, 
                created_at_nairobitime, crash_landmark, crash_cluster_id_v1, crash_cluster_id_v2,
                latitude_truth, longitude_truth, geocoded,
                landmark_c1, landmark_c2) 

saveRDS(truth_data, file.path(replication_data_path, "tweets_truth", "data", "raw_data", "tweets_truth.Rds"))

# Raw Landmark Gazetteer -------------------------------------------------------
googleplaces <- readRDS(file.path(dropbox_file_path, "Data", "Google Landmarks", "FinalData", "google_places.Rds"))
geonames <- readRDS(file.path(dropbox_file_path, "Data", "Geonames Landmarks", "FinalData", "geonames_nairobi.Rds"))
osm <- readRDS(file.path(dropbox_file_path, "Data", "OSM", "FinalData", "osm_landmarks.Rds"))

saveRDS(googleplaces, file.path(replication_data_path, "landmark_gazetteer", "raw_data", "google_places.Rds"))
saveRDS(geonames, file.path(replication_data_path, "landmark_gazetteer", "raw_data", "geonames.Rds"))
saveRDS(osm, file.path(replication_data_path, "landmark_gazetteer", "raw_data", "osm_landmarks.Rds"))

# Landmark Names to Remove -----------------------------------------------------
landmarks_to_rm <- read.csv(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm", "landmarks_to_remove", "landmarks_to_remove.csv"), 
                            stringsAsFactors = F)

write.csv(landmarks_to_rm, file.path(replication_data_path, "landmark_gazetteer", "raw_data", "landmarks_to_remove.csv"),
          row.names = F)

# Raw Road Gazetteer -----------------------------------------------------------
nairobi_roads <- readRDS(file.path(dropbox_file_path, "Data", "OSM", "FinalData", 
                                   "rds_files_20190317", "gis_osm_roads_free_1_nairobi.Rds"))

saveRDS(nairobi_roads, file.path(replication_data_path, "road_gazetteer", "raw_data", "gis_osm_roads_free_1_nairobi.Rds"))

# Estates ----------------------------------------------------------------------
estates <- readRDS(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm", 
                             "raw_gazetteers", "nairobi_estates.Rds"))

saveRDS(estates, file.path(replication_data_path, "nairobi_estates", "nairobi_estates.Rds"))

# GADM -------------------------------------------------------------------------
kenya <- readRDS(file.path(dropbox_file_path, "Data", "GADM", "RawData", "gadm36_KEN_1_sp.rds"))
saveRDS(kenya, file.path(replication_data_path, "gadm", "gadm36_KEN_1_sp.rds"))

# Algorithm Results ------------------------------------------------------------
df_aug <- list.files(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm", "tweets_geocoded", "tweets_geocoded_chunks22"), # 7
                     pattern = "*.Rds",
                     full.names = T) %>% 
  map_df(readRDS) 

df_raw <- list.files(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm", "tweets_geocoded", "tweets_geocoded_chunks22_raw"), # 7
                     pattern = "*.Rds",
                     full.names = T) %>% 
  map_df(readRDS) 

df_aug_google <- list.files(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm", "tweets_geocoded", "tweets_geocoded_chunks22_google"), # 7
                            pattern = "*.Rds",
                            full.names = T) %>% 
  map_df(readRDS) 

df_aug_osm <- list.files(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm", "tweets_geocoded", "tweets_geocoded_chunks22_osm"), # 7
                         pattern = "*.Rds",
                         full.names = T) %>% 
  map_df(readRDS)

df_aug_geonames <- list.files(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm", "tweets_geocoded", "tweets_geocoded_chunks22_geonames"), # 7
                              pattern = "*.Rds",
                              full.names = T) %>% 
  map_df(readRDS) 

saveRDS(df_aug, file.path(data_tweets_georesults_dir, paste0("tweet_geoparse_gaz_aug.Rds")))
saveRDS(df_aug_geonames, file.path(data_tweets_georesults_dir, paste0("tweet_geoparse_gaz_aug_geonames.Rds")))
saveRDS(df_aug_google, file.path(data_tweets_georesults_dir, paste0("tweet_geoparse_gaz_aug_google.Rds")))
saveRDS(df_aug_osm, file.path(data_tweets_georesults_dir, paste0("tweet_geoparse_gaz_aug_osm.Rds")))
saveRDS(df_raw, file.path(data_tweets_georesults_dir, paste0("tweet_geoparse_gaz_raw.Rds")))

# LNEx Results -----------------------------------------------------------------
lnex_results <- read.csv(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm", "tweets_geocoded", "lnex_output", "lnex_rawgaz.csv"),
                         stringsAsFactors = F)

write.csv(lnex_results, file.path(data_tweets_georesults_dir, "tweet_geoparse_lnex.csv"),
          row.names = F)

# Sendy ------------------------------------------------------------------------
sendy_df <- readRDS(file.path(sendy_path, "Twitter Crash Verification", "FinalData", "survey_sendy_tweet.rds"))

## Subset
sendy_df <- sendy_df[sendy_df$survey_type %in% "Verification",]
sendy_df <- sendy_df[!is.na(sendy_df$Tweet),]

## Select variables
sendy_df <- sendy_df %>%
  dplyr::select(Notes, q1, why_no_crash,
                date_tweet, date_placed, date_pickedup, date_start, end_date, "Suggested Landmark") %>%
  dplyr::rename(note_to_driver = Notes,
                observe_crash = q1,
                datetime_tweet = date_tweet,
                datetime_order_placed = date_placed,
                datetime_driver_pickup_order = date_pickedup,
                datetime_survey_start = date_start,
                datetime_survey_end = end_date)

write.csv(sendy_df, file.path(data_sendy_dir, "sendy_data.csv"),
          row.names = F)






