from datetime import timedelta
from joblib import dump
from matplotlib import pyplot as plt
import pandas as pd
from sklearn.linear_model import ElasticNet
from sklearn.linear_model import LinearRegression
from sklearn import metrics
from sklearn.model_selection import GridSearchCV
from sklearn.preprocessing import StandardScaler
from xgboost import XGBRegressor


def main():
    prices_df = pd.read_csv("modified-prices-split-adjusted.csv")

    # Drops rows without target stock
    prices_df.drop(prices_df[prices_df["symbol"] != "AAPL"].index, inplace=True)

    # cleans dataset and removes unwanted features
    prices_df = prices_df.dropna()

    # splits data into training and test set
    # x_train, x_test, y_train, y_test = train_test_split(prices_df[["open", "low", "high", "volume", "sma_10", "macd", "rsi"]], prices_df["close"], test_size = 0.10, shuffle=False)
    x_train, x_test, y_train, y_test = train_test_split_last_year(prices_df)

    # scales data with standard scaler
    x_train, x_test = scaleData(x_train, x_test)

    # Creates and runs linear OLS model
    createOLSModel(x_train, x_test, y_train, y_test)

    # Creates and runs elastic model
    createElasticModel(x_train, x_test, y_train, y_test)

    # Creates and runs XGBoost model
    createXGBoostModel(x_train, x_test, y_train, y_test)


# splits the dataset into a training set and a test set, where the test set consists of the last year of data
def train_test_split_last_year(prices_df, date_col="date", feature_cols = ["open_L1", "low_L1", "high_L1", "volume_L1", "sma_10_L1", "macd_L1", "rsi_L1"], target_col = "close"):

    # Ensure the date column is in datetime format
    prices_df[date_col] = pd.to_datetime(prices_df[date_col])

    # Find the last date in the dataset
    last_date = prices_df[date_col].max()

    # Determine the cutoff date for the test set (one year before the last date)
    cutoff_date = last_date - timedelta(days=365)

    # Split into training and testing sets based on the cutoff date
    train_df = prices_df[prices_df[date_col] < cutoff_date]
    test_df = prices_df[prices_df[date_col] >= cutoff_date]

    # Extract train and test sets
    x_train, y_train = train_df[feature_cols], train_df[target_col]
    x_test, y_test = test_df[feature_cols], test_df[target_col]

    return x_train, x_test, y_train, y_test


# scales data with standard scaler
def scaleData(x_train, x_test):
    # Creates and trains scalar
    std_scaler = StandardScaler()
    std_scaler.fit(x_train)

    # Transforms data based on scalar
    columns = x_train.columns
    x_train = std_scaler.transform(x_train)
    x_train = pd.DataFrame(x_train, columns=columns)
    x_test = std_scaler.transform(x_test)
    x_test = pd.DataFrame(x_test, columns=columns)

    # saves scaler
    dump(std_scaler, 'TrainingScaler.joblib')

    return x_train, x_test


# creates, tests, and visualizes a linear regression (OLS regression)
def createOLSModel(x_train, x_test, y_train, y_test):

    # creates a linear regression
    print("\nCreating linear regression model (OLS regression)")
    linearReg = LinearRegression(n_jobs=-1)
    linearReg.fit(x_train, y_train)
    print(f"Best model coefficients: {linearReg.coef_}")
    print("\nTraining Set Metrics")
    y_train_pred = linearReg.predict(x_train)
    outputMetrics(y_train, y_train_pred)
    print("\nTest Set Metrics")
    y_test_pred = linearReg.predict(x_test)
    outputMetrics(y_test, y_test_pred)

    # plots a graph comparing actual value versus predicted value
    # fig, ax = plt.subplots()
    # y_pred = linearRegElastic.predict(x_test)
    # ax.scatter(y_pred, y_test, edgecolors=(0, 0, 1), alpha=0.1)
    # ax.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=3)
    # ax.set_xlabel('Predicted')
    # ax.set_ylabel('Actual')
    # plt.show()

    # saves model
    dump(linearReg, 'Linear.joblib')

