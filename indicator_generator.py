import pandas as pd


def calculate_rsi(df, period=14):
    # Calculate price changes
    delta = df.diff()

    # Separate gains and losses
    gain = delta.clip(lower=0)
    loss = -delta.clip(upper=0)

    # Calculate exponential moving averages of gains and losses
    avg_gain = gain.rolling(window=period, min_periods=period).mean()
    avg_loss = loss.rolling(window=period, min_periods=period).mean()

    # Calculate the Relative Strength (RS)
    rs = avg_gain / avg_loss

    # Calculates and returns the RSI
    rsi = 100 - (100 / (1 + rs))
    return rsi


def calculate_macd(df):
    # Get the 12-day EMA of the closing price
    ema_12 = df.groupby("symbol")["close"].transform(lambda group: group.ewm(span=12, adjust=False, min_periods=12).mean())

    # Get the 26-day EMA of the closing price
    ema_26 = df.groupby("symbol")["close"].transform(lambda group: group.ewm(span=26, adjust=False, min_periods=26).mean())

    # Calculates and returns the MACD
    macd = ema_12 - ema_26
    return macd


def calculate_sma(df, period=10):
    return df.rolling(period).mean()


def lag_indicators(df, lag=1, indicators=["open", "low", "high", "volume", "sma_10", "macd", "rsi"]):
    for indicator in indicators:
        df[f"{indicator}_L{lag}"] = df.groupby("symbol")[indicator].transform(lambda column: column.shift(lag))

    return df


def main():
    prices = pd.read_csv("prices-split-adjusted.csv")

    # Calculates the SMA
    prices["sma_10"] = prices.groupby("symbol")["close"].transform(calculate_sma)

    # Calculates the MACD
    prices["macd"] = calculate_macd(prices)

    # Calculates the RSI
    # Tested against https://www.marketvolume.com/quotes/calculatersi.asp
    prices["rsi"] = prices.groupby("symbol")["close"].transform(calculate_rsi)

    # Adds lagged indicators
    prices = lag_indicators(prices)

    # Adds indicators to dataset
    prices.to_csv("modified-prices-split-adjusted.csv", index=False)

if __name__ == "__main__":
    main()