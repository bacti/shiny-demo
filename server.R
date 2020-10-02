library(data.table)
library(dygraphs)
library(datasets)
library(xts)          # To make the convertion data-frame / xts format
library(tidyverse)
library(lubridate)
library(quantmod)

PREDICTED_DAYS <- 20
shinyServer
(
    function(input, output, session)
    {
        drawChart <- function(DT) {
            chart <- dygraph(DT[, c(c(1,2,3,4) * input$candlestick, 6 * input$line, c(7,8,9) * input$predicted)])
            if (input$candlestick)
                chart <- chart %>% dyCandlestick()
            if (input$line)
                chart <- chart %>% dySeries('Adjusted', color = 'blue', label = 'Adjusted Closing Price')
            if (input$predicted)
                chart <- chart %>% dySeries(c('lwr', 'fit', 'upr'), label = 'Predicted')
            chart
        }

        observeEvent(
            input$watchlist,
            {
                future::future({
                    DT <- getSymbols(input$watchlist, auto.assign = FALSE)
                    names(DT) <- c('Open', 'High', 'Low', 'Close', 'Volume', 'Adjusted')
                    hw <- HoltWinters(ts(DT[,6], frequency = 5))
                    DT <<- cbind(
                        DT,
                        xts(predict(hw, n.ahead = PREDICTED_DAYS, prediction.interval = TRUE), tail(index(DT), 1) + (1:PREDICTED_DAYS))
                    )
                }) %>%
                promises::then({
                    chart <<- drawChart(DT) %>% dyRangeSelector()
                    output$dygraph <- renderDygraph(chart)
                    min <- index(DT)[1]
                    max <- tail(index(DT), 1)
                    output$dates <- renderUI({
                        dateRangeInput('dates', label = NULL, start = min, end = max, min = min, max = max)
                    })
                })
            }
        )

        sapply(
            c('candlestick', 'line', 'predicted', 'dates'),
            function(event)
            {
                observeEvent(
                    input[[event]],
                    {
                        chart <<- drawChart(DT) %>% dyRangeSelector(dateWindow = input$dates)
                        output$dygraph <- renderDygraph(chart)
                    }
                )
            }
        )

        sapply(
            list(list('M1', 1), list('M3', 3), list('M6', 6), list('Y1', 12), list('Y5', 60)),
            function(period)
            {
                observeEvent(input[[period[[1]]]], {
                    start <- format(lubridate::ymd(tail(index(DT), 1)) - months(period[[2]]), format = '%Y-%m-%d')
                    updateDateRangeInput(session, 'dates', start = start, end = tail(index(DT), 1))
                })
            }
        )

        observeEvent(
            input$YTD,
            {
                start <- format(lubridate::floor_date(lubridate::today(), 'year'), format = '%Y-%m-%d')
                updateDateRangeInput(session, 'dates', start = start, end = tail(index(DT), 1))
            }
        )
        
        observeEvent(input$All, updateDateRangeInput(session, 'dates', start = index(DT)[1], end = tail(index(DT), 1)))
    }
)
