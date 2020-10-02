library(dygraphs)
rmarkdown::render('docs.Rmd')
shinyUI
(
    fluidPage
    (
        verticalLayout
        (
            mainPanel(dygraphOutput('dygraph'), width = '100%'),
            br(),
            splitLayout
            (
                div
                (
                    sidebarPanel
                    (
                        radioButtons
                        (
                            inputId = 'watchlist',
                            label = strong('Watchlist'),
                            choices = c
                            (
                                'Facebook, Inc. (FB)' = 'FB',
                                'Amazon.com, Inc. (AMZN)' = 'AMZN',
                                'Apple Inc. (AAPL)' = 'AAPL',
                                'Microsoft Corporation (MSFT)' = 'MSFT',
                                'Alphabet Inc. (GOOG)' = 'GOOG'
                            )
                        ),
                        width = '100%'
                    ),
                    sidebarPanel
                    (
                        strong('Time Period'),
                        splitLayout
                        (
                            actionButton(inputId = 'M1', label = '1M', width = '100%'),
                            actionButton(inputId = 'M3', label = '3M', width = '100%'),
                            actionButton(inputId = 'M6', label = '6M', width = '100%'),
                            actionButton(inputId = 'YTD', label = 'YTD', width = '100%'),
                            style = 'display: flex'
                        ),
                        splitLayout
                        (
                            actionButton(inputId = 'Y1', label = '1Y', width = '100%'),
                            actionButton(inputId = 'Y5', label = '5Y', width = '100%'),
                            actionButton(inputId = 'All', label = 'All', width = '100%'),
                            cellWidths = c('25%', '25%', '50%'),
                            style = 'display: flex'
                        ),
                        uiOutput('dates'),
                        checkboxInput('candlestick', label = 'Candlestick Charts', value = TRUE),
                        checkboxInput('line', label = 'Adjusted Closing Price', value = TRUE),
                        checkboxInput('predicted', label = 'Predicted Next 20 Days', value = TRUE),
                        width = '100%'
                    ),
                ),
                br(),
                div(includeMarkdown('docs.md'), style ='white-space: normal'),
                cellWidths = c('20%', '5%', '75%')
            )
        ),
        theme = 'styles.css'
    )
)
