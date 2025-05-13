###############################################################################
# Script Name : patient_data_preparation.R
# Description : Prepares patient data by converting visit times to dates and 
#               generating daily admissions count.
###############################################################################

if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")
if (!require("lubridate")) install.packages("lubridate")

library(dplyr)
library(readr)
library(lubridate)

BASE_DIR <- getwd()
input_dir <- file.path(BASE_DIR, "outputs")
output_dir <- input_dir

X_train <- read_csv(file.path(input_dir, "X_train_time.csv"))
y_train <- read_csv(file.path(input_dir, "y_train_time.csv"))

X_train$visit_date <- as.Date(X_train$visit_datetime)
X_train$disposition <- y_train$disposition

daily_admissions <- X_train %>%
  filter(disposition == "Admit") %>%
  group_by(visit_date) %>%
  summarise(admissions = n()) %>%
  arrange(visit_date)

write_csv(daily_admissions, file.path(output_dir, "daily_admissions.csv"))
cat("Daily admissions file saved successfully.\n")
