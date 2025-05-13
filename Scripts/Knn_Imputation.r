###############################################################################
# Script Name: knn_imputation_batches.R
# Description: Perform KNN Imputation in batches on large dataset to handle missing values.
#               - Impute categorical variables with mode.
#               - Impute numerical variables using KNN (k=3).
#               - Save processed batches and combine final result.
###############################################################################

# Load Required Libraries
library(data.table)
library(dplyr)
library(VIM)
if (!require("tqdm")) devtools::install_github("tidyverse/tqdm")
library(tqdm)

#  Configuration Parameters
input_path <- "data_after_removing_missing_90.csv"#Put the path for the file on your device
output_dir <- "Processed_Parts"#Put the path for the file on your device
batch_size <- 100000
start_batch <- 5  
k_value <- 3      

#  Create Output Directory if it doesn't exist
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Compute Total Number of Rows
n_rows <- as.integer(system(paste("find /c /v \"\" ", shQuote(input_path)), intern = TRUE))
n_rows <- as.integer(gsub(".*: ([0-9]+)", "\\1", n_rows)) - 1  # Exclude Header
chunks <- seq(0, n_rows, by = batch_size)
header <- names(fread(input_path, nrows = 0))

cat(sprintf("Total Rows: %d\n Total Batches: %d\n", n_rows, length(chunks)))

# Batch Processing
for (i in seq(start_batch, length(chunks))) {
  start <- chunks[i]
  cat(sprintf("\n Processing Batch %d of %d\n", i, length(chunks)))
  
  df <- tryCatch({
    fread(input_path, skip = start + 1, nrows = batch_size, header = FALSE)
  }, error = function(e) {
    cat(sprintf("Error reading batch %d: %s\n", i, e$message))
    next
  })
  
  setnames(df, header)

  # Column Types
  num_cols <- names(df)[sapply(df, is.numeric)]
  cat_cols <- names(df)[sapply(df, function(col) is.character(col) || is.factor(col))]

  # Impute Categorical Variables with Mode
  for (col in tqdm(cat_cols, desc = sprintf("Imputing Categorical (Batch %d)", i), leave = FALSE)) {
    mode_val <- names(sort(table(df[[col]]), decreasing = TRUE))[1]
    if (!is.na(mode_val)) df[[col]][is.na(df[[col]])] <- mode_val
  }

  # KNN Imputation for Numerical Variables!
  if (length(num_cols) > 0) {
    cat(sprintf("🔵 Starting KNN Imputation for Numerical Columns - Batch %d\n", i))
    df[, (num_cols) := kNN(df[, ..num_cols], k = k_value, imp_var = FALSE)]
  }

  # Save Batch Output
  output_file <- sprintf("%s/imputed_part_%d.csv", output_dir, i)
  fwrite(df, output_file)
  cat(sprintf("Batch %d Saved: %s\n", i, output_file))
}

# Merge All Processed Batches
cat("\n Merging All Batches into Final Dataset...\n")
all_parts <- list()

for (i in seq(1, length(chunks))) {
  part_path <- sprintf("%s/imputed_part_%d.csv", output_dir, i)
  if (file.exists(part_path)) {
    all_parts[[length(all_parts) + 1]] <- fread(part_path)
  }
}

final_df <- rbindlist(all_parts, use.names = TRUE, fill = TRUE)
final_output_path <- sprintf("%s/imputed_full_data.csv", output_dir)
fwrite(final_df, final_output_path)

cat(sprintf("Final File Saved Successfully: %s\n", final_output_path))
