# stock_price_predict
This project utlizes two differnt approaches to forcasting stock prices. Both approaches use the following parameters to predic the closing price of a stock. 
* open 
* low 
* high 
* volume 
* sma_10 (Simple Moving Aveage over 10 day period)
* macd 
* rsi

The first approach uses techniques from Econometrics such as the OLS regress and the common tests associated with this field. The code and results of this approach can be found in `analysis_commands.do` and `analysis_commands_lagged.do`. The difference between the first and second file is that `analysis_commands_lagged.do` uses all the same parameters, but lagged by one day. 

The second approach uses machine learning methods including OLS, Elastic Net Regression, and XGDBoost. This code also contains the methods to preform the regressions with and without the lagged parameters. The code to perform these regressions can be found in `regression.py`. Also, `indicator_generator.py` has code used to generate the technical indicators from the original price data, and `data_explore.py` has some methods to explore the dataset.

Also, a testing set can be used to see the generalizability of these regressions. `analysis_commands_test.do` and `analysis_commands_lagged_test.do` contain the STATA code to perform this test and `regression.py` has this code built in for the machine learning approach. 

The orginal data set used can be found in `prices-split-adjusted.csv` and this file comes from https://www.kaggle.com/datasets/dgawlik/nyse

This project uses Python 3.11 and STATA 17.0 (package requires for Python can be found in `requirements.txt`)
