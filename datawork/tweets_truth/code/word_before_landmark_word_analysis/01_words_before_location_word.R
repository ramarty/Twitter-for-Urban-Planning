# Patterns of words/phrases that come before location word

# Load Data --------------------------------------------------------------------
# Restrict to observations included in the truth dataset and where we know how the
# landmark used to geocode the tweet was written in the tweet.
truth_data_all <- readRDS(file.path(data_tweets_dir, "raw_data", "tweets_truth.Rds"))

truth_data_alg <- truth_data_all %>%
  filter(!is.na(crash_landmark),
         accident_truth %in% T)

# Prep Data --------------------------------------------------------------------
# The "crash_landmark" variable contains the landmark used to geocode the tweet
# that is written the same way as in the tweet. We replace the landmark (word or
# phrase) in the tweet with "landmark_here", where we then examine words that come
# before "landmark_here"
truth_data_alg$tweet <- truth_data_alg$tweet %>% 
  str_replace_all(truth_data_alg$crash_landmark, "landmark_here") %>%
  str_replace_all("\\bthe\\b", " ") %>%
  str_squish()

# Function ---------------------------------------------------------------------
text_before_landmark_df <- lapply(1:nrow(truth_data_alg), function(i){
  # Create a dataset at the tweet level that indicates:
  # (1) 1-grams, 2-grams and 3-grams before landmark word
  # (2) 1-grams, 2-grams and 3-grams two words before landmark word
  # Additional, it creates variables indicating whether the ngrams occur
  # somewhere else in the tweet besides infront on of the landmark. Here, 
  # we count the number of times the ngram occurs -- if it occurs more than
  # once we know it occured somewhere else.
  
  if((i %% 500) == 0) print(i)
  
  #### Restrict to tweet i
  truth_data_alg_i <- truth_data_alg[i,]
  
  #### Text Original
  # We need the original tweet text to determine whether the ngram occurs more than
  # just in front of the ngram. For this, we look both before and after the landmark 
  # word.
  #text_original <- truth_data_alg_i$tweet
  
  #### Text of tweet of just words that come before landmark and break into individual words. 
  tweet_words_before_landmark <- truth_data_alg_i$tweet %>% 
    str_replace_all("landmark_here.*", "") %>% 
    str_squish() %>%
    strsplit(" ") %>%
    unlist() %>%
    
    # Reversing of order of words will make it easier to grab words and phrase. 
    # Because of this, when grabbing ngram will need to reverse again to get
    # orginal text.
    rev()
  
  #### Extract grams
  ngram1_1beforelandmark <- tweet_words_before_landmark[1]
  ngram1_2beforelandmark <- tweet_words_before_landmark[2]
  ngram1_3beforelandmark <- tweet_words_before_landmark[3]
  
  ngram2_1beforelandmark <- tweet_words_before_landmark[1:2] %>% rev() %>% paste(collapse=" ")
  ngram2_2beforelandmark <- tweet_words_before_landmark[2:3] %>% rev() %>% paste(collapse=" ")
  ngram2_3beforelandmark <- tweet_words_before_landmark[3:4] %>% rev() %>% paste(collapse=" ")
  
  #### Determine whether gram appears elsewhere in tweet
  ngram1_1beforelandmark_N <- str_count(truth_data_alg_i$tweet, paste0("\\b", ngram1_1beforelandmark, "\\b")) %>% na_if(0)
  ngram1_2beforelandmark_N <- str_count(truth_data_alg_i$tweet, paste0("\\b", ngram1_2beforelandmark, "\\b")) %>% na_if(0)
  ngram1_3beforelandmark_N <- str_count(truth_data_alg_i$tweet, paste0("\\b", ngram1_3beforelandmark, "\\b")) %>% na_if(0)
  
  ngram2_1beforelandmark_N <- str_count(truth_data_alg_i$tweet, paste0("\\b", ngram2_1beforelandmark, "\\b")) %>% na_if(0)
  ngram2_2beforelandmark_N <- str_count(truth_data_alg_i$tweet, paste0("\\b", ngram2_2beforelandmark, "\\b")) %>% na_if(0)
  ngram2_3beforelandmark_N <- str_count(truth_data_alg_i$tweet, paste0("\\b", ngram2_3beforelandmark, "\\b")) %>% na_if(0)
  
  #### Dataframe to Ouput
  df_out <- data.frame(status_id_str = truth_data_alg_i$status_id_str,
                       ngram1_1beforelandmark,
                       ngram1_2beforelandmark,
                       ngram1_3beforelandmark,
                       ngram2_1beforelandmark,
                       ngram2_2beforelandmark,
                       ngram2_3beforelandmark,
                       ngram1_1beforelandmark_N,
                       ngram1_2beforelandmark_N,
                       ngram1_3beforelandmark_N,
                       ngram2_1beforelandmark_N,
                       ngram2_2beforelandmark_N,
                       ngram2_3beforelandmark_N)
  
  return(df_out)
  
}) %>% bind_rows

