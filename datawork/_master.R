# Applying machine learning and geolocation techniques to social
# media data (Twitter) to develop a resource for urban planning

# Master R Script

# Filepaths --------------------------------------------------------------------

#### Root file path
project_dir <- "~/Documents/Github/CrashMap-Nairobi/Replication Code for Outputs/smarTTrans Algorithm Technical Paper"

#### Datawork Paths
datawork_dir            <- file.path(project_dir, "datawork")
tweets_all_dir          <- file.path(datawork_dir, "tweets_all")
tweets_truth_dir        <- file.path(datawork_dir, "tweets_truth")

tweets_classif_dir      <- file.path(datawork_dir, "tweet_classification_algorithm")
tweets_geoparse_dir     <- file.path(datawork_dir, "tweet_geoparse_algorithm")
landmarkgaz_dir         <- file.path(datawork_dir, "landmark_gazetteer")
roadgaz_dir             <- file.path(datawork_dir, "road_gazetteer")
estates_dir             <- file.path(datawork_dir, "nairobi_estates")
gadm_dir                <- file.path(datawork_dir, "gadm")
sendy_dir               <- file.path(datawork_dir, "sendy")
google_places_dir       <- file.path(datawork_dir, "google_places")
osm_dir                 <- file.path(datawork_dir, "osm")
geonames_dir            <- file.path(datawork_dir, "geonames")

## Outputs
outputs_dir <- file.path(project_dir, "outputs")
tables_dir  <- file.path(outputs_dir, "tables")
figures_dir <- file.path(outputs_dir, "figures")

# Parameters -------------------------------------------------------------------
NAIROBI_UTM_PROJ <- "+init=epsg:21037"

# Libraries --------------------------------------------------------------------
library(dplyr)
library(spacyr)
library(purrr)
library(ggplot2)
library(ggpubr)

## Unique Location Extractor
source("https://raw.githubusercontent.com/ramarty/Unique-Location-Extractor/master/R/load_ulex.R")

## Clustering Functions
figures_dir <- file.path(project_dir, "functions_and_packages", "clustering", "cluster_crashes_into_unique_crashes.R")
figures_dir <- file.path(project_dir, "functions_and_packages", "clustering", "cluster_crashes_into_clusters.R")

# CODE =========================================================================

# 1. Download GADM =============================================================
# Download GADM boundary for Kenya. GADM boundaries used in multiple scripts
source(file.path(gadm_dir, "code", "download_gadm.R"))

# 2. Gazetteers ================================================================

# ** 2.1 Prep data from individual sources -------------------------------------
# The gazetteers are made from multiple sources. These scripts clean data
# from individual data sources

#### Google Paces
source(file.path(google_places_dir, "code", "scrape_data_googlepaces.R"))

#### OSM
## Prep data from different OSM sources
source(file.path(osm_dir, "code", "crop_geofabrik_to_nairobi.R"))
source(file.path(osm_dir, "code", "download_from_overpass_api.R"))

## Create and clean landmark file from OSM
source(file.path(osm_dir, "code", "landmarks", "append_landmarks.R"))

## Clean roads file from OSM
source(file.path(osm_dir, "code", "roads", "01_create_raw_road_gazetteer.R"))
source(file.path(osm_dir, "code", "roads", "02_augment_road_gazetteer.R"))

#### OSM
source(file.path(geonames_dir, "code", "clean_geonames.R"))

# ** 2.2 Create landmark gazetteers --------------------------------------------
# Appends data from individual sources to create raw and augmented landmark
# gazetteers

source(file.path(landmarkgaz_dir, "code", "01_raw_landmark_gazetteer.R"))
source(file.path(landmarkgaz_dir, "code", "02_augment_landmark_gazetteer.R"))

# ** 2.3 Create road gazetteers ------------------------------------------------

source(file.path(osm_dir, "code", "roads", "01_create_raw_road_gazetteer.R"))
source(file.path(osm_dir, "code", "roads", "02_augment_road_gazetteer.R"))

# 3. Analysis of words that come before landmark words =========================

source(file.path(tweets_truth_dir, "code", "word_before_landmark_word_analysis", "01_words_before_location_word.R"))
source(file.path(tweets_truth_dir, "code", "word_before_landmark_word_analysis", "02_make_dataset_word_pairs.R"))
source(file.path(tweets_truth_dir, "code", "word_before_landmark_word_analysis", "03_determine_preposition_tiers.R"))

# [figure_s3.png]
source(file.path(tweets_truth_dir, "code", "word_before_landmark_word_analysis", "03_top_words_before_landmark_figure.R"))

# [figure_s4.png]
source(file.path(tweets_truth_dir, "code", "word_before_landmark_word_analysis", "03_word_importance_figure.R"))

# 4. Analysis of landmark types ================================================
source(file.path(tweets_truth_dir, "code", "landmark_type_analysis", "figure_landmark_types.R"))

# 5. Tweet Classification Algorithm ============================================

# Functions used for classification algorithm
source(file.path(tweets_classif_dir, "code", "_functions.R"))

# Cleans tweet names and determines which are potentially accident related
source(file.path(tweets_classif_dir, "code", "00_prep_tweets.R"))

# Trains Naive Bayes and SVM models using multiple parameters. Exports dataframe
# of results
source(file.path(tweets_classif_dir, "code", "01_grid_search.R"))

# Cleans results data
source(file.path(tweets_classif_dir, "code", "02_clean_results_data.R"))

# Saves best model
source(file.path(tweets_classif_dir, "code", "03_save_best_model.R"))

# Results table [table_s4.tex]
source(file.path(tweets_classif_dir, "code", "04_results_table.R"))

# 6. Tweet Geoparse Algorithm ==================================================
source(file.path(tweets_geoparse_dir, "code", "_functions.R"))
source(file.path(tweets_geoparse_dir, "code", "01_clean_tweet_data_for_testing.R"))
source(file.path(tweets_geoparse_dir, "code", "02_implement_algorithm.R"))
source(file.path(tweets_geoparse_dir, "code", "03_tweet_results_to_long.R"))
source(file.path(tweets_geoparse_dir, "code", "04_results_main.R"))
source(file.path(tweets_geoparse_dir, "code", "04_results_si.R"))
source(file.path(tweets_geoparse_dir, "code", "04_figure_illustrate_algorithm.R"))

# 7. Cluster Algorithm =========================================================

# Calculate rand and jaccard indices
source(file.path(tweets_truth_dir, "code", "cluster_analysis", "cluster_jaccard_rand_calc.R"))

# Figure of rand and jaccard indices [figure_s5.png]
source(file.path(tweets_truth_dir, "code", "cluster_analysis", "cluster_jaccard_rand_figure.R"))

# Cluster summary stats [table_s6.tex]
source(file.path(tweets_truth_dir, "code", "cluster_analysis", "cluster_sum_stat_table.R"))

# 8. Apply Algorithm on Tweets =================================================
source(file.path(tweets_all_dir, "code", "01_classify_crash_tweets.R"))
source(file.path(tweets_all_dir, "code", "02a_geocode_tweets.R"))
source(file.path(tweets_all_dir, "code", "02b_merge_geocodes_to_tweets.R"))
source(file.path(tweets_all_dir, "code", "03_cluster_tweets.R"))
source(file.path(tweets_all_dir, "code", "04_figure_crash_tweet_trends_map.R"))

# 9. Sendy Analysis ============================================================
source(file.path(sendy_dir, "code", "proportion_crashes_verified.R"))























