


# تحميل المكتبات
install.packages("VIM")
install.packages("dplyr")
install.packages("pbapply")

library(dplyr)
library(VIM)
library(pbapply)

# مسار الملف الأصلي
file_path <- "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Data/cleaned_data.csv"

# تحميل البيانات
data <- read.csv(file_path)

# تفعيل مؤشر التقدم
pboptions(type = "txt")

# تعويض القيم المفقودة باستخدام KNN بدون إنشاء أعمدة *_imp
imputed_data <- kNN(data, k = 5, imp_var = FALSE)

# حفظ البيانات بعد التعويض
write.csv(imputed_data, "C:/Users/shath/Desktop/Masters/Research Project (2)/Package - R/Outputs/imputed_data_full_knn.csv", row.names = FALSE)
