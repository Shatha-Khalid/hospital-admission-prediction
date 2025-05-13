###############################################################################
# Script Name: temporal_data_splitting_smote.R
# Description: 
#   - Temporal splitting of data after applying SMOTE balancing.
#   - Generate visit_datetime based on available time features.
#   - Split data into train, validation, and test sets (80%, 10%, 10%).
#   - Save splits for future modeling experiments.
###############################################################################

# ------------------------- Install and Load Required Libraries -------------------------
if (!require("dplyr")) install.packages("dplyr")
if (!require("lubridate")) install.packages("lubridate")
if (!require("readr")) install.packages("readr")
if (!require("forecast")) install.packages("forecast")
if (!require("caret")) install.packages("caret")

library(dplyr)
library(lubridate)
library(readr)
library(forecast)
library(caret)

# ------------------------- Configuration Parameters -------------------------
BASE_DIR <- getwd()
input_path <- file.path(BASE_DIR, "outputs", "smote_balancing_preprocessing.csv")
output_dir <- file.path(BASE_DIR, "outputs", "temporal_splitting_smote")

if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# ------------------------- Load Dataset -------------------------
data <- read.csv(input_path)
data$disposition <- as.factor(data$disposition)

# ------------------------- Validate Time Columns -------------------------
required_cols <- c("arrivalmonth_num", "hour")
if (!all(required_cols %in% names(data))) {
    stop("Error: Required columns 'arrivalmonth_num' or 'hour' are missing from the dataset.")
}

# ------------------------- Generate Date-Time Columns -------------------------
data$year  <- 2014 + floor((data$arrivalmonth_num - 3) / 12)
data$month <- ((data$arrivalmonth_num - 3) %% 12) + 3
data <- data %>% mutate(day = 1 + (row_number() %% 28))

data$year  <- as.integer(data$year)
data$month <- as.integer(data$month)
data$day   <- as.integer(data$day)
data$hour  <- as.integer(data$hour)

data$visit_datetime <- make_datetime(
    year = data$year,
    month = data$month,
    day = data$day,
    hour = data$hour,
    min = 0,
    sec = 0
)

# ------------------------- Sort Data Chronologically -------------------------
data_sorted <- data %>% arrange(visit_datetime)

# ------------------------- Temporal Splitting -------------------------
n <- nrow(data_sorted)
train_size <- floor(0.8 * n)
val_size   <- floor(0.1 * n)

train_data <- data_sorted[1:train_size, ]
val_data   <- data_sorted[(train_size + 1):(train_size + val_size), ]
test_data  <- data_sorted[(train_size + val_size + 1):n, ]

# ------------------------- Save Splits Function -------------------------
save_split <- function(part, name) {
    X <- part %>% select(-disposition)
    y <- part["disposition"]
    write.csv(X, file.path(output_dir, paste0("X_", name, "_time.csv")), row.names = FALSE)
    write.csv(y, file.path(output_dir, paste0("y_", name, "_time.csv")), row.names = FALSE)
}

# ------------------------- Save Files -------------------------
save_split(train_data, "train")
save_split(val_data, "val")
save_split(test_data, "test")

cat("Temporal data splitting completed successfully. Files saved in:", output_dir, "\n")
