library(shiny)
library(rCharts)
library(data.table)

shinyUI(fluidPage(
  titlePanel("Developing data products - Storm Database"),
  sidebarPanel(
    sliderInput(
      "range", "Range:", min = 1950, max = 2011,
      value = c(1993, 2011),format = "####"
    ),uiOutput("evtypeControls")
  ),
  
  mainPanel(tabsetPanel(
    tabPanel("Documentation",mainPanel(includeMarkdown("README.md"))),
    
    tabPanel(
      'By year',h4('Number of events', align = "center"), showOutput("eventsByYear", "nvd3"),
      h4('Population impact', align = "center"), showOutput("populationImpact", "nvd3"),
      h4('Economic impact', align = "center"), showOutput("economicImpact", "nvd3")
    )
  ))
))