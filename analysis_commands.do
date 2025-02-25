generate Date = date(date, "YMD")

format Date %td

keep if symbol == "F"

tsset Date

regress close open low high volume sma_10 macd rsi

//  Source |       SS           df       MS      Number of obs   =     1,737
// -------------+----------------------------------   F(7, 1729)      >  99999.00
//        Model |  8529.44223         7  1218.49175   Prob > F        =    0.0000
//     Residual |  12.9524005     1,729  .007491267   R-squared       =    0.9985
// -------------+----------------------------------   Adj R-squared   =    0.9985
//        Total |  8542.39463     1,736  4.92073423   Root MSE        =    .08655
//
// ------------------------------------------------------------------------------
//        close | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//         open |  -.5348824   .0187287   -28.56   0.000    -.5716157    -.498149
//          low |   .5471133   .0172983    31.63   0.000     .5131855    .5810411
//         high |   .9348434   .0197598    47.31   0.000     .8960877     .973599
//       volume |  -5.43e-10   7.85e-11    -6.91   0.000    -6.97e-10   -3.89e-10
//       sma_10 |   .0506517   .0072458     6.99   0.000     .0364404    .0648631
//         macd |  -.0257818   .0113186    -2.28   0.023    -.0479813   -.0035822
//          rsi |   .0017678   .0001984     8.91   0.000     .0013787     .002157
//        _cons |   -.081947   .0181518    -4.51   0.000    -.1175487   -.0463452
// ------------------------------------------------------------------------------

estat vif

//     Variable |       VIF       1/VIF  
// -------------+----------------------
//         high |    445.00    0.002247
//         open |    401.66    0.002490
//          low |    342.71    0.002918
//       sma_10 |     58.75    0.017020
//          rsi |      3.00    0.333526
//         macd |      2.26    0.443425
//       volume |      1.85    0.540320
// -------------+----------------------
//     Mean VIF |    179.32


estat ovtest

// Ramsey RESET test for omitted variables
// Omitted: Powers of fitted values of close
//
// H0: Model has no omitted variables
//
// F(3, 1726) =   1.49
//   Prob > F = 0.2147


estat bgodfrey, lags(1) nomiss0

// Number of gaps in sample = 374
//
// Breusch–Godfrey LM test for autocorrelation
// ---------------------------------------------------------------------------
//     lags(p)  |          chi2               df                 Prob > chi2
// -------------+-------------------------------------------------------------
//        1     |         18.280               1                   0.0000
// ---------------------------------------------------------------------------
//                         H0: no serial correlation
//


estat imtest, white

// White's test
// H0: Homoskedasticity
// Ha: Unrestricted heteroskedasticity
//
//    chi2(35) = 1266.66
// Prob > chi2 =  0.0000
//
// Cameron & Trivedi's decomposition of IM-test
//
// --------------------------------------------------
//               Source |       chi2     df         p
// ---------------------+----------------------------
//   Heteroskedasticity |    1266.66     35    0.0000
//             Skewness |     357.35      7    0.0000
//             Kurtosis |       1.95      1    0.1623
// ---------------------+----------------------------
//                Total |    1625.96     43    0.0000
// --------------------------------------------------

dfuller open, lags(0) 		// Z(t) = 0.2029 UNIT ROOT / NONSTATIONARY
dfuller close, lags(0)		// Z(t) = 0.2233 UNIT ROOT / NONSTATIONARY
dfuller low, lags(0)		// Z(t) = 0.1603 UNIT ROOT / NONSTATIONARY
dfuller high, lags(0)		// Z(t) = 0.2198 UNIT ROOT / NONSTATIONARY
dfuller volume, lags(0)		// Z(t) = 0.0000
dfuller sma_10, lags(0)		// Z(t) = 0.7964 UNIT ROOT / NONSTATIONARY
dfuller macd, lags(0)		// Z(t) = 0.0335
dfuller rsi, lags(0)		// Z(t) = 0.0000
// H0: Random walk without drift, d = 0

regress open close
predict residOC, residuals
dfuller residOC, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress open low
predict residOL, residuals
dfuller residOL, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress open high
predict residOH, residuals
dfuller residOH, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress open sma_10
predict residOS, residuals
dfuller residOS, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress close low
predict residCL, residuals
dfuller residCL, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress close high
predict residCH, residuals 
dfuller residCH, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress close sma_10
predict residCS, residuals
dfuller residCS, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 

regress low high
predict residLH, residuals
dfuller residLH, lags(0)	// Z(t) = 0.0000 COINTEGRATED 

regress low sma_10
predict residLS, residuals
dfuller residLS, lags(0) 	// Z(t) = 0.0000 COINTEGRATED 