# creates, tests, and visualizes a linear regression (elastic net regression)
def createElasticModel(x_train, x_test, y_train, y_test):

    # creates a linear regression
    print("\nCreating linear regression model (elastic net)")
    parameters = [{'l1_ratio': [0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]}]
    K = 5
    linearElasticRegElastic = GridSearchCV(ElasticNet(random_state=17, max_iter=10000), parameters, cv=K, verbose=0, n_jobs=-1)
    linearElasticRegElastic.fit(x_train, y_train)
    print(f"Best model parameters: {linearElasticRegElastic.best_params_}")
    print(f"Best model coefficients: {linearElasticRegElastic.best_estimator_.coef_}")
    print("\nTraining Set Metrics")
    y_train_pred = linearElasticRegElastic.predict(x_train)
    outputMetrics(y_train, y_train_pred)
    print("\nTest Set Metrics")
    y_test_pred = linearElasticRegElastic.predict(x_test)
    outputMetrics(y_test, y_test_pred)

    # plots a graph comparing actual value versus predicted value
    # fig, ax = plt.subplots()
    # y_pred = linearElasticRegElastic.predict(x_test)
    # ax.scatter(y_pred, y_test, edgecolors=(0, 0, 1), alpha=0.1)
    # ax.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=3)
    # ax.set_xlabel('Predicted')
    # ax.set_ylabel('Actual')
    # plt.show()

    # saves model
    dump(linearElasticRegElastic, 'Elastic.joblib')
    
    
# creates, tests, and visualizes a XGBoost regression
def createXGBoostModel(x_train, x_test, y_train, y_test):
    # creates a SVM polynomial model
    print("\nCreating XGBoost regression model")
    parameters = [{"max_depth": [6, 12, 18, 32, 38, 42], "gamma": [0, 0.1, 1, 10, 100, 1000], "min_child_weight": [0, 1, 10, 100, 1000], "subsample": [0.1, 0.5, 1]}]
    K = 5
    xgb_reg = GridSearchCV(XGBRegressor(), parameters, cv=K, verbose=0, n_jobs=-1)
    xgb_reg.fit(x_train, y_train)
    print(f"Best model parameters: {xgb_reg.best_params_}")
    print("\nTraining Set Metrics")
    y_train_pred = xgb_reg.predict(x_train)
    outputMetrics(y_train, y_train_pred)
    print("\nTest Set Metrics")
    y_test_pred = xgb_reg.predict(x_test)
    outputMetrics(y_test, y_test_pred)

    # plots a graph comparing actual value versus predicted value
    # fig, ax = plt.subplots()
    # y_pred = xgb_reg.predict(x_test)
    # ax.scatter(y_pred, y_test, edgecolors=(0, 0, 1), alpha=0.1)
    # ax.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=3, )
    # ax.set_xlabel('Predicted')
    # ax.set_ylabel('Actual')
    # plt.show()

    # plot feature importance
    # sorted_idx = xgb_reg.best_estimator_.feature_importances_.argsort()
    # sorted_df = pd.DataFrame(sorted_idx, columns=x_train.columns)
    # plt.barh(sorted_df)
    # plt.xlabel("Xgboost Feature Importance")
    # plot_importance(xgb_reg.best_estimator_)
    # plt.show()
    # feature_important = xgb_reg.best_estimator_.get_booster().get_score(importance_type='weight')
    # keys = list(feature_important.keys())
    # values = list(feature_important.values())
    #
    # data = pd.DataFrame(data=values, index=keys, columns=["score"]).sort_values(by="score", ascending=False)
    # data.nlargest(40, columns="score").plot(kind='barh', figsize=(20, 10))  ## plot top 40 features
    # plt.show()

    # saves model
    dump(xgb_reg, 'XGBR.joblib')


# outputs metrics for given predictions and actual data set
def outputMetrics(y_actual, y_pred):
    mse = metrics.root_mean_squared_error(y_actual, y_pred)
    r2 = metrics.r2_score(y_actual, y_pred)
    print("--------------------------------------")
    print('RMSE is {}'.format(mse))
    print('R2 score is {}'.format(r2))
    print("--------------------------------------")


if __name__ == "__main__":
    main()