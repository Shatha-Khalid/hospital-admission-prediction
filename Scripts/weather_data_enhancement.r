###############################################################################
# Script Name: weather_data_enhancement.R
# Description: 
#   - Enhance weather dataset by adding features: is_weekend, is_holiday, temp_range.
#   - Apply one-hot encoding for season variable.
###############################################################################

# ------------------------- Load Required Libraries -------------------------
if (!require("dplyr")) install.packages("dplyr")
library(dplyr)

# ------------------------- Configuration -------------------------
BASE_DIR <- getwd()
input_path <- file.path(BASE_DIR, "outputs", "weather_cleaned_knn.csv")
output_dir <- file.path(BASE_DIR, "outputs")
output_file <- file.path(output_dir, "weather_enhanced.csv")

if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# ------------------------- Load Dataset -------------------------
weather <- read.csv(input_path)
weather$date <- as.Date(weather$date)

# ------------------------- Feature Engineering -------------------------

# 1. Add is_weekend Column (Saturday & Sunday)
weather$is_weekend <- ifelse(weekdays(weather$date) %in% c("Saturday", "Sunday"), 1, 0)

# 2. Add is_holiday Column (US Federal Holidays)
us_holidays <- as.Date(c(
    # 2014
    "2014-01-01", "2014-01-20", "2014-02-17", "2014-05-26", "2014-07-04", "2014-09-01", "2014-10-13", "2014-11-11", "2014-11-27", "2014-12-25",
    # 2015
    "2015-01-01", "2015-01-19", "2015-02-16", "2015-05-25", "2015-07-04", "2015-09-07", "2015-10-12", "2015-11-11", "2015-11-26", "2015-12-25",
    # 2016
    "2016-01-01", "2016-01-18", "2016-02-15", "2016-05-30", "2016-07-04", "2016-09-05", "2016-10-10", "2016-11-11", "2016-11-24", "2016-12-25",
    # 2017
    "2017-01-01", "2017-01-16", "2017-02-20"
))
weather$is_holiday <- ifelse(weather$date %in% us_holidays, 1, 0)

# 3. Add temp_range Column
weather$temp_range <- weather$temp_max - weather$temp_min

# 4. One-Hot Encode Season Column
weather$season <- as.factor(weather$season)
season_dummies <- model.matrix(~ season - 1, data = weather)
weather <- cbind(weather, season_dummies)
weather$season <- NULL  # Remove original season column

# ------------------------- Save Enhanced Dataset -------------------------
write.csv(weather, output_file, row.names = FALSE)
cat("Weather dataset enhanced and saved successfully at:", output_file, "\n")
