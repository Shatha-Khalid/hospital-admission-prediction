
# تحميل المكتبات
library(dplyr)

# تحميل البيانات المتوازنة SMOTE
file_path <- "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/smote_balanced_data.csv"
data <- read.csv(file_path)

# التأكد أن العمود الزمني موجود
if (!"arrivalmonth" %in% colnames(data)) {
    stop("❌ العمود 'arrivalmonth' غير موجود.")
}

# تحويل الأشهر إلى ترتيب زمني
month_levels <- c("January", "February", "March", "April", "May", "June",
                  "July", "August", "September", "October", "November", "December")
data$month_number <- match(data$arrivalmonth, month_levels)

# ترتيب البيانات زمنيًا
data_sorted <- data %>% arrange(month_number)

# التقسيم: 80% تدريب، والباقي تحقق واختبار
n <- nrow(data_sorted)
train_size <- floor(0.8 * n)
val_test_size <- n - train_size
val_size <- floor(val_test_size / 2)

# المجموعات الثلاث
train_data <- data_sorted[1:train_size, ]
val_data <- data_sorted[(train_size + 1):(train_size + val_size), ]
test_data <- data_sorted[(train_size + val_size + 1):n, ]

# فصل X و y لكل مجموعة، واستبعاد arrivalmonth و month_number
X_train <- train_data %>% select(-disposition, -arrivalmonth, -month_number)
y_train <- train_data$disposition

X_val <- val_data %>% select(-disposition, -arrivalmonth, -month_number)
y_val <- val_data$disposition

X_test <- test_data %>% select(-disposition, -arrivalmonth, -month_number)
y_test <- test_data$disposition

# حفظ الملفات
write.csv(X_train, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/X_train_time_smote.csv", row.names = FALSE)
write.csv(y_train, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/y_train_time_smote.csv", row.names = FALSE)

write.csv(X_val, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/X_val_time_smote.csv", row.names = FALSE)
write.csv(y_val, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/y_val_time_smote.csv", row.names = FALSE)

write.csv(X_test, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/X_test_time_smote.csv", row.names = FALSE)
write.csv(y_test, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/y_test_time_smote.csv", row.names = FALSE)

cat("✅ تم تنفيذ التقسيم الزمني بنجاح على بيانات SMOTE وتم حفظ جميع الملفات.\n")
