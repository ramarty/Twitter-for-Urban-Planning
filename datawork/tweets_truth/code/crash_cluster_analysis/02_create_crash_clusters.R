# Cluster Crashes

# Load Data --------------------------------------------------------------------
crashes_sdf <- readRDS(file.path(tweets_truth_dir, "data", "processed_data", 
                                 "crash_cluster_analysis", 
                                 "tweets_truth_uniquecrash.Rds"))

crashes_sdf <- spTransform(crashes_sdf, CRS(NAIROBI_UTM_PROJ))

# Grab centroid and make dataframe ---------------------------------------------
crashes_coords <- coordinates(crashes_sdf) %>%
  as.data.frame() %>%
  dplyr::rename(long = V1,
                lat = V2) 
crashes_df <- bind_cols(crashes_sdf@data, crashes_coords)

# Cluster Crashes --------------------------------------------------------------
crashes_df_cluster <- create_crash_clusters(crashes_df = crashes_df, 
                                            lat_var = "lat", 
                                            lon_var = "long", 
                                            distance = 300, 
                                            sp_out = F)

# Export -----------------------------------------------------------------------
saveRDS(crashes_df_cluster,
        file.path(tweets_truth_dir, "data", "processed_data", 
                  "crash_cluster_analysis", 
                  "tweets_truth_crashcluster.Rds"))








