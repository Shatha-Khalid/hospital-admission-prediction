###############################################################################
# Script Name : arimax_forecasting.R
# Description : Prepares exogenous variables and trains ARIMAX model with PCA.
###############################################################################

if (!require("forecast")) install.packages("forecast")
if (!require("readr")) install.packages("readr")
if (!require("dplyr")) install.packages("dplyr")
if (!require("caret")) install.packages("caret")

library(forecast)
library(readr)
library(dplyr)
library(caret)

BASE_DIR <- getwd()
input_dir <- file.path(BASE_DIR, "outputs")

daily_admissions <- read_csv(file.path(input_dir, "daily_admissions.csv"))
weather <- read_csv(file.path(input_dir, "weather_enhanced.csv"))

daily_admissions$visit_date <- as.Date(daily_admissions$visit_date)
weather$date <- as.Date(weather$date)

merged_data <- left_join(daily_admissions, weather, by = c("visit_date" = "date"))
stopifnot(nrow(merged_data) == nrow(daily_admissions))

# Prepare xreg matrix
xreg_raw <- merged_data %>%
  select(temp_avg, temp_min, temp_max, precipitation, pressure, 
         is_weekend, is_holiday, temp_range, starts_with("season"))

# Remove constant columns
constant_cols <- names(which(apply(xreg_raw, 2, function(col) length(unique(col)) <= 1)))
xreg_no_constants <- xreg_raw %>% select(-all_of(constant_cols))

# PCA Transformation
pca_result <- prcomp(xreg_no_constants, center = TRUE, scale. = TRUE)
explained_variance <- summary(pca_result)$importance[3, ]
num_components <- which(cumsum(explained_variance) >= 0.95)[1]

xreg_pca <- pca_result$x[, 1:num_components]

# Data Splitting
test_size <- 30
train_size <- nrow(xreg_pca) - test_size

y_train <- merged_data$admissions[1:train_size]
y_test  <- merged_data$admissions[(train_size + 1):nrow(xreg_pca)]

xreg_train_final <- xreg_pca[1:train_size, ]
xreg_test_final  <- xreg_pca[(train_size + 1):nrow(xreg_pca), ]

# ARIMAX Training
model_arimax <- auto.arima(y_train, xreg = xreg_train_final, seasonal = TRUE, 
                           stepwise = TRUE, approximation = FALSE)

summary(model_arimax)

# Forecasting
forecast_arimax <- forecast(model_arimax, xreg = xreg_test_final, h = test_size)
plot(forecast_arimax, main = "ARIMAX Forecast with PCA")
accuracy(forecast_arimax, y_test)
