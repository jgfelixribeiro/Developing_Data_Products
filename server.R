library(shiny)
library(ggplot2)
library(data.table)
library(maps)
library(rCharts)
library(reshape2)
library(markdown)
library(mapproj)

#stateMap <- map_data("state")
dt <- fread('data/events.agg.csv')
dt$EVTYPE <- tolower(dt$EVTYPE)
eventTypes <<- sort(unique(dt$EVTYPE))

shinyServer(function(input, output)
{
  output$evtypeControls <- renderUI({
    checkboxGroupInput('eventTypes', 'Event types', eventTypes, selected = eventTypes)
  })
  
  dt.agg.year <-
    reactive({
      dt[YEAR >= input$range[1] &
           YEAR <= input$range[2] & EVTYPE %in% input$eventTypes,
         list(
           COUNT = sum(COUNT),INJURIES = sum(INJURIES),PROPDMG = round(sum(PROPDMG), 2),FATALITIES =
             sum(FATALITIES),CROPDMG = round(sum(CROPDMG), 2)
         ),
         by = list(YEAR)]
    })
  
  
  output$eventsByYear <- renderChart({
    data <- dt.agg.year()[, list(COUNT = sum(COUNT)), by = list(YEAR)]
    setnames(data, c('YEAR', 'COUNT'), c("Year", "Count"))
    
    eventsByYear <-
      nPlot(
        Count ~ Year,data = data[order(data$Year)],type = "lineChart", dom = 'eventsByYear', width = 650
      )
    
    eventsByYear$chart(margin = list(left = 100))
    eventsByYear$yAxis(axisLabel = "Count", width = 80)
    eventsByYear$xAxis(axisLabel = "Year", width = 70)
    return(eventsByYear)
  })
  
  output$populationImpact <- renderChart({
    data <-
      melt(dt.agg.year()[, list(Year = YEAR, Injuries = INJURIES, Fatalities =
                                  FATALITIES)],id = 'Year')
    populationImpact <-
      nPlot(
        value ~ Year, group = 'variable', data = data[order(-Year, variable, decreasing = T)],
        type = 'stackedAreaChart', dom = 'populationImpact', width = 650
      )
    
    populationImpact$chart(margin = list(left = 100))
    populationImpact$yAxis(axisLabel = "Affected", width = 80)
    populationImpact$xAxis(axisLabel = "Year", width = 70)
    
    return(populationImpact)
  })
  
  output$economicImpact <- renderChart({
    data <-
      melt(dt.agg.year()[, list(Year = YEAR, Propety = PROPDMG, Crops = CROPDMG)],id =
             'Year')
    economicImpact <- nPlot(
      value ~ Year, group = 'variable', data = data[order(-Year, variable, decreasing = T)],
      type = 'stackedAreaChart', dom = 'economicImpact', width = 650
    )
    economicImpact$chart(margin = list(left = 100))
    economicImpact$yAxis(axisLabel = "Total damage (Million USD)", width = 80)
    economicImpact$xAxis(axisLabel = "Year", width = 70)
    
    return(economicImpact)
  })
})