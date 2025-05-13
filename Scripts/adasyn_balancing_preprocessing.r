###############################################################################
# Script Name: adasyn_balancing_preprocessing.R
# Description: 
#   - Preprocess data for modeling by handling temporal variables.
#   - Apply one-hot encoding on categorical variables.
#   - Balance classes using the ADASYN algorithm.
###############################################################################

# ------------------------- Install and Load Required Libraries --------------------------
if (!require("smotefamily")) install.packages("smotefamily")
if (!require("fastDummies")) install.packages("fastDummies")
if (!require("dplyr")) install.packages("dplyr")

library(dplyr)
library(smotefamily)
library(fastDummies)

# ------------------------- Configuration Parameters -------------------------
BASE_DIR <- getwd()  # Project base directory
input_path <- file.path(BASE_DIR, "processed_data", "imputed_full_data.csv")
output_path <- file.path(BASE_DIR, "outputs", "adasyn_balanced_sampled_All_data_imputed.csv")

# ------------------------- Load Dataset -------------------------
data <- read.csv(input_path)
data$disposition <- as.factor(data$disposition)

# ------------------------- Handle Temporal Columns -------------------------
month_map <- list(
  jan = 1, january = 1, feb = 2, february = 2, mar = 3, march = 3,
  apr = 4, april = 4, may = 5, jun = 6, june = 6, jul = 7, july = 7,
  aug = 8, august = 8, sep = 9, sept = 9, september = 9, oct = 10, october = 10,
  nov = 11, november = 11, dec = 12, december = 12
)

standardize_month <- function(x) {
  x <- trimws(tolower(x))
  sapply(x, function(val) {
    if (!is.null(month_map[[val]])) return(month_map[[val]])
    return(NA)
  })
}

data$arrivalmonth_num <- standardize_month(data$arrivalmonth)

weekday_levels <- c("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday")
data$arrivalday_num <- match(trimws(tolower(data$arrivalday)), weekday_levels)

data$hour <- as.numeric(sub("-.*", "", data$arrivalhour_bin))

# Remove original text columns related to time
data <- data %>% select(-arrivalmonth, -arrivalday, -arrivalhour_bin)

# ------------------------- One-Hot Encoding for Categorical Columns -------------------------
text_cols <- c("dep_name", "gender", "ethnicity", "race", "lang", "religion",
               "maritalstatus", "employstatus", "insurance_status",
               "arrivalmode", "previousdispo")

data <- dummy_cols(data, select_columns = text_cols, remove_selected_columns = TRUE)

# ------------------------- Check for Missing Values -------------------------
if (any(is.na(data))) {
  stop("Error: Missing values detected after preprocessing. Please review the data.")
}

# ------------------------- Apply ADASYN -------------------------
X <- data %>% select(-disposition)
y <- data$disposition

set.seed(42)
adasyn_result <- ADAS(X, y, K = 5)

balanced_data <- cbind(adasyn_result$data, disposition = as.factor(adasyn_result$data$class))
balanced_data$class <- NULL  # Remove redundant class column

# ------------------------- Save the Balanced Dataset -------------------------
if (!dir.exists(dirname(output_path))) dir.create(dirname(output_path), recursive = TRUE)
write.csv(balanced_data, output_path, row.names = FALSE)

cat("ADASYN completed successfully. Balanced dataset saved at:", output_path, "\n")
