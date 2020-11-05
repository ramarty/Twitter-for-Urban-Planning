# Proportion of tweet-based crashes verified by Sendy where a crash was identified

## Load data
sendy_df <- read.csv(file.path(data_sendy_dir, "sendy_data.csv"),
                     stringsAsFactors = F)

## Remove cases where driver couldn't reach crash
sendy_df <- sendy_df[!(sendy_df$why_no_crash %in% "Cannot Reach"),]

## Variable for verifying crash
sendy_df$verified_crash <- sendy_df$observe_crash %in% "Crash There" | sendy_df$why_no_crash %in% c("Crash Cleared", "Crash Nearby")

## Stats
nrow(sendy_df) # Total Observations
mean(sendy_df$verified_crash) # Proportion crash verified
