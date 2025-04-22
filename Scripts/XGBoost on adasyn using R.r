

# تحميل المكتبات
library(xgboost)
library(caret)
library(pROC)
library(dplyr)

# تحميل البيانات
X_train <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/X_train_time.csv")
y_train <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/y_train_time.csv")$disposition

X_val <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/X_val_time.csv")
y_val <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/y_val_time.csv")$disposition

# التأكد أن y من نوع عامل (factor) وتحويلها إلى رقمية لـ XGBoost
y_train <- as.factor(y_train)
y_val <- as.factor(y_val)
y_train_num <- as.numeric(y_train) - 1  # Discharge = 0, Admit = 1
y_val_num <- as.numeric(y_val) - 1

# تحويل بيانات التدريب والتحقق إلى DMatrix
dtrain <- xgb.DMatrix(data = as.matrix(X_train), label = y_train_num)
dval <- xgb.DMatrix(data = as.matrix(X_val), label = y_val_num)

# تدريب النموذج
model <- xgboost(data = dtrain, objective = "binary:logistic", nrounds = 100, verbose = 0)

# التنبؤ بالاحتمالات
pred_probs <- predict(model, newdata = as.matrix(X_val))

# تحويل الاحتمالات إلى تصنيفات
pred_labels <- ifelse(pred_probs > 0.5, "Admit", "Discharge")
pred_labels <- factor(pred_labels, levels = levels(y_val))

# حساب المقاييس
conf_matrix <- confusionMatrix(pred_labels, y_val, positive = "Admit")
print(conf_matrix)

# حساب AUC
roc_obj <- roc(y_val, pred_probs, levels = rev(levels(y_val)))
auc_val <- auc(roc_obj)
cat(sprintf("🔵 AUC = %.3f\n", auc_val))

# رسم ROC Curve
plot(roc_obj, main = "ROC Curve - XGBoost", col = "darkgreen")
