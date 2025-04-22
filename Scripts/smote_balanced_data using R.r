
# تثبيت المكتبة إذا مو مثبتة
if (!require("smotefamily")) install.packages("smotefamily")
install.packages("dplyr")


# تحميل المكتبات
library(dplyr)
library(smotefamily)

# تحميل البيانات المعالجة بـ KNN
file_path <- "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/imputed_data_full_knn.csv"
data <- read.csv(file_path)

# تحويل العمود المستهدف إلى عامل (factor)
data$disposition <- as.factor(data$disposition)

# فصل الخصائص عن الهدف
X <- data %>%
    select(-disposition) %>%
    mutate(across(where(is.character), as.factor)) %>%
    mutate(across(where(is.factor), ~as.numeric(as.factor(.))))

y <- data$disposition

# تطبيق SMOTE
set.seed(42)
smote_result <- SMOTE(X, y, K = 5)

# دمج النتائج
smote_data <- cbind(smote_result$data, disposition = smote_result$data$class)
smote_data$class <- NULL  # حذف العمود المؤقت

# حفظ البيانات الجديدة
write.csv(smote_data, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/smote_balanced_data.csv", row.names = FALSE)

# تأكيد نجاح العملية
cat("✅ تم تطبيق SMOTE بنجاح باستخدام smotefamily.\n")
