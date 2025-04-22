

# تحميل المكتبة
library(dplyr)

# تحميل بيانات SMOTE
file_path <- "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/smote_balanced_data.csv"
data <- read.csv(file_path)

# التأكد أن العمود المستهدف كـ factor
data$disposition <- as.factor(data$disposition)

# خلط البيانات Shuffle
set.seed(42)
shuffled_data <- data[sample(nrow(data)), ]

# حساب أحجام المجموعات
n <- nrow(shuffled_data)
train_size <- floor(0.8 * n)
val_size <- floor(0.1 * n)
test_size <- n - train_size - val_size

# تقسيم البيانات
train_data <- shuffled_data[1:train_size, ]
val_data <- shuffled_data[(train_size + 1):(train_size + val_size), ]
test_data <- shuffled_data[(train_size + val_size + 1):n, ]

# فصل الخصائص والهدف
X_train <- train_data %>% select(-disposition)
y_train <- train_data$disposition

X_val <- val_data %>% select(-disposition)
y_val <- val_data$disposition

X_test <- test_data %>% select(-disposition)
y_test <- test_data$disposition

# حفظ النتائج
write.csv(X_train, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/X_train_random_smote.csv", row.names = FALSE)
write.csv(y_train, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/y_train_random_smote.csv", row.names = FALSE)

write.csv(X_val, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/X_val_random_smote.csv", row.names = FALSE)
write.csv(y_val, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/y_val_random_smote.csv", row.names = FALSE)

write.csv(X_test, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/X_test_random_smote.csv", row.names = FALSE)
write.csv(y_test, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/y_test_random_smote.csv", row.names = FALSE)

cat("✅ تم تنفيذ التقسيم العشوائي على بيانات SMOTE بنجاح وتم حفظ الملفات.\n")
