
# تثبيت المكتبة إذا مو مثبتة
if (!require("smotefamily")) install.packages("smotefamily")
install.packages("dplyr")

# تحميل المكتبات
library(dplyr)
library(smotefamily)

# تحميل البيانات المعالجة بـ KNN
file_path <- "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/imputed_data_full_knn.csv"
data <- read.csv(file_path)

# تحويل العمود المستهدف إلى factor
data$disposition <- as.factor(data$disposition)

# فصل الهدف عن الخصائص
X <- data %>%
  select(-disposition) %>%
  mutate(across(where(is.character), as.factor)) %>%
  mutate(across(where(is.factor), ~as.numeric(as.factor(.))))

y <- data$disposition

# تطبيق ADASYN من مكتبة smotefamily
set.seed(42)
adasyn_result <- ADAS(X, y, K = 5)

# إعادة دمج البيانات بعد التوازن
balanced_data <- cbind(adasyn_result$data, disposition = adasyn_result$data$class)
balanced_data$class <- NULL  # إزالة العمود المؤقت "class"

# حفظ البيانات الجديدة
write.csv(balanced_data, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/adasyn_balanced_data.csv", row.names = FALSE)

cat("✅ تم تطبيق ADASYN بنجاح باستخدام smotefamily.\n")
