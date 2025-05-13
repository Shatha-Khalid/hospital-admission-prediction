###############################################################################
# Script Name: dnn_classification_smote.R
# Description: 
#   - Train and evaluate a Deep Neural Network on SMOTE-balanced data 
#     using temporal splitting.
###############################################################################

# ------------------------- Install and Load Required Libraries -------------------------
if (!require("keras")) install.packages("keras")
if (!require("caret")) install.packages("caret")
if (!require("pROC")) install.packages("pROC")
if (!require("MLmetrics")) install.packages("MLmetrics")
if (!require("dplyr")) install.packages("dplyr")

library(keras)
library(caret)
library(pROC)
library(MLmetrics)
library(dplyr)

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

y_train <- ifelse(y_train$disposition == "Admit", 1, 0)
y_val   <- ifelse(y_val$disposition == "Admit", 1, 0)

X_train_mat <- as.matrix(X_train_scaled)
X_val_mat   <- as.matrix(X_val_scaled)

# ------------------------- Build and Compile DNN -------------------------
model <- keras_model_sequential() %>%
  layer_dense(units = 256, activation = "relu", input_shape = ncol(X_train_mat)) %>%
  layer_batch_normalization() %>%
  layer_dropout(rate = 0.4) %>%
  layer_dense(units = 128, activation = "relu") %>%
  layer_batch_normalization() %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 64, activation = "relu") %>%
  layer_batch_normalization() %>%
  layer_dropout(rate = 0.2) %>%
  layer_dense(units = 1, activation = "sigmoid")

model %>% compile(
  loss = "binary_crossentropy",
  optimizer = optimizer_adam(learning_rate = 0.001),
  metrics = c("accuracy")
)

# ------------------------- Callbacks -------------------------
early_stop <- callback_early_stopping(monitor = "val_loss", patience = 5, restore_best_weights = TRUE)
lr_schedule <- callback_learning_rate_scheduler(function(epoch, lr) {
  if (epoch > 10) return(lr * 0.5)
  return(lr)
})

# ------------------------- Training -------------------------
history <- model %>% fit(
  X_train_mat, y_train,
  epochs = 50,
  batch_size = 128,
  validation_data = list(X_val_mat, y_val),
  callbacks = list(early_stop, lr_schedule),
  verbose = 1
)

# ------------------------- Evaluation -------------------------
probs <- model %>% predict(X_val_mat)
preds <- ifelse(probs > 0.5, 1, 0)

conf <- confusionMatrix(as.factor(preds), as.factor(y_val), positive = "1")
print(conf)

cat("F1-Score :", F1_Score(y_val, preds, positive = "1"), "\n")
cat("Precision:", Precision(y_val, preds, positive = "1"), "\n")
cat("Recall   :", Recall(y_val, preds, positive = "1"), "\n")

roc_obj <- roc(y_val, as.numeric(probs))
cat("AUC =", auc(roc_obj), "\n")
plot(roc_obj, main = "ROC Curve - DNN (SMOTE)", col = "darkblue")
