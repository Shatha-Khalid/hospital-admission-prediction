###############################################################################
# Script Name : generate_daily_admissions.R
# Description : Generates daily admissions file from merged patient and weather data.
###############################################################################

if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")
if (!require("lubridate")) install.packages("lubridate")

library(dplyr)
library(readr)
library(lubridate)

BASE_DIR <- getwd()
input_dir <- file.path(BASE_DIR, "outputs")

X_train_weather <- read_csv(file.path(input_dir, "X_train_weather.csv"))
X_train_weather$visit_date <- as.Date(X_train_weather$visit_datetime)

if (!"disposition" %in% names(X_train_weather)) {
    stop("Column 'disposition' is missing in the dataset!")
}

daily_admissions <- X_train_weather %>%
  filter(disposition == "Admit") %>%
  group_by(visit_date) %>%
  summarise(admissions = n()) %>%
  arrange(visit_date)

write_csv(daily_admissions, file.path(input_dir, "daily_admissions.csv"))
cat("Daily admissions file generated successfully.\n")
