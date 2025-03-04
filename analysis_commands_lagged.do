clear

import delimited "M:\Stock Price Project\modified-prices-split-adjusted.csv"

generate Date = date(date, "YMD")

format Date %td

keep if symbol == "F"

tsset Date

regress close L1.open L1.low L1.high L1.volume L1.sma_10 L1.macd L1.rsi
//       Source |       SS           df       MS      Number of obs   =     1,362
// -------------+----------------------------------   F(7, 1354)      =  14613.04
//        Model |  6593.32507         7  941.903582   Prob > F        =    0.0000
//     Residual |  87.2739131     1,354  .064456361   R-squared       =    0.9869
// -------------+----------------------------------   Adj R-squared   =    0.9869
//        Total |  6680.59899     1,361  4.90859588   Root MSE        =    .25388
//
// ------------------------------------------------------------------------------
//        close | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//         open |
//          L1. |  -.6631253   .0624151   -10.62   0.000     -.785566   -.5406846
//              |
//          low |
//          L1. |   .6223373    .054719    11.37   0.000     .5149941    .7296806
//              |
//         high |
//          L1. |   .9901447   .0637945    15.52   0.000      .864998    1.115291
//              |
//       volume |
//          L1. |  -3.55e-10   2.57e-10    -1.38   0.166    -8.58e-10    1.48e-10
//              |
//       sma_10 |
//          L1. |   .0435051   .0239594     1.82   0.070    -.0034965    .0905067
//              |
//         macd |
//          L1. |  -.0597153   .0376098    -1.59   0.113    -.1334952    .0140645
//              |
//          rsi |
//          L1. |   .0014454    .000653     2.21   0.027     .0001644    .0027265
//              |
//        _cons |  -.0052851   .0602034    -0.09   0.930    -.1233872    .1128169
// ------------------------------------------------------------------------------


estat vif
//     Variable |       VIF       1/VIF  
// -------------+----------------------
//         high |
//          L1. |    421.97    0.002370
//         open |
//          L1. |    404.85    0.002470
//          low |
//          L1. |    311.78    0.003207
//       sma_10 |
//          L1. |     58.49    0.017097
//          rsi |
//          L1. |      2.99    0.334429
//         macd |
//          L1. |      2.27    0.440910
//       volume |
//          L1. |      1.71    0.585924
// -------------+----------------------
//     Mean VIF |    172.01



estat ovtest
// Ramsey RESET test for omitted variables
// Omitted: Powers of fitted values of close
//
// H0: Model has no omitted variables
//
// F(3, 1351) =   3.80
//   Prob > F = 0.0099



estat bgodfrey, lags(1) nomiss0
// Number of gaps in sample = 362
//
// Breusch–Godfrey LM test for autocorrelation
// ---------------------------------------------------------------------------
//     lags(p)  |          chi2               df                 Prob > chi2
// -------------+-------------------------------------------------------------
//        1     |         37.545               1                   0.0000
// ---------------------------------------------------------------------------
//                         H0: no serial correlation



estat imtest, white
// White's test
// H0: Homoskedasticity
// Ha: Unrestricted heteroskedasticity
//
//    chi2(35) = 102.47
// Prob > chi2 = 0.0000
//
// Cameron & Trivedi's decomposition of IM-test
//
// --------------------------------------------------
//               Source |       chi2     df         p
// ---------------------+----------------------------
//   Heteroskedasticity |     102.47     35    0.0000
//             Skewness |      11.76      7    0.1086
//             Kurtosis |       1.50      1    0.2207
// ---------------------+----------------------------
//                Total |     115.73     43    0.0000
// --------------------------------------------------



dfuller L1.open, lags(0) 		// Z(t) = 0.1196 UNIT ROOT / NONSTATIONARY
dfuller close, lags(0)		// Z(t) = 0.2233 UNIT ROOT / NONSTATIONARY
dfuller L1.low, lags(0)		// Z(t) = 0.3281 UNIT ROOT / NONSTATIONARY
dfuller L1.high, lags(0)		// Z(t) = 0.2553 UNIT ROOT / NONSTATIONARY
dfuller L1.volume, lags(0)		// Z(t) = 0.0000
dfuller L1.sma_10, lags(0)		// Z(t) = 0.8474 UNIT ROOT / NONSTATIONARY
dfuller L1.macd, lags(0)		// Z(t) = 0.0711 UNIT ROOT / NONSTATIONARY
dfuller L1.rsi, lags(0)		// Z(t) = 0.0000
// H0: Random walk without drift, d = 0

regress L1.open close
predict residOC, residuals
dfuller residOC, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress L1.open L1.low
predict residOL, residuals
dfuller residOL, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress L1.open L1.high
predict residOH, residuals
dfuller residOH, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress L1.open L1.sma_10
predict residOS, residuals
dfuller residOS, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress close L1.low
predict residCL, residuals
dfuller residCL, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress close L1.high
predict residCH, residuals 
dfuller residCH, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress close L1.sma_10
predict residCS, residuals
dfuller residCS, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress L1.low L1.high
predict residLH, residuals
dfuller residLH, lags(0)	// Z(t) = 0.0000 COINTEGRATED 

regress L1.low L1.sma_10
predict residLS, residuals
dfuller residLS, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 