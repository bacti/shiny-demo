Trading View of The Big Five Tech Companies
===
author: Hai Bacti
date: October 02, 2020
transition: rotate

Apply [`quantmod`](http://www.quantmod.com/) and [`dygraphs`](http://dygraphs.com/) packages to make visualized analysis and simple prediction of FAAMG's stock values on NASDAQ.

Available at https://bacti.shinyapps.io/StockView/



===
Using `quantmod::getSymbols` function to load [OHLC](https://en.wikipedia.org/wiki/Open-high-low-close_chart) data and `HoltWinters` function to computes Holt-Winters Filtering of the adjusted closing price.


```r
OHLC <- getSymbols(watchlist,
                   auto.assign = FALSE)
names(OHLC) <- c('Open', 'High', 'Low',
                 'Close', 'Volume', 'Adjusted')
hw <- HoltWinters(ts(OHLC[,6], frequency = 5))
OHLC <- cbind(
   OHLC,
   xts(
      predict(hw, n.ahead = PREDICTED_DAYS,
              prediction.interval = TRUE),
      tail(index(OHLC), 1) + (1:PREDICTED_DAYS)
   )
)
```

Adding prediction values at the end of OHLC stock data.

===
In the codes below, we make a analysis with Candlestick Charts, Line Chart and a prediction of the Adjusted Closing Price in next 20 days.

Stock to check is of Facebook, Inc. (FB).


```r
watchlist <- 'FB'
PREDICTED_DAYS <- 20
```


```r
chart <- dygraph(OHLC[,-5]) %>%
    dyCandlestick() %>%
    dySeries('Adjusted', color = 'blue',
          label = 'Adjusted Closing Price') %>%
    dySeries(c('lwr', 'fit', 'upr'),
             label = 'Predicted')
```


===
Users could select a date window they want to zoom into the chart.  
For example, 3 months back from present time.


```r
## number of months
n <- 3

## start and end of the date window
s <- format(tail(index(OHLC), 1) - months(n),
            format = '%Y-%m-%d')
e <- format(tail(index(OHLC), 1),
            format = '%Y-%m-%d')

## add a range selector to the chart bottom
chart <- chart %>%
    dyRangeSelector(dateWindow = c(s, e))
```


===
**THANK YOU!!**
<iframe src='chart.html' style='position:absolute;height:100%;width:100%'></iframe>
