
# تثبيت keras وتفعيل TensorFlow تلقائيًا
install.packages("keras")


# تحميل المكتبات
library(keras)
library(tensorflow)
library(dplyr)
library(pROC)
library(caret)

# تحميل البيانات
X_train <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/X_train_time.csv")
y_train <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/y_train_time.csv")$disposition

X_val <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/X_val_time.csv")
y_val <- read.csv("C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/y_val_time.csv")$disposition

# تحويل الهدف إلى رقمي: Discharge = 0, Admit = 1
y_train_bin <- ifelse(y_train == "Admit", 1, 0)
y_val_bin <- ifelse(y_val == "Admit", 1, 0)

# تحويل البيانات إلى مصفوفات
X_train_matrix <- as.matrix(X_train)
X_val_matrix <- as.matrix(X_val)

# بناء النموذج
model <- keras_model_sequential() %>%
  layer_dense(units = 128, activation = 'relu', input_shape = ncol(X_train_matrix)) %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 64, activation = 'relu') %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 1, activation = 'sigmoid')

# تجميع النموذج
model %>% compile(
  loss = 'binary_crossentropy',
  optimizer = optimizer_adam(),
  metrics = c('accuracy')
)

# تدريب النموذج
history <- model %>% fit(
  X_train_matrix, y_train_bin,
  epochs = 30,
  batch_size = 32,
  validation_data = list(X_val_matrix, y_val_bin),
  verbose = 1
)

# التنبؤ
pred_probs <- model %>% predict(X_val_matrix)
pred_classes <- ifelse(pred_probs > 0.5, "Admit", "Discharge")
pred_classes <- factor(pred_classes, levels = c("Discharge", "Admit"))

# المقارنة بالهدف الحقيقي
y_val_factor <- factor(ifelse(y_val_bin == 1, "Admit", "Discharge"), levels = c("Discharge", "Admit"))

# حساب المقاييس
conf_matrix <- confusionMatrix(pred_classes, y_val_factor, positive = "Admit")
print(conf_matrix)

# حساب AUC
roc_obj <- roc(y_val_factor, pred_probs)
auc_val <- auc(roc_obj)
cat(sprintf("🔵 AUC = %.3f\n", auc_val))

# رسم منحنى ROC
plot(roc_obj, main = "ROC Curve - DNN", col = "purple")
