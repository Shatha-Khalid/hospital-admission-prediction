
# تحميل المكتبات
library(dplyr)

# تحميل البيانات المتوازنة بعد ADASYN
file_path <- "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/adasyn_balanced_data.csv"
data <- read.csv(file_path)

# تأكد أن العمود المستهدف كـ factor
data$disposition <- as.factor(data$disposition)

# الترتيب حسب arrivalmonth (بما إنه أرقام من 1 إلى 12، ما نحتاج تحويل)
data_sorted <- data %>% arrange(arrivalmonth)

# حساب حجم البيانات لكل مجموعة
n <- nrow(data_sorted)
train_size <- floor(0.8 * n)
val_test_size <- n - train_size
val_size <- floor(val_test_size / 2)

# تقسيم البيانات
train_data <- data_sorted[1:train_size, ]
val_data <- data_sorted[(train_size + 1):(train_size + val_size), ]
test_data <- data_sorted[(train_size + val_size + 1):n, ]

# استخراج X و y لكل جزء
X_train <- train_data %>% select(-disposition, -arrivalmonth)
y_train <- train_data["disposition"]

X_val <- val_data %>% select(-disposition, -arrivalmonth)
y_val <- val_data["disposition"]

X_test <- test_data %>% select(-disposition, -arrivalmonth)
y_test <- test_data["disposition"]

# حفظ الملفات إلى CSV
write.csv(X_train, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/X_train_time.csv", row.names = FALSE)
write.csv(y_train, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/y_train_time.csv", row.names = FALSE)

write.csv(X_val, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/X_val_time.csv", row.names = FALSE)
write.csv(y_val, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/y_val_time.csv", row.names = FALSE)

write.csv(X_test, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/X_test_time.csv", row.names = FALSE)
write.csv(y_test, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/Temporal Splitting on adasyn/y_test_time.csv", row.names = FALSE)

cat("✅ تم تنفيذ التقسيم الزمني بنجاح وتم حفظ جميع الملفات.\n")
