library(shiny)
library(ggplot2)
library(data.table)
library(markdown)

stormDataTable <- fread('data/events.agg.csv')
stormDataTable$EVTYPE <- tolower(stormDataTable$EVTYPE)
eventTypes <<- sort(unique(stormDataTable$EVTYPE))

shinyServer(function(input, output)
{
  output$eventTypeControl <- renderUI({
    checkboxGroupInput('eventTypes', 'Event types', eventTypes, selected = eventTypes)
  })
  
  stormDataTable.agg.year <-
    reactive({
      stormDataTable[YEAR >= input$range[1] &
           YEAR <= input$range[2] & EVTYPE %in% input$eventTypes,
         list(
           COUNT = sum(COUNT),INJURIES = sum(INJURIES),PROPDMG = round(sum(PROPDMG), 2),FATALITIES =
             sum(FATALITIES),CROPDMG = round(sum(CROPDMG), 2)
         ),
         by = list(YEAR)]
    })
  
  
  output$graphEvents <- renderChart({
    data <- stormDataTable.agg.year()[, list(COUNT = sum(COUNT)), by = list(YEAR)]
    setnames(data, c('YEAR', 'COUNT'), c("Year", "Count"))
    
    graphEvents <-
      nPlot(
        Count ~ Year,data = data[order(data$Year)],type = "multiBarChart", dom = 'graphEvents', width = 650
      )
    
    graphEvents$chart(margin = list(left = 100))
    graphEvents$yAxis(axisLabel = "Count", width = 80)
    graphEvents$xAxis(axisLabel = "Year", width = 70)
    return(graphEvents)
  })
  
  output$graphPopulation <- renderChart({
    data <-
      melt(stormDataTable.agg.year()[, list(Year = YEAR, Injuries = INJURIES, Fatalities =
                                  FATALITIES)],id = 'Year')
    graphPopulation <-
      nPlot(
        value ~ Year, group = 'variable', data = data[order(-Year, variable, decreasing = T)],
        type = 'stackedAreaChart', dom = 'graphPopulation', width = 650
      )
    
    graphPopulation$chart(margin = list(left = 100))
    graphPopulation$yAxis(axisLabel = "Affected", width = 80)
    graphPopulation$xAxis(axisLabel = "Year", width = 70)
    
    return(graphPopulation)
  })
  
  output$graphEconomic <- renderChart({
    data <-
      melt(stormDataTable.agg.year()[, list(Year = YEAR, Propety = PROPDMG, Crops = CROPDMG)],id =
             'Year')
    graphEconomic <- nPlot(
      value ~ Year, group = 'variable', data = data[order(-Year, variable, decreasing = T)],
      type = 'stackedAreaChart', dom = 'graphEconomic', width = 650
    )
    graphEconomic$chart(margin = list(left = 100))
    graphEconomic$yAxis(axisLabel = "Total damage (Million USD)", width = 80)
    graphEconomic$xAxis(axisLabel = "Year", width = 70)
    
    return(graphEconomic)
  })
})