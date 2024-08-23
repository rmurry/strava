library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)
library(shinyjs)

ui <- dashboardPage(
  dashboardHeader(title = 'Strava Activity'),
  dashboardSidebar(
    pickerInput('activity_type',
                label = div(icon("bicycle"),' Activity Type'),
                choices= NULL,
                selected = NULL,
                options = pickerOptions(actionsBox = TRUE,
                                        liveSearch = TRUE,
                                        size = 10,
                                        container = "body",
                                        selectedTextFormat = "count > 1"),
                multiple = T),
    dateRangeInput("date_range", 
                   label = div(icon("calendar")," Date Range"),
                   start = NULL, 
                   end = NULL, 
                   min = NULL,
                   max = NULL,
                   format = 'mm-dd-yyyy'),
    actionButton('apply','Apply Filters')
  ),
  dashboardBody(
    useShinyjs(),
    fluidRow(
    )
  )
)

server <- function(input, output, session) {
  
  updatePickerInput(session,'activity_type',
                    choices = unique(dat$type),
                    selected = unique(dat$type))
  
  updateDateRangeInput(session,'date_range',
                       start = max(dat$start_date)-7,
                       end = max(dat$start_date),
                       min = min(dat$start_date),
                       max = max(dat$start_date))
  
  dat_rd <- eventReactive(input$apply, {
    
    dat %>%
      filter(type %in% input$activity_type,
             start_date >= input$date_range[1],
             start_date <= input$date_range[2])
    
  })

  
}

shinyApp(ui,server)