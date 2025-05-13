###############################################################################
# Script Name : save_arimax_forecasts.R
# Description : Saves ARIMAX forecast results for use in other models.
###############################################################################

if (!require("readr")) install.packages("readr")
library(readr)

BASE_DIR <- getwd()
output_dir <- file.path(BASE_DIR, "outputs")

train_expected_admissions <- as.numeric(fitted(model_arimax))
test_expected_admissions  <- as.numeric(forecast_arimax$mean)

write.csv(data.frame(expected = train_expected_admissions),
          file.path(output_dir, "arimax_forecast_train.csv"),
          row.names = FALSE)

write.csv(data.frame(expected = test_expected_admissions),
          file.path(output_dir, "arimax_forecast_val.csv"),
          row.names = FALSE)

cat("ARIMAX forecast results saved successfully.\n")
