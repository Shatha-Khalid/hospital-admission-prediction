###############################################################################
# Script Name: logistic_regression_ridge_smote.R
# Description: 
#   - Train and evaluate Logistic Regression (Ridge) on SMOTE-balanced data 
#     using temporal splitting.
###############################################################################

# ------------------------- Install and Load Required Libraries -------------------------
if (!require("glmnet")) install.packages("glmnet")
if (!require("caret")) install.packages("caret")
if (!require("MLmetrics")) install.packages("MLmetrics")
if (!require("pROC")) install.packages("pROC")

library(glmnet)
library(caret)
library(MLmetrics)
library(pROC)

# ------------------------- Configuration -------------------------
BASE_DIR <- getwd()
input_dir <- file.path(BASE_DIR, "outputs", "temporal_splitting_smote")

X_train <- read.csv(file.path(input_dir, "X_train_time.csv"))
y_train <- read.csv(file.path(input_dir, "y_train_time.csv"))
X_val   <- read.csv(file.path(input_dir, "X_val_time.csv"))
y_val   <- read.csv(file.path(input_dir, "y_val_time.csv"))

X_train$visit_datetime <- NULL
X_val$visit_datetime <- NULL

X_train <- data.frame(lapply(X_train, as.numeric))
X_val   <- data.frame(lapply(X_val, as.numeric))

# ------------------------- Standardization -------------------------
scaler <- preProcess(X_train, method = c("center", "scale"))
X_train_scaled <- predict(scaler, X_train)
X_val_scaled   <- predict(scaler, X_val)

# ------------------------- Prepare Target Variable -------------------------
y_train <- ifelse(y_train$disposition == "Admit", 1, 0)
y_val   <- ifelse(y_val$disposition == "Admit", 1, 0)

X_train_mat <- as.matrix(X_train_scaled)
X_val_mat   <- as.matrix(X_val_scaled)

# ------------------------- Model Training (Logistic Regression with L2 Regularization) -------------------------
set.seed(42)
cv_model <- cv.glmnet(X_train_mat, y_train, alpha = 0, family = "binomial", type.measure = "auc")

# ------------------------- Predictions and Evaluation -------------------------
probs <- predict(cv_model, newx = X_val_mat, s = "lambda.min", type = "response")
preds <- ifelse(probs > 0.5, 1, 0)

conf <- confusionMatrix(as.factor(preds), as.factor(y_val), positive = "1")
print(conf)

cat("F1-Score :", F1_Score(y_val, preds, positive = "1"), "\n")
cat("Precision:", Precision(y_val, preds, positive = "1"), "\n")
cat("Recall   :", Recall(y_val, preds, positive = "1"), "\n")

roc_obj <- roc(y_val, as.numeric(probs))
cat("AUC =", auc(roc_obj), "\n")
plot(roc_obj, main = "ROC Curve - Logistic Regression (Ridge) - SMOTE", col = "darkblue")