truth_data_all <- merge(truth_data_all,
                        text_before_landmark_df,
                        by = "status_id_str",
                        all.x = T,
                        all.y = F)

# Export -----------------------------------------------------------------------
saveRDS(truth_data_all, file.path(data_tweets_dir, "processed_data", "tweets_truth_clean.Rds"))


# 
# 
# #### Create 1gram and 2gram functions
# 
# ## Create list of 1grams
# create_1gram <- function(text){
#   out <- text %>%
#     strsplit(" ") %>%
#     unlist()
#   
#   return(out)
# }
# 
# ## Create list of 2grams
# create_2gram <- function(text){
#   out <- text %>% 
#     strsplit(" ") %>% 
#     unlist() %>% 
#     ngrams(2L) %>% 
#     lapply(function(x) paste(x, collapse=" ")) %>% 
#     unlist()
#   
#   return(out)
# }
# 
# 
# #text_occurs_somewhere_else <- function(df, )
# 
# # Analysis ---------------------------------------------------------------------
# #var <- "ngram1_1beforelandmark"
# #text_before_tweet_list <- unique(text_before_landmark_df$ngram1_1beforelandmark)
# #text_before_tweet_i <- text_before_tweet_list[1]
# 
# calc_text_prop_beforelandmark_elsewhere <- function(text_before_tweet_i, var, text_before_landmark_df){
#   # Calcualtes the proportion that text (1 or 2gram) occurs before a landmark and elsewhere
#   # by "before a landmark", we consider 1, 2 and 3 words before landmark.
#   
#   print(text_before_tweet_i)
#   
#   #### Proportion of tweets where the ngram comes before landmark
#   prop_text_occurs_before_landmark <- text_before_landmark_df[[var]] %in% text_before_tweet_i %>% mean()
#   
#   #### Proportion of tweets where the ngram does not come before landmark. 
#   # 1. For tweets where the ngram comes before the landmark, check if ngram 
#   #    occurs > 1. (1 time for before the landmark, and other times not before landmark)
#   # 2. For tweets where the ngram does not come before the landmark, check if ngram
#   #    occures > 0.
#   tweets_word_before_landmark <- text_before_landmark_df$tweet[text_before_landmark_df[[var]] %in% text_before_tweet_i]
#   tweets_word_not_before_landmark <- text_before_landmark_df$tweet[!(text_before_landmark_df[[var]] %in% text_before_tweet_i)]
#   
#   # Count number of words of text before word, as different process for 1 and 2grams
#   text_before_tweet_i_Nwords <- words(text_before_tweet_i) %>% length()
#   
#   if(text_before_tweet_i_Nwords %in% 1){
#     
#     TF_beforelandmark_elsewhere <- lapply(tweets_word_before_landmark, function(text){
#       text_list <- create_1gram(text)
#       out <- (text_list %in% text_before_tweet_i) %>% sum() > 1
#       return(out)
#     }) %>% unlist 
#     
#     TF_notbeforelandmark_elsewhere <- lapply(tweets_word_not_before_landmark, function(text){
#       text_list <- create_1gram(text)
#       out <- (text_list %in% text_before_tweet_i) %>% sum() > 0
#       return(out)
#     }) %>% unlist
#     
#     prop_text_elsewhere <- c(TF_beforelandmark_elsewhere, TF_notbeforelandmark_elsewhere) %>% mean()
#   }
#   
#   if(text_before_tweet_i_Nwords %in% 2){
#     
#     TF_beforelandmark_elsewhere <- lapply(tweets_word_before_landmark, function(text){
#       text_list <- create_2gram(text)
#       out <- (text_list %in% text_before_tweet_i) %>% sum() > 1
#       return(out)
#     }) %>% unlist 
#     
#     TF_notbeforelandmark_elsewhere <- lapply(tweets_word_not_before_landmark, function(text){
#       text_list <- create_2gram(text)
#       out <- (text_list %in% text_before_tweet_i) %>% sum() > 0
#       return(out)
#     }) %>% unlist
#     
#     prop_text_elsewhere <- c(TF_beforelandmark_elsewhere, TF_notbeforelandmark_elsewhere) %>% mean()
#   }
#   
#   df_out <- data.frame(text = text_before_tweet_i,
#                        variable = var,
#                        prop_text_elsewhere = prop_text_elsewhere,
#                        prop_text_occurs_before_landmark = prop_text_occurs_before_landmark)
#   
#   return(df_out)
# }
# 
# # Create Dataframe for Analysis ------------------------------------------------
# # Only consider words with some level of frequency of occurence
# 
# #### 1gram 1before landmark
# ngram1_1beforelandmark_freq <- text_before_landmark_df %>%
#   group_by(ngram1_1beforelandmark) %>%
#   summarise(N = n()) %>%
#   filter(N >= 5)
# 
# ngram1_1beforelandmark_df <- lapply(ngram1_1beforelandmark_freq$ngram1_1beforelandmark, 
#                                     calc_text_prop_beforelandmark_elsewhere,
#                                     "ngram1_1beforelandmark",
#                                     text_before_landmark_df) %>% bind_rows()
# 
# #### 2gram 1before landmark
# ngram2_1beforelandmark_freq <- text_before_landmark_df %>%
#   group_by(ngram2_1beforelandmark) %>%
#   summarise(N = n()) %>%
#   filter(N >= 25)
# 
# ngram2_1beforelandmark_df <- lapply(ngram2_1beforelandmark_freq$ngram2_1beforelandmark, 
#                                     calc_text_prop_beforelandmark_elsewhere,
#                                     "ngram2_1beforelandmark",
#                                     text_before_landmark_df) %>% bind_rows()
# 
# #### Append Dataframes
# ngramALL_ALLbeforelandmark_df <- bind_rows(ngram1_1beforelandmark_df,
#                                            ngram2_1beforelandmark_df)
# 
# ngramALL_ALLbeforelandmark_df$greater_likelihood_before_landmark <- ngramALL_ALLbeforelandmark_df$prop_text_occurs_before_landmark / ngramALL_ALLbeforelandmark_df$prop_text_elsewhere
# 
# #### Only consider text that appears in >= .5% of tweets
# ngramALL_ALLbeforelandmark_df <- ngramALL_ALLbeforelandmark_df[ngramALL_ALLbeforelandmark_df$prop_text_occurs_before_landmark >= 0.005,] 
# 
# ngramALL_ALLbeforelandmark_df <- ngramALL_ALLbeforelandmark_df[!is.na(ngramALL_ALLbeforelandmark_df$text),]
# 
# # Make table -------------------------------------------------------------------
# ROUND_NUM <- 3
# ngramALL_ALLbeforelandmark_df <- ngramALL_ALLbeforelandmark_df[order(ngramALL_ALLbeforelandmark_df$greater_likelihood_before_landmark, decreasing = T),]
# 
# sink(file.path(outputs_file_path, "Papers", "Algorithm", "Tables", "text_before_landmark_summary.tex"))
# cat("\\begin{tabular}{cccc} ")
# cat("\\hline ")
# cat("Text & \\multicolumn{2}{c}{Proportion of tweets where text appears...} & Likelihood of text  \\\\ ")
# cat("     & ...before landmark & ...elsewhere & before landmark not elsewhere \\\\ ")
# cat("\\hline ")
# for(i in 1:nrow(ngramALL_ALLbeforelandmark_df)){
#   df_i <- ngramALL_ALLbeforelandmark_df[i,]
#   
#   cat(
#     df_i$text, " & ",
#     df_i$prop_text_occurs_before_landmark %>% round(5), " & ",
#     df_i$prop_text_elsewhere %>% round(5), " & ",
#     df_i$greater_likelihood_before_landmark %>% round(3), " \\\\ "
#   )
#   
# }
# cat("\\hline ")
# cat("\\end{tabular} ")
# sink()
# 
# 
# 
