clear

import delimited "M:\Stock Price Project\modified-prices-split-adjusted.csv"

generate Date = date(date, "YMD")

format Date %td

keep if symbol == "F"

tsset Date

// Generates a train_test flag to seperate train and test set
generate year = year(Date)
bysort year: gen max_year = _N == _N  // This finds the last year in the dataset
summarize year, meanonly
local last_year = r(max)
generate train_test = year == `last_year'   // Test set for the last year, 1 for test set, 0 for training set

* Step 1: Perform regression on the training set (data excluding the last year)
regress close open low high volume sma_10 macd rsi if train_test == 0

* Step 2: Use the estimated coefficients to predict values for the test set (last year)
predict y_hat_test if train_test == 1

* Step 3: Calculate residuals and test set statistics
gen residuals_test = close - y_hat_test  // Residuals for the test set
gen squared_residuals_test = residuals_test^2  // Squared residuals

* Step 4: Calculate RMSE (Root Mean Squared Error) for the test set
summarize squared_residuals_test, meanonly
local mean_squared_residuals = r(mean)
local rmse_test = sqrt(`mean_squared_residuals')

* Step 5: Calculate SST (Total Sum of Squares) for the test set
summarize close if train_test == 1, meanonly
local mean_close = r(mean)  // Mean of the actual close values in the test set
gen squared_deviation = (close - `mean_close')^2  // Squared deviation from the mean
summarize squared_deviation if train_test == 1, meanonly
local SST_test = r(sum)  // Total sum of squares for the test set

* Step 6: Calculate SSR (Sum of Squared Residuals) for the test set
summarize squared_residuals_test if train_test == 1, meanonly
local SSR_test = r(sum)

* Step 7: Calculate R-squared for the test set
local R2_test = 1 - (`SSR_test' / `SST_test')

* Display the R-squared, RMSE, and MAE for the test set
di "R-squared for test set: " `R2_test'
di "RMSE for test set: " `rmse_test'
// R-squared for test set: .98557654
// RMSE for test set: .07979883
