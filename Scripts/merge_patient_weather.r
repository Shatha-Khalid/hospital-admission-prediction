###############################################################################
# Script Name : merge_patient_weather.R
# Description : Merges patient data with weather data based on visit dates.
###############################################################################

if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")
if (!require("lubridate")) install.packages("lubridate")

library(dplyr)
library(readr)
library(lubridate)

BASE_DIR <- getwd()
input_dir <- file.path(BASE_DIR, "outputs")

X_train <- read_csv(file.path(input_dir, "X_train_time.csv"))
y_train <- read_csv(file.path(input_dir, "y_train_time.csv"))
weather <- read_csv(file.path(input_dir, "weather_enhanced.csv"))

X_train$visit_date <- as.Date(X_train$visit_datetime)
weather$date <- as.Date(weather$date)

rows_to_keep <- which(X_train$visit_date >= as.Date("2014-03-01") & 
                      X_train$visit_date <= as.Date("2017-03-31"))
X_train_filtered <- X_train[rows_to_keep, ]
y_train_filtered <- y_train[rows_to_keep, ]

X_train_filtered$disposition <- y_train_filtered$disposition

X_train_weather <- left_join(X_train_filtered, weather, by = c("visit_date" = "date"))

write_csv(X_train_weather, file.path(input_dir, "X_train_weather.csv"))
cat("Merged patient and weather data saved successfully.\n")
