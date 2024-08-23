library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)
library(shinyjs)
library(glue)
library(highcharter)
library(dplyr)

dat <- read.csv('strava.csv') %>%
  mutate(start_date = as.Date(start_date))

ui <- dashboardPage(
  dashboardHeader(title = 'Strava Activity'),
  dashboardSidebar(
    pickerInput('activity_type',
                label = div(icon("bicycle"),' Activity Type'),
                choices= unique(dat$type),
                selected = unique(dat$type),
                options = pickerOptions(actionsBox = TRUE,
                                        liveSearch = TRUE,
                                        size = 10,
                                        container = "body",
                                        selectedTextFormat = "count > 1"),
                multiple = T),
    
    dateRangeInput("date_range", 
                   label = div(icon("calendar")," Date Range"),
                   start = max(dat$start_date)-28,
                   end = max(dat$start_date),
                   min = min(dat$start_date),
                   max = max(dat$start_date),
                   format = 'mm-dd-yyyy'),
    
    actionButton('apply','Apply Filters')
  ),
  dashboardBody(
    fluidRow(infoBoxOutput('activityTotal',width = 4),
             infoBoxOutput('minuteTotal',width = 4),
             infoBoxOutput('mileTotal',width = 4)
             ),
    fluidRow(box(width = 4,highchartOutput('hrZones')),
             box(width = 8,highchartOutput('minutesTrend'))
             ),
    fluidRow(box(width = 12,highchartOutput('activityScatter')))
  )
)

server <- function(input, output, session) {
  
  dat_rd <- eventReactive(input$apply, {
    
    dat %>%
      filter(type %in% input$activity_type,
             start_date >= input$date_range[1],
             start_date <= input$date_range[2])
    
  }, ignoreNULL = F)
  
  output$activityTotal <- renderInfoBox({
    
    infoBox(title = 'Total Activities',
            value = nrow(dat_rd()))
  })
  
  output$minuteTotal <- renderInfoBox({
    
    infoBox(title = 'Total Minutes',
            value = round(sum(dat_rd()$minutes),digits = 0))
    
  })
  
  output$mileTotal <- renderInfoBox({
    
    infoBox(title = 'Total Miles',
            value = round(sum(dat_rd()$miles),digits = 1))
    
  })
  
  output$hrZones <- renderHighchart({
    
    dat_rd() %>%
      filter(!is.na(average_heartrate)) %>%
      group_by(hr_zone) %>%
      summarise(mins = sum(minutes)) %>%
      mutate(perc = round(mins / sum(mins) * 100,2)) %>%
      hchart('pie',hcaes(x = hr_zone,y = perc)) %>%
      hc_tooltip(pointFormat = '{point.perc}%') %>%
      hc_title(text = 'Average Heartrate Zone') %>%
      hc_add_theme(hc_theme_smpl())
    
  })
  
  output$minutesTrend <- renderHighchart({
    
    dat_rd() %>%
      group_by(week_of) %>%
      summarise(across(c(miles,minutes),\(x) round(sum(x, na.rm = T),0))) %>%
      hchart('spline',hcaes(x = week_of,y = minutes)) %>%
      hc_tooltip(pointFormat = '{point.minutes} minutes<br>{point.miles} miles') %>%
      hc_title(text = "Weekly Exercise Minutes")
    
  })
  
  output$activityScatter <- renderHighchart({
    
    dat_rd() %>%
      mutate(across(c(minutes,miles),\(x) round(x,2))) %>%
      hchart('scatter',hcaes(x = start_date,y = minutes, size = miles, group = type)) %>%
      hc_tooltip(pointFormat = '{point.name}<br><b>Date:</b> {point.start_date}<br><b>Type:</b> {point.type}<br><b>Length:</b> {point.miles} miles<br><b>Duration:</b> {point.minutes} minutes') %>%
      hc_title(text = 'Activity Scatter Plot')
    
  })
  

  
}

shinyApp(ui,server)