# Cluster Tweets

library(dplyr)

# Load Tweets ------------------------------------------------------------------
tweets_all <- readRDS(file.path(data_tweets_dir, "processed_data", "tweets_classified_geoparsed.Rds"))

### Subset for Tweets Truth
tweets_truth <- tweets_all[tweets_all$accident_truth %in% TRUE,]
tweets_truth <- tweets_truth[!is.na(tweets_truth$latitude_truth),]
tweets_truth <- tweets_truth[!is.na(tweets_truth$longitude_truth),]

### Subset for Tweets All
tweets_all <- tweets_all[tweets_all$crash_tweet_algorithm %in% TRUE,]
tweets_all <- tweets_all[tweets_all$potentially_accident_related %in% TRUE,]
tweets_all <- tweets_all[!is.na(tweets_all$lat_alg),]
tweets_all <- tweets_all[!is.na(tweets_all$lon_alg),]

# Cluster Tweets ---------------------------------------------------------------
crashes_df = tweets_truth
time_var = "created_at_nairobitime"
lat_var = "latitude_truth"
lon_var = "longitude_truth"
time_thresh_hrs=4
cluster_km=0.5 
cluster_id_only=F
vars_to_keep <- c("tweet")

tweets_truth_clustered <- cluster_crashes_one_dataset(crashes_df = tweets_truth,
                                                     time_var = "created_at_nairobitime",
                                                     lat_var = "latitude_truth",
                                                     lon_var = "longitude_truth",
                                                     vars_to_keep = c("tweet"),
                                                     time_thresh_hrs=4, 
                                                     cluster_km=0.5, 
                                                     cluster_id_only=F)

tweets_all_clustered <- cluster_crashes_one_dataset(crashes_df = tweets_all,
                            time_var = "created_at_nairobitime",
                            lat_var = "lat_alg",
                            lon_var = "lon_alg",
                            vars_to_keep = c("tweet"),
                            time_thresh_hrs=4, 
                            cluster_km=0.5, 
                            cluster_id_only=F)

# Add CRS To Dataset -----------------------------------------------------------
crs(tweets_truth_clustered) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
crs(tweets_all_clustered) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

## Id
tweets_all_clustered$crash_id   <- 1:nrow(tweets_all_clustered)
tweets_truth_clustered$crash_id <- 1:nrow(tweets_truth_clustered)

# Use Coordinates, not polygon -------------------------------------------------
tweets_all_clustered_coords <- tweets_all_clustered %>% 
  coordinates() %>% 
  as.data.frame() %>%
  dplyr::rename(longitude = V1,
                latitude = V2)
tweets_all_clustered_df <- bind_cols(tweets_all_clustered %>% as.data.frame(), 
                                     tweets_all_clustered_coords)

tweets_truth_clustered_coords <- tweets_truth_clustered %>% 
  coordinates() %>% 
  as.data.frame() %>%
  dplyr::rename(longitude = V1,
                latitude = V2)
tweets_truth_clustered_df <- bind_cols(tweets_truth_clustered %>% as.data.frame(), 
                                       tweets_truth_clustered_coords)

# Export -----------------------------------------------------------------------
saveRDS(tweets_all_clustered_df,   file.path(data_tweets_dir, "processed_data", "tweets_classified_geoparsed_uniquecrashes.Rds"))
saveRDS(tweets_truth_clustered_df, file.path(data_tweets_dir, "processed_data", "truth_tweets_classified_geoparsed_uniquecrashes.Rds"))

#st_write(obj=st_as_sf(tweets_all_clustered), dsn=file.path(dropbox_file_path, "Data", "Twitter", "Tweets All", "FinalData", "Full Tweets", "geojson", "tweets_all_accidentclassif_geocodedmerged_clustered.geojson"), delete_dsn=T)
#saveRDS(tweets_all_clustered, file=file.path(dropbox_file_path, "Data", "Twitter", "Tweets All", "FinalData", "Full Tweets", "rds", "tweets_all_accidentclassif_geocodedmerged_clustered.Rds"))

#st_write(st_as_sf(tweets_truth_clustered), file.path(dropbox_file_path, "Data", "Twitter", "Tweets All", "FinalData", "Full Tweets", "geojson", "tweets_truth_accidentclassif_geocodedmerged_clustered_truthonly.geojson"), delete_dsn=T)
#saveRDS(tweets_truth_clustered, file=file.path(dropbox_file_path, "Data", "Twitter", "Tweets All", "FinalData", "Full Tweets", "rds", "tweets_truth_accidentclassif_geocodedmerged_clustered_truthonly.Rds"))






