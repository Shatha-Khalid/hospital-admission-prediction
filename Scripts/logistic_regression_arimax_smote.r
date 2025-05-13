###############################################################################
# Script Name : logistic_regression_arimax_smote.R
# Description: 
#   - Integrates ARIMAX forecasts with Logistic Regression model 
#     using SMOTE-balanced data.
###############################################################################

# ------------------------- Install and Load Required Libraries -------------------------
if (!require("readr")) install.packages("readr")
if (!require("dplyr")) install.packages("dplyr")
if (!require("caret")) install.packages("caret")
if (!require("lubridate")) install.packages("lubridate")
if (!require("pROC")) install.packages("pROC")

library(readr)
library(dplyr)
library(caret)
library(lubridate)
library(pROC)

# ------------------------- Configuration -------------------------
BASE_DIR <- getwd()
input_dir <- file.path(BASE_DIR, "outputs", "temporal_splitting_smote")

X_train <- read_csv(file.path(input_dir, "X_train_time.csv"))
X_val   <- read_csv(file.path(input_dir, "X_val_time.csv"))
y_train <- read_csv(file.path(input_dir, "y_train_time.csv"))
y_val   <- read_csv(file.path(input_dir, "y_val_time.csv"))

y_train <- ifelse(y_train$disposition == "Admit", 1, 0)
y_val   <- ifelse(y_val$disposition == "Admit", 1, 0)

X_train$visit_date <- as.Date(X_train$visit_datetime)
X_val$visit_date   <- as.Date(X_val$visit_datetime)
X_train$visit_datetime <- NULL
X_val$visit_datetime   <- NULL

# ------------------------- Load ARIMAX Forecasts -------------------------
arimax_train <- read_csv(file.path(BASE_DIR, "outputs", "arimax_forecast_train.csv"))
arimax_val   <- read_csv(file.path(BASE_DIR, "outputs", "arimax_forecast_val.csv"))
daily_adm    <- read_csv(file.path(BASE_DIR, "outputs", "daily_admissions.csv"))
daily_adm$visit_date <- as.Date(daily_adm$visit_date)

arimax_train$visit_date <- daily_adm$visit_date[1:nrow(arimax_train)]
arimax_val$visit_date   <- daily_adm$visit_date[(nrow(arimax_train) + 1):(nrow(arimax_train) + nrow(arimax_val))]

X_train <- left_join(X_train, arimax_train, by = "visit_date")
X_val   <- left_join(X_val, arimax_val, by = "visit_date")

colnames(X_train)[colnames(X_train) == "expected"] <- "expected_admissions"
colnames(X_val)[colnames(X_val) == "expected"]     <- "expected_admissions"

# ------------------------- Handle Missing Values -------------------------
X_train$expected_admissions[is.na(X_train$expected_admissions)] <- 
  ave(X_train$expected_admissions, X_train$visit_date, FUN = function(x) mean(x, na.rm = TRUE))

X_val$expected_admissions[is.na(X_val$expected_admissions)] <- 
  ave(X_val$expected_admissions, X_val$visit_date, FUN = function(x) mean(x, na.rm = TRUE))

X_train$visit_date <- NULL
X_val$visit_date   <- NULL

# ------------------------- Standardization -------------------------
scaler <- preProcess(X_train, method = c("center", "scale"))
X_train_scaled <- predict(scaler, X_train)
X_val_scaled   <- predict(scaler, X_val)

# ------------------------- Logistic Regression Model -------------------------
logit_model <- glm(y_train ~ ., data = cbind(X_train_scaled, y_train = y_train), family = "binomial")

# ------------------------- Prediction and Evaluation -------------------------
probs <- predict(logit_model, newdata = X_val_scaled, type = "response")
preds <- ifelse(probs > 0.5, 1, 0)

conf <- confusionMatrix(as.factor(preds), as.factor(y_val), positive = "1")
print(conf)

cat("F1-Score :", MLmetrics::F1_Score(y_val, preds, positive = "1"), "\n")
cat("Precision:", MLmetrics::Precision(y_val, preds, positive = "1"), "\n")
cat("Recall   :", MLmetrics::Recall(y_val, preds, positive = "1"), "\n")

roc_obj <- roc(y_val, as.numeric(probs))
cat("AUC =", auc(roc_obj), "\n")
plot(roc_obj, main = "ROC Curve - Logistic Regression + ARIMAX (SMOTE)", col = "darkblue")
