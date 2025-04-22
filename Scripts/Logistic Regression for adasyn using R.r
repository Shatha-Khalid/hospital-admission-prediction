

# تحميل المكتبات
library(dplyr)
library(caret)
library(pROC)

# تحميل البيانات
X_train <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/X_train_time.csv")
y_train <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/y_train_time.csv")

X_val <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/X_val_time.csv")
y_val <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/y_val_time.csv")

# التأكد أن الهدف نوعه factor
y_train <- as.factor(y_train$disposition)
y_val <- as.factor(y_val$disposition)

# دمج بيانات التدريب
train_data <- cbind(X_train, disposition = y_train)

# تدريب نموذج Logistic Regression
model_lr <- glm(disposition ~ ., data = train_data, family = binomial)

# التنبؤ باحتمالات على مجموعة التحقق
probabilities <- predict(model_lr, newdata = X_val, type = "response")

# تحويل الاحتمالات إلى تصنيفات
predictions <- ifelse(probabilities > 0.5, "Discharge", "Admit")
predictions <- factor(predictions, levels = levels(y_val))

# حساب مقاييس الأداء
conf_matrix <- confusionMatrix(predictions, y_val, positive = "Admit")
print(conf_matrix)

# حساب AUC
roc_obj <- roc(response = y_val, predictor = probabilities, levels = rev(levels(y_val)))
auc_value <- auc(roc_obj)
cat(sprintf("🔵 AUC = %.3f\n", auc_value))

# رسم منحنى ROC
plot(roc_obj, main = "ROC Curve - Logistic Regression", col = "blue")
