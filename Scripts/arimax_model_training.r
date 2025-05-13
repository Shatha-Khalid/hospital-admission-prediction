###############################################################################
# Script Name : arimax_model_training.R
# Description : Trains ARIMAX model using selected exogenous variables 
#               while avoiding rank deficiency issues.
###############################################################################

if (!require("forecast")) install.packages("forecast")
if (!require("readr")) install.packages("readr")
if (!require("tseries")) install.packages("tseries")

library(forecast)
library(readr)
library(tseries)

BASE_DIR <- getwd()
input_dir <- file.path(BASE_DIR, "outputs")

daily_admissions <- read_csv(file.path(input_dir, "daily_admissions.csv"))
daily_admissions$visit_date <- as.Date(daily_admissions$visit_date)

# Time Series Conversion
admissions_ts <- ts(daily_admissions$admissions, frequency = 7, 
                    start = c(2014, as.numeric(format(min(daily_admissions$visit_date), "%j")) %/% 7 + 1))

print(head(admissions_ts))

# Stationarity Test
adf_result <- adf.test(admissions_ts)
print(adf_result)

# Plot ACF and PACF
acf(admissions_ts)
pacf(admissions_ts)
