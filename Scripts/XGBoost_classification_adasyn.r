###############################################################################
# Script Name: xgboost_classification_adasyn.R
# Description: 
#   - Train and evaluate XGBoost classifier on ADASYN-balanced data 
#     using temporal splitting.
###############################################################################

# ------------------------- Install and Load Required Libraries -------------------------
if (!require("xgboost")) install.packages("xgboost")
if (!require("pROC")) install.packages("pROC")
if (!require("caret")) install.packages("caret")
if (!require("MLmetrics")) install.packages("MLmetrics")

library(xgboost)
library(pROC)
library(caret)
library(MLmetrics)

# ------------------------- Configuration -------------------------
BASE_DIR <- getwd()
input_dir <- file.path(BASE_DIR, "outputs", "temporal_splitting_adasyn")

X_train <- read.csv(file.path(input_dir, "X_train_time.csv"))
y_train <- read.csv(file.path(input_dir, "y_train_time.csv"))
X_val   <- read.csv(file.path(input_dir, "X_val_time.csv"))
y_val   <- read.csv(file.path(input_dir, "y_val_time.csv"))

# ------------------------- Preprocessing -------------------------
y_train <- ifelse(y_train$disposition == "Admit", 1, 0)
y_val   <- ifelse(y_val$disposition == "Admit", 1, 0)

X_train$visit_datetime <- NULL
X_val$visit_datetime <- NULL

X_train <- data.frame(lapply(X_train, as.numeric))
X_val   <- data.frame(lapply(X_val, as.numeric))

dtrain <- xgb.DMatrix(data = as.matrix(X_train), label = y_train)
dval   <- xgb.DMatrix(data = as.matrix(X_val), label = y_val)

# ------------------------- Model Parameters -------------------------
params <- list(
  objective = "binary:logistic",
  eval_metric = "auc",
  max_depth = 6,
  eta = 0.3
)

# ------------------------- Training -------------------------
set.seed(42)
xgb_model <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 100,
  watchlist = list(val = dval),
  verbose = 1
)

# ------------------------- Predictions and Evaluation -------------------------
probs <- predict(xgb_model, newdata = as.matrix(X_val))
preds <- ifelse(probs > 0.5, 1, 0)

conf <- confusionMatrix(as.factor(preds), as.factor(y_val), positive = "1")
print(conf)

cat("F1-Score :", F1_Score(y_val, preds, positive = "1"), "\n")
cat("Precision:", Precision(y_val, preds, positive = "1"), "\n")
cat("Recall   :", Recall(y_val, preds, positive = "1"), "\n")

roc_obj <- roc(y_val, probs)
cat("AUC =", auc(roc_obj), "\n")
plot(roc_obj, main = "ROC Curve - XGBoost (ADASYN)", col = "blue")
