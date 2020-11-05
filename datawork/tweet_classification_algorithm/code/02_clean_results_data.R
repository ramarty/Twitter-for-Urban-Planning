# Explore Results

# Load Data --------------------------------------------------------------------
results_nb_df <- read.csv(file.path(data_tweetsalgresults_dir, "tweet_classification_results_nb.csv"))
results_svm_df <- read.csv(file.path(data_tweetsalgresults_dir, "tweet_classification_results_svm.csv"))

results_df <- bind_rows(results_nb_df, results_svm_df)

# Aggregate --------------------------------------------------------------------
# Aggregate k-folds
results_agg <- results_df %>%
  group_by(model, model_type) %>%
  dplyr::summarise(recall_mean = mean(recall),
            precision_mean = mean(precision),
            accuracy_mean = mean(accuracy),
            f1_mean = mean(f1),
            
            recall_min = min(recall),
            precision_min = min(precision),
            accuracy_min = min(accuracy),
            f1_min = min(f1),
            
            recall_max = max(recall),
            precision_max = max(precision),
            accuracy_max = max(accuracy),
            f1_max = max(f1))

params <- results_df %>%
  distinct(model, model_type, .keep_all = T) %>%
  dplyr::select(-c(recall, precision, accuracy, f1))

results_agg <- merge(results_agg, params, by = c("model", "model_type"))

# Export -----------------------------------------------------------------------
# write.csv(results_df, file.path(dropbox_file_path, "Data", "Twitter",
#                               "Tweet Classification Geocoding Algorithm",
#                               "tweet_classification",
#                               "results",
#                               "appended",
#                               "results_all.csv"), row.names = T)

write.csv(results_agg, file.path(data_tweetsalgresults_dir,
                               "tweet_classification_results_all_agg.csv"), row.names = F)

