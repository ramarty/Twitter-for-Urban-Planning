# Tweet Classification
# Classify Tweets as Crash Related or Not

#### Parameters 
K_FOLDS <- 4
set.seed(42)

RUN_NB <- T
RUN_SVM <- T

# ** FUNCTIONS ** ==============================================================

# Calculate Performance --------------------------------------------------------
calc_performance <- function(pred, truth){
  # Given vectors of predictions and truth data, calculate recall, precision,
  # accuracy and f1 stat
  
  recall <- sum((truth %in% T) & (pred %in% T)) / sum(truth %in% T)
  precision <- sum((truth %in% T) & (pred %in% T)) / sum(pred %in% T)
  accuracy <- mean(truth == pred)
  f1 <- (2 * precision * recall) / (precision + recall)
  
  df_out <- data.frame(recall = recall,
                       precision = precision,
                       accuracy = accuracy,
                       f1 = f1)
  
  return(df_out)
}

# Prep DFM ---------------------------------------------------------------------
prep_dfm <- function(df, params_df){
  # Prep dfm based on parameters
  
  dfm <- tokens(x=df[[params_df$tweet_var]], what="word") %>%
    tokens_ngrams(n=1:params_df$ngram_max, conc=" ") %>%
    dfm(tolower=T) %>%
    dfm_trim(min_docfreq=0.0002, docfreq_type = "prop")  %>% # always take out super few
    dfm_trim(min_docfreq=params_df$trim, docfreq_type = "prop")  %>%
    dfm_trim(max_docfreq=(1-params_df$trim), docfreq_type = "prop") 
  
  if(params_df$tfid %in% "TRUE"){
    dfm <- dfm_tfidf(dfm)
  }
  
  return(dfm)
}

# Grid Search: DFM Based Input -------------------------------------------------
grid_search_with_dfm <- function(params, model_type){
  
  # Loop through parameters - - - - - - - - - - - - - - - - - - - - - - - - - - 
  results_all_df <- lapply(params$model, function(model_i){
    
    print(model_i)
    
    #### Prep DFM
    params_i <- params[model_i,]
    dfm <- prep_dfm(truth_data, params_i)
    
    # Loop through folds - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    results_df <- lapply(1:K_FOLDS, function(fold_i){
      
      if(model_type %in% "svm"){
        model <- textmodel_svm(x=dfm[k_fold != fold_i,], 
                               y=truth_data$accident_truth[k_fold != fold_i], 
                               weight=params_i$prior,
                               cost = params_i$svm_cost)
        
      } else if(model_type %in% "nb"){
        model <- textmodel_nb(x=dfm[k_fold != fold_i,], 
                              y=truth_data$accident_truth[k_fold != fold_i], 
                              prior=params_i$prior)
        
      } 
      
      predictions <- predict(model, newdata = dfm[k_fold == fold_i,], type="class") %>% as.vector()
      truth <- truth_data$accident_truth[k_fold == fold_i]
      
      predictions <- (predictions %in% "TRUE")
      
      df_out <- calc_performance(predictions,
                                 truth)
      df_out$fold <- fold_i
      
      return(df_out)
    }) %>%
      bind_rows()
    
    # Add parameters to results dataframe - - - - - - - - - - - - - - - - - - - -
    for(var in names(params_i)) results_df[[var]] <- params_i[[var]]
    results_df$model_type <- model_type
    
    # saveRDS(results_df,
    #         file.path(dropbox_file_path, "Data", "Twitter",
    #                   "Tweet Classification Geocoding Algorithm",
    #                   "tweet_classification",
    #                   "results",
    #                   "individual_files",
    #                   paste0(model_type, model_i, ".Rds")))
    
    return(results_df)
  }) %>%
    bind_rows()
  
  return(results_all_df)
}

# ** DATAWORK ** ===============================================================

# Load Data --------------------------------------------------------------------
truth_data <- readRDS(file.path(replication_data_path, "tweets", "processed_data",
                                "tweets_truth_for_classification.Rds"))

## One year sample
truth_data$date <- truth_data$created_at_nairobitime %>% as.Date()
truth_data <- truth_data %>%
  filter(date >= "2017-07-01",
         date <= "2018-07-31")

# Train and Test Sets ----------------------------------------------------------
# Randomly sort truth data and divide into K_FOLDS folds

truth_data <- truth_data[sample(1:nrow(truth_data)),]
k_fold <- rep(1:K_FOLDS, length.out = nrow(truth_data)) 

# Parameters -------------------------------------------------------------------
# Create dataframe of parameters to try. First create master parameter
# dataframe, then filter out for relevant parameters for SVM and NB

#### Parameter List
ngram_max <- 1:3
prior <- c("uniform", "docfreq", "termfreq")
trim <- c(0, 0.01, 0.05) 
tweet_var <- c("tweet") # "tweet_aug"
tfid <- c(T, F)
svm_cost <- c(0.5, 1, 2, 10, 100, 1000)

#### Parameters
all_params <- list(ngram_max = ngram_max,
                   prior = prior,
                   trim = trim,
                   tweet_var = tweet_var,
                   tfid = tfid,
                   svm_cost = svm_cost) %>%
  as.data.frame() %>%
  mutate_all(as.factor) %>%
  complete(ngram_max, prior, trim, tweet_var, tfid, svm_cost) %>%
  mutate_all(as.character) %>%
  mutate_at(c("trim", "svm_cost", "ngram_max"), as.numeric)

## SVM Parameters
svm_params <- all_params[all_params$prior %in% "uniform",]

## NB Parameters
nb_params <- all_params %>%
  filter(svm_cost %in% 1) %>%
  dplyr::select(-svm_cost)

#### Add model number
svm_params$model <- 1:nrow(svm_params)
nb_params$model  <- 1:nrow(nb_params)

# Run Models -------------------------------------------------------------------
if(RUN_NB){
  nb_results <- grid_search_with_dfm(nb_params, "nb")
  
  write.csv(nb_results, file.path(data_tweetsalgresults_dir,
                                  "tweet_classification_results_nb.csv"),
            row.names = F)
}

if(RUN_SVM){
  svm_results <- grid_search_with_dfm(svm_params, "svm")
  
  write.csv(svm_results, file.path(data_tweetsalgresults_dir,
                                   "tweet_classification_results_svm.csv"),
            row.names = F)
}




