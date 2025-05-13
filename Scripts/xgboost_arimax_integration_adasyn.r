###############################################################################
# Script Name : xgboost_arimax_integration_adasyn.R
# Description : Integrates ARIMAX forecasts with XGBoost using ADASYN-balanced data.
###############################################################################

if (!require("xgboost")) install.packages("xgboost")
if (!require("pROC")) install.packages("pROC")
if (!require("caret")) install.packages("caret")
if (!require("MLmetrics")) install.packages("MLmetrics")
if (!require("readr")) install.packages("readr")
if (!require("dplyr")) install.packages("dplyr")
if (!require("lubridate")) install.packages("lubridate")

library(xgboost)
library(pROC)
library(caret)
library(MLmetrics)
library(readr)
library(dplyr)
library(lubridate)

BASE_DIR <- getwd()
input_dir <- file.path(BASE_DIR, "outputs", "temporal_splitting_adasyn")

X_train <- read_csv(file.path(input_dir, "X_train_time.csv"))
y_train <- read_csv(file.path(input_dir, "y_train_time.csv"))
X_val   <- read_csv(file.path(input_dir, "X_val_time.csv"))
y_val   <- read_csv(file.path(input_dir, "y_val_time.csv"))

y_train <- ifelse(y_train$disposition == "Admit", 1, 0)
y_val   <- ifelse(y_val$disposition == "Admit", 1, 0)

X_train$visit_date <- as.Date(X_train$visit_datetime)
X_val$visit_date   <- as.Date(X_val$visit_datetime)
X_train$visit_datetime <- NULL
X_val$visit_datetime   <- NULL

# Load ARIMAX Forecasts
arimax_train <- read_csv(file.path(BASE_DIR, "outputs", "arimax_forecast_train.csv"))
arimax_val   <- read_csv(file.path(BASE_DIR, "outputs", "arimax_forecast_val.csv"))
daily_admissions <- read_csv(file.path(BASE_DIR, "outputs", "daily_admissions.csv"))
daily_admissions$visit_date <- as.Date(daily_admissions$visit_date)

arimax_train$visit_date <- daily_admissions$visit_date[1:nrow(arimax_train)]
arimax_val$visit_date   <- daily_admissions$visit_date[(nrow(arimax_train) + 1):(nrow(arimax_train) + nrow(arimax_val))]

X_train <- left_join(X_train, arimax_train, by = "visit_date")
X_val   <- left_join(X_val, arimax_val, by = "visit_date")

colnames(X_train)[colnames(X_train) == "expected"] <- "expected_admissions"
colnames(X_val)[colnames(X_val) == "expected"]     <- "expected_admissions"

X_train <- X_train %>% select(-visit_date)
X_val   <- X_val %>% select(-visit_date)

X_train <- data.frame(lapply(X_train, as.numeric))
X_val   <- data.frame(lapply(X_val, as.numeric))

dtrain <- xgb.DMatrix(data = as.matrix(X_train), label = y_train)
dval   <- xgb.DMatrix(data = as.matrix(X_val),   label = y_val)

params <- list(
  objective = "binary:logistic",
  eval_metric = "auc",
  max_depth = 6,
  eta = 0.3
)

set.seed(42)
xgb_model <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 100,
  watchlist = list(val = dval),
  verbose = 1
)

probs <- predict(xgb_model, newdata = dval)
preds <- ifelse(probs > 0.5, 1, 0)

conf <- confusionMatrix(as.factor(preds), as.factor(y_val), positive = "1")
print(conf)

cat("F1-Score :", F1_Score(y_val, preds, positive = "1"), "\n")
cat("Precision:", Precision(y_val, preds, positive = "1"), "\n")
cat("Recall   :", Recall(y_val, preds, positive = "1"), "\n")

roc_obj <- roc(y_val, probs)
cat("AUC =", auc(roc_obj), "\n")
plot(roc_obj, main = "ROC Curve - XGBoost + ARIMAX (ADASYN)", col = "darkgreen")
