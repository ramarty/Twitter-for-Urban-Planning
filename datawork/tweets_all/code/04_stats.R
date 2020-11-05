# Provide Basic Summary Stats from Waze Data

# Load Data --------------------------------------------------------------------
tweets <- readRDS(file.path(tweets_all_dir, "data", "processed_data", "tweets_classified_geoparsed.Rds"))
crashes <- readRDS(file.path(tweets_all_dir, "data", "processed_data", "tweets_classified_geoparsed_uniquecrashes.Rds"))

# Stats ------------------------------------------------------------------------
## Number of Tweets
tweets %>%
  nrow()

## Prop Tweets between 9pm and 6am
tweets <- tweets %>%
  mutate(hour = created_at_nairobitime %>% hour) %>%
  mutate(occur_9to6 = hour %in% c(21:23,0:5))
tweets$occur_9to6 %>% mean()

## Number Crash Tweets
tweets %>%
  filter(crash_tweet_algorithm %in% T) %>%
  nrow()

## Prop Crash Tweets between 9pm and 6am
tweets %>%
  filter(crash_tweet_algorithm %in% T) %>%
  pull(occur_9to6) %>%
  mean()

## Number of Geocoded Crash Tweets
tweets %>%
  filter(!is.na(lat_alg)) %>%
  filter(crash_tweet_algorithm %in% T) %>%
  nrow()

## Number of Unique Crashes
crashes %>% 
  nrow()


