
Predicting Hospital Admissions Using Machine Learning Techniques

Project Overview
This project focuses on predicting hospital admissions using various machine learning techniques, including Logistic Regression, XGBoost, Deep Neural Networks (DNN), and ARIMAX. The workflow covers data preprocessing, class balancing (ADASYN and SMOTE), temporal data splitting, weather data integration, time series modeling, and hybrid model development.

Note: The original hospital dataset is not included in this repository. You can download it directly from the original research GitHub repository that giving in the research.


Project Directory Structure

data:
Weather dataset only

scripts:
R scripts for all processing and modeling steps

README.md :
Project documentation

ecution Workflow
1. Data Preparation
weather_data_enhancement.R: Enhances weather data with additional features like is_weekend, is_holiday, temp_range, and performs one-hot encoding on seasons.

2. Class Balancing
adasyn_balancing_preprocessing.R: Balances class distribution using ADASYN.

smote_balancing_preprocessing.R: Balances class distribution using SMOTE.

3. Temporal Data Splitting
Temporal_data_splitting_adasyn.R

Temporal_data_splitting_smote.R
Splits datasets into training, validation, and test sets using a time-based approach.

4. ARIMAX Modeling
arimax_model_training.R: Trains the ARIMAX model using exogenous variables.

arimax_forecasting.R: Performs forecasting using the trained ARIMAX model.

save_arimax_forecasts.R: Saves ARIMAX forecast results for further integration.

5. Machine Learning Models
Logistic Regression
Logistic_regression_ridge_adasyn.R

Logistic_regression_ridge_smote.R

Applies Logistic Regression using Ridge regularization on ADASYN and SMOTE datasets without ARIMAX integration.

logistic_regression_arimax_adasyn.R

logistic_regression_arimax_smote.R

Combines ARIMAX forecasts with Logistic Regression for improved results.

XGBoost
XGBoost_classification_adasyn.R

XGBoost_classification_smote.R

Trains XGBoost models on ADASYN and SMOTE datasets without ARIMAX integration.

xgboost_arimax_integration_adasyn.R

xgboost_arimax_integration_smote.R

Integrates ARIMAX forecasts with XGBoost models for enhanced prediction accuracy.

Deep Neural Networks (DNN)
DNN_classification_adasyn.R

DNN_classification_smote.R

Trains DNN models using ADASYN and SMOTE balanced datasets.

Dependencies:
•	R (version >= 4.0.0)
•	Packages:
o	dplyr
o	readr
o	lubridate
o	forecast
o	tseries
o	pROC
o	caret
o	MLmetrics
o	xgboost
o	keras
install.packages(c("dplyr", "readr", "lubridate", "forecast", "tseries", "pROC", "caret", "MLmetrics", "xgboost", "keras"))

Notes
•	Ensure that all scripts are executed in the provided sequence for consistent results.
•	Weather and admissions data are expected to be preprocessed using the provided scripts before model training.


