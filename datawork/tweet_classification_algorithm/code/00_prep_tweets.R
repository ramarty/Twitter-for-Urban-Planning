# Tweet Classification
# Classify Tweets as Crash Related or Not

#### Parameters 
#K_FOLDS <- 4
#CHUNK_SIZE <- 300
#set.seed(42)

# Load Data --------------------------------------------------------------------
truth_data <- readRDS(file.path(replication_data_path, "tweets", "raw_data", "tweets_truth.Rds"))

# Clean Tweet Text -------------------------------------------------------------
truth_data$tweet <- iconv(truth_data$tweet, "latin1", "ASCII", sub="")
truth_data$tweet <- truth_data$tweet %>%
  str_to_lower %>%
  str_replace_all("\\br/about\\b", "round about") %>%
  
  str_replace_all("\\.", " ") %>%
  str_replace_all("via @[a-z_,A-Z_,0-9_]*", "") %>%
  str_replace_all("@[a-z_,A-Z_,0-9_]*", "") %>%
  str_replace_all(","," , ") %>% # Add space between commas (eg, "road,allsops") 
  str_replace_all("\n", "") %>%
  str_replace_all("~", "") %>%
  str_replace_all("\\b(http|https)://t.co/[0-9,A-Z, a-z]*\\b", "") %>%
  str_replace_all("\\b(http|https)://t.co/[0-9,A-Z, a-z]", "") %>%
  str_replace_all("\\b(http|https)://t.co\\b", "") %>%
  str_replace_all("\\b(http|https):", "") %>%
  str_replace_all("~more*", "") %>%
  str_replace_all("(RT|rt) @[a-z,A-Z,0-9, _]*:", "") %>%
  str_replace_all("^[0-9][0-9]\\:[0-9][0-9]", "") %>%
  str_replace_all("[[:punct:]]", "") %>%
  str_replace_all("\\bamp\\b", "and") %>%
  str_squish

# Restrict to Potentially Accident Related Tweets ------------------------------
truth_data$potentially_accident_related <- class_potnt_crash(truth_data$tweet)

truth_data <- truth_data[truth_data$potentially_accident_related %in% T,]

# # Replace landmarks and roads with LANDMARK, ROAD ------------------------------
# # Creates augmented tweet. For example, changes the tweet: 
# # "crash on thika rd near garden city" with "crash on roadnamegeneral near landmarknamegeneral"
# 
# #### Load data and clean names
# # Use augmented road and landmark names
# roads <- readRDS(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm", "augmented_gazetteers", "osm_roads_aug.Rds"))
# landmark_gazetteer_aug <- readRDS(file.path(dropbox_file_path, "Data", "Twitter", "Tweet Classification Geocoding Algorithm", "augmented_gazetteers", "landmarks_aug.Rds"))
# 
# #roads <- roads[1:100,] # FOR TESTING CODE; DELETE LATER
# #landmark_gazetteer_aug <- landmark_gazetteer_aug[1:100,]
# 
# roads_names <- roads$name %>% as.character %>% tolower %>% unique
# landmark_gazetteer_aug_names <- landmark_gazetteer_aug$name %>% str_replace_all("[[:punct:]]", "") %>% unique
# 
# #### Restrict landmark and road names to ones potentially in tweets
# # For more efficiently replacing road and landmark names with "...namegeneral",
# # restrict the list of road and landmark names to ones that potentially appear in
# # the tweet by checking against words in tweets. To make this process more
# # efficient, we ignore word boundaries.
# 
# # Concatenate all tweets and extract all road names that appear in the
# # concatenated tweet text.
# roads_candidates <- paste(truth_data$tweet, collapse=" ") %>%
#   str_extract_all(fixed(roads_names)) %>% 
#   unlist() %>%
#   unique
# 
# # The above process would take much longer on the longer list of landmark
# # gazetteer names. Instead, we take all 1-3 ngrams in tweets and restrict to
# # landmarks that match those n-grams
# tweet_ngrams <- tokens(x=truth_data$tweet, what="word", ngrams=1:3, conc=" ") %>% unlist %>% as.character %>% unique
# landmark_aug_candidates <- landmark_gazetteer_aug_names[landmark_gazetteer_aug_names %in% tweet_ngrams]
# 
# #### Convert list of names to regex string
# # Roads list simply combined to reges string. landmark list is longer and to help
# # with efficiency we break the list into two.
# roads_regex <- paste0("\\b",roads_candidates,"\\b") %>% paste(collapse="|")
# 
# half <- round(length(landmark_aug_candidates)/2)
# landmarks_aug_regex_1 <- paste0("\\b",landmark_aug_candidates[1:half],"\\b") %>% paste(collapse="|")
# landmarks_aug_regex_2 <- paste0("\\b",landmark_aug_candidates[(half+1):length(landmark_aug_candidates)],"\\b") %>% paste(collapse="|")
# 
# #### Replace landmark/roads with general name
# starts <- seq(from=1, to=nrow(truth_data),by=CHUNK_SIZE)
# replace_tweets_with_roads_landmarks <- function(start){
#   print(start)
#   end <- min(start + CHUNK_SIZE - 1, nrow(truth_data))
#   out <- truth_data$tweet[start:end] %>% 
#     str_replace_all(roads_regex, "roadnamegeneral") %>%
#     str_replace_all(landmarks_aug_regex_1, "landmarknamegeneral") %>%
#     str_replace_all(landmarks_aug_regex_2, "landmarknamegeneral")
#   return(out)
# }
# truth_data$tweet_aug <- lapply(starts, replace_tweets_with_roads_landmarks) %>% unlist

# Export -----------------------------------------------------------------------
saveRDS(truth_data, file.path(replication_data_path, "data_tweetsclassif_dir",
                              "tweets_truth_for_classification.Rds"))



