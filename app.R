library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)
library(shinyjs)
library(glue)

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
                   start = max(dat$start_date)-7,
                   end = max(dat$start_date),
                   min = min(dat$start_date),
                   max = max(dat$start_date),
                   format = 'mm-dd-yyyy'),
    
    actionButton('apply','Apply Filters')
  ),
  dashboardBody(
    fluidRow(infoBoxOutput('activityTotal',width = 4),
             infoBoxOutput('minuteTotal',width = 4),
             infoBoxOutput('mileTotal',width = 4))
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
  

  
}

shinyApp(ui,server)