# Prep dataframe ---------------------------------------------------------------
#### Coordinates
tweets_all_clustered_coords <- tweets_all_clustered %>% 
  coordinates() %>% 
  as.data.frame() %>%
  dplyr::rename(longitude = V1,
                latitude = V2)
tweets_all_clustered_df <- bind_cols(tweets_all_clustered %>% as.data.frame(), 
                                     tweets_all_clustered_coords)

tweets_truth_clustered_coords <- tweets_truth_clustered %>% 
  coordinates() %>% 
  as.data.frame() %>%
  dplyr::rename(longitude = V1,
                latitude = V2)
tweets_truth_clustered_df <- bind_cols(tweets_truth_clustered %>% as.data.frame(), 
                                     tweets_truth_clustered_coords)

#### Characteristics
fatal_words <- c("dead", "died", "body", "killed", "fatal") 
fatal_words_rx <- paste0("\\b", fatal_words, "\\b") %>% paste(collapse = "|")

tweets_all_clustered_df <- tweets_all_clustered_df %>%
  mutate(fatality = tweet %>% str_detect(fatal_words_rx) %>% as.numeric(),
         tweet = tweet %>% substring(1,200)) %>%
  dplyr::select(-cluster_id)

tweets_truth_clustered_df <- tweets_truth_clustered_df %>%
  mutate(fatality = tweet %>% str_detect(fatal_words_rx) %>% as.numeric(),
         tweet = tweet %>% substring(1,200)) %>%
  dplyr::select(-cluster_id)

#### Variables
tweets_all_clustered_df$crash_date <- tweets_all_clustered_df$crash_time_min %>% date()
tweets_truth_clustered_df$crash_date <- tweets_truth_clustered_df$crash_time_min %>% date()

#### Label Variable
tweets_all_clustered_df$fatality <- tweets_all_clustered_df$fatality %>%
  labelled(labels = c(No = 0, Yes = 1),
           label = paste0("The tweet contains: ",
                          paste(fatal_words, collapse = ", ")))

tweets_truth_clustered_df$fatality <- tweets_truth_clustered_df$fatality %>%
  labelled(labels = c(No = 0, Yes = 1),
           label = paste0("The tweet contains: ",
                          paste(fatal_words, collapse = ", ")))

var_label(tweets_all_clustered_df$N_crash_reports) <- "Number of tweets that reported crash"
var_label(tweets_truth_clustered_df$N_crash_reports) <- "Number of tweets that reported crash"

var_label(tweets_all_clustered_df$crash_time_min) <- "Date/time of first tweet that reported crash"
var_label(tweets_truth_clustered_df$crash_time_min) <- "Date/time of first tweet that reported crash"

var_label(tweets_all_clustered_df$crash_time_max) <- "Date/time of last tweet that reported crash"
var_label(tweets_truth_clustered_df$crash_time_max) <- "Date/time of last tweet that reported crash"

var_label(tweets_all_clustered_df$crash_date) <- "Crash Date (Using time of first tweet report)"
var_label(tweets_truth_clustered_df$crash_date) <- "Crash Date (Using time of first tweet report)"

var_label(tweets_all_clustered_df$tweet) <- "Tweet text"
var_label(tweets_truth_clustered_df$tweet) <- "Tweet text"

var_label(tweets_all_clustered_df$crash_id) <- "Unique ID"
var_label(tweets_truth_clustered_df$crash_id) <- "Unique ID"

var_label(tweets_all_clustered_df$longitude) <- "Longitude"
var_label(tweets_truth_clustered_df$longitude) <- "Longitude"

var_label(tweets_all_clustered_df$latitude) <- "Latitude"
var_label(tweets_truth_clustered_df$latitude) <- "Latitude"

#### Export
saveRDS(tweets_all_clustered_df, file.path(dropbox_file_path, "Data", "Twitter", "Tweets All", "FinalData", "Full Tweets", "rds", "tweet_unique_crashes.Rds"))
write_dta(tweets_all_clustered_df, file.path(dropbox_file_path, "Data", "Twitter", "Tweets All", "FinalData", "Full Tweets", "dta", "tweet_unique_crashes.dta"))

saveRDS(tweets_truth_clustered_df, file.path(dropbox_file_path, "Data", "Twitter", "Tweets All", "FinalData", "Full Tweets", "rds", "tweet_unique_crashes_truth.Rds"))
write_dta(tweets_truth_clustered_df, file.path(dropbox_file_path, "Data", "Twitter", "Tweets All", "FinalData", "Full Tweets", "dta", "tweet_unique_crashes_truth.dta"